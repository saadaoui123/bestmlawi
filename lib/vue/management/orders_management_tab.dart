import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:intl/intl.dart';
import 'package:projet_best_mlewi/vue/management/assign_dialogs.dart';
import 'order_detail_page.dart';
import 'package:projet_best_mlewi/utils/status_utils.dart'; // IMPORTANT : Importer

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
            allOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

            // CORRIGÉ : Filtrage avec les constantes
            final pendingOrders = allOrders.where((o) =>
                [OrderStatus.pending, OrderStatus.confirmed].contains(o.status.toLowerCase())
            ).toList();

            final activeOrders = allOrders.where((o) =>
                [
                  OrderStatus.assignedToPoint,
                  OrderStatus.assignedToDriver,
                  OrderStatus.preparing,
                  OrderStatus.readyForDelivery,
                  OrderStatus.delivering
                ].contains(o.status.toLowerCase())
            ).toList();

            final historyOrders = allOrders.where((o) =>
                [OrderStatus.delivered, OrderStatus.cancelled].contains(o.status.toLowerCase())
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
            const Text('Aucune commande dans cette catégorie', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) => _buildOrderCard(context, orders[index]),
    );
  }

  Widget _buildOrderCard(BuildContext context, Commande order) {
    final orderService = Provider.of<OrderService>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ManagementOrderDetailPage(order: order)));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${order.id?.substring(0, 8) ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getStatusColor(order.status), // CORRIGÉ
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          getStatusText(order.status), // CORRIGÉ
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${order.clientFirstName} ${order.clientName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(DateFormat('dd/MM HH:mm').format(order.orderDate), style: const TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${order.items.length} articles', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${order.totalAmount.toStringAsFixed(2)} DT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 24),
            _buildActionButtons(context, order, orderService),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Commande order, OrderService orderService) {
    // CORRIGÉ : Utilise les constantes partout
    switch (order.status.toLowerCase()) {
      case OrderStatus.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check, size: 16),
              label: const Text('Confirmer'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => orderService.updateOrderStatus(order.id!, OrderStatus.confirmed),
            ),
            TextButton.icon(
              icon: const Icon(Icons.cancel, size: 16),
              label: const Text('Annuler'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => orderService.updateOrderStatus(order.id!, OrderStatus.cancelled),
            ),
          ],
        );
      case OrderStatus.confirmed:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.store, size: 16),
              label: const Text('Assigner (Point)'),
              onPressed: () => _showAssignTopMlawiDialog(context, order),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.delivery_dining, size: 16),
              label: const Text('Assigner (Livreur)'),
              onPressed: () => _showAssignLivreurDialog(context, order),
            ),
          ],
        );
      case OrderStatus.readyForDelivery:
        return Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delivery_dining, size: 16),
            label: const Text('Assigner un Livreur'),
            onPressed: () => _showAssignLivreurDialog(context, order),
          ),
        );
      default:
        return const Center(child: Text('Aucune action requise', style: TextStyle(color: Colors.grey)));
    }
  }

  // SUPPRIMÉ : Ces fonctions sont maintenant dans status_utils.dart
  // Color _getStatusColor(String status) { ... }
  // String _getStatusText(String status) { ... }

  void _showAssignTopMlawiDialog(BuildContext context, Commande order) {
    showDialog(context: context, builder: (context) => AssignTopMlawiDialog(order: order));
  }

  void _showAssignLivreurDialog(BuildContext context, Commande order) {
    showDialog(context: context, builder: (context) => AssignLivreurDialog(order: order));
  }
}
