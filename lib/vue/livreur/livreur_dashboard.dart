import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:intl/intl.dart';

class LivreurDashboard extends StatefulWidget {
  const LivreurDashboard({super.key});

  @override
  State<LivreurDashboard> createState() => _LivreurDashboardState();
}

class _LivreurDashboardState extends State<LivreurDashboard> {
  // Simulate location update
  void _simulateLocationUpdate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Position GPS mise à jour envoyée au gérant')),
    );
    // In a real app, this would call LivreurService.updateLocation
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final orderService = Provider.of<OrderService>(context);
    final currentUserId = authService.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text('Non connecté')));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord Livreur'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'En cours', icon: Icon(Icons.motorcycle)),
              Tab(text: 'Historique', icon: Icon(Icons.history)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.gps_fixed),
              tooltip: 'Mettre à jour ma position',
              onPressed: _simulateLocationUpdate,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
        body: StreamBuilder<List<Commande>>(
          stream: orderService.getOrdersByLivreur(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            final allOrders = snapshot.data ?? [];
            
            // Filter orders
            final activeOrders = allOrders.where((order) => 
              ['assigned_to_driver', 'delivering'].contains(order.status.toLowerCase())
            ).toList();

            final historyOrders = allOrders.where((order) => 
              ['delivered', 'cancelled'].contains(order.status.toLowerCase())
            ).toList();

            // Calculate stats
            final deliveredToday = historyOrders.where((order) {
              if (order.deliveredAt == null) return false;
              return order.status.toLowerCase() == 'delivered';
            }).length;

            // Simple earnings calculation (e.g., 5 TND per delivery)
            final earnings = deliveredToday * 5.0;

            return TabBarView(
              children: [
                _buildActiveOrdersTab(context, activeOrders, orderService, deliveredToday, earnings),
                _buildHistoryTab(context, historyOrders),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveOrdersTab(BuildContext context, List<Commande> orders, OrderService orderService, int deliveredCount, double earnings) {
    return Column(
      children: [
        _buildStatsCard(deliveredCount, earnings),
        Expanded(
          child: orders.isEmpty
              ? _buildEmptyState('Aucune commande en cours')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderCard(context, orders[index], orderService, isActive: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(BuildContext context, List<Commande> orders) {
    return orders.isEmpty
        ? _buildEmptyState('Aucun historique de commande')
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index], null, isActive: false);
            },
          );
  }

  Widget _buildStatsCard(int count, double earnings) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    count.toString(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const Text(
                    'Livraisons (Total)',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(height: 40, width: 1, color: Colors.grey[300]),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${earnings.toStringAsFixed(1)} TND',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const Text(
                    'Gains (Est.)',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.motorcycle, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Commande order, OrderService? orderService, {required bool isActive}) {
    final isDelivering = order.status.toLowerCase() == 'delivering';
    final isDelivered = order.status.toLowerCase() == 'delivered';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Commande #${order.id?.substring(0, 8) ?? "N/A"}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDelivered ? Colors.green : (isDelivering ? Colors.blue : Colors.orange),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDelivered ? 'Livrée' : (isDelivering ? 'En Livraison' : 'À Récupérer'),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person, '${order.clientFirstName} ${order.clientName}'),
            _buildInfoRow(Icons.phone, order.clientPhone),
            _buildInfoRow(Icons.location_on, order.clientAddress),
            const SizedBox(height: 16),
            const Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('- ${item['quantity']}x ${item['name']}'),
            )),
            
            if (isActive && orderService != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (isDelivering) {
                      final notificationService = Provider.of<NotificationService>(context, listen: false);
                      await orderService.markAsDelivered(order.id!, notificationService);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Commande livrée !')),
                        );
                      }
                    } else {
                      await orderService.markOrderPickedUp(order.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Commande récupérée, en route !')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDelivering ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(isDelivering ? Icons.check_circle : Icons.directions_run),
                  label: Text(
                    isDelivering ? 'Confirmer la Livraison' : 'Récupérer la Commande',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            
            if (!isActive) ...[
              const SizedBox(height: 16),
              Text(
                'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)}',
                style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
