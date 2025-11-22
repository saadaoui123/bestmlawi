import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:intl/intl.dart';
import 'package:projet_best_mlewi/vue/management/assign_dialogs.dart';
import 'order_detail_page.dart';

class OrdersManagementTab extends StatefulWidget {
  const OrdersManagementTab({super.key});

  @override
  State<OrdersManagementTab> createState() => _OrdersManagementTabState();
}

class _OrdersManagementTabState extends State<OrdersManagementTab> {
  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des Commandes'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'En Attente'),
              Tab(text: 'En Cours'),
              Tab(text: 'Terminées'),
            ],
          ),
        ),
        body: StreamBuilder<List<Commande>>(
          stream: orderService.getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final allOrders = snapshot.data ?? [];

            // Filter orders
            final pendingOrders = allOrders.where((o) => 
              ['pending', 'confirmed'].contains(o.status.toLowerCase())
            ).toList();

            final activeOrders = allOrders.where((o) => 
              ['assigned_to_driver', 'assigned_to_point', 'preparing', 'delivering'].contains(o.status.toLowerCase())
            ).toList();

            final historyOrders = allOrders.where((o) => 
              ['delivered', 'cancelled'].contains(o.status.toLowerCase())
            ).toList();

            return TabBarView(
              children: [
                _buildOrderList(pendingOrders),
                _buildOrderList(activeOrders),
                _buildOrderList(historyOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(List<Commande> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Aucune commande',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(context, order);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Commande order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManagementOrderDetailPage(order: order),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.id?.substring(0, 8) ?? "N/A"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${order.clientFirstName} ${order.clientName}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM HH:mm').format(order.orderDate),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} articles',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.totalAmount.toStringAsFixed(2)} DT',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber[800]),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'assigned_to_point':
        return Colors.purple;
      case 'assigned_to_driver':
        return Colors.green;
      case 'delivered':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'assigned_to_point':
        return 'Au point';
      case 'assigned_to_driver':
        return 'En livraison';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }

  void _showAssignTopMlawiDialog(BuildContext context, Commande order) {
    showDialog(
      context: context,
      builder: (context) => AssignTopMlawiDialog(order: order),
    );
  }

  void _showAssignLivreurDialog(BuildContext context, Commande order) {
    showDialog(
      context: context,
      builder: (context) => AssignLivreurDialog(order: order),
    );
  }
}
