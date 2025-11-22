import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Livreur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.gps_fixed),
            tooltip: 'Mettre à jour ma position',
            onPressed: _simulateLocationUpdate,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<Commande>>(
        stream: orderService.getAllOrders(), // Ideally filter by livreurId in query
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final allOrders = snapshot.data ?? [];
          // Client-side filtering for now as we don't have a specific query yet
          final myOrders = allOrders.where((order) => 
            order.livreurId == currentUserId && 
            ['assigned_to_driver', 'delivering'].contains(order.status.toLowerCase())
          ).toList();

          if (myOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.motorcycle, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune commande assignée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              final order = myOrders[index];
              return _buildOrderCard(context, order, orderService);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Commande order, OrderService orderService) {
    final isDelivering = order.status.toLowerCase() == 'delivering';

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
                Text(
                  'Commande #${order.id?.substring(0, 8) ?? "N/A"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDelivering ? Colors.blue : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDelivering ? 'En Livraison' : 'À Récupérer',
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
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (isDelivering) {
                    await orderService.markOrderDelivered(order.id!);
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
