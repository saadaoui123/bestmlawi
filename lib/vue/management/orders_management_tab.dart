import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/service/top_mlawi_service.dart';
import 'package:projet_best_mlewi/service/livreur_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart';
import 'package:projet_best_mlewi/model/livreur.dart';
import 'package:intl/intl.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Commandes'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Commande>>(
        stream: orderService.getPendingOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune commande en attente',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Commande order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
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
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${order.items.length} article(s)'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${order.totalAmount.toStringAsFixed(2)} DT',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAssignTopMlawiDialog(context, order),
                    icon: const Icon(Icons.store),
                    label: const Text('Affecter TopMlawi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAssignLivreurDialog(context, order),
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Affecter Livreur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'assigned_to_point':
        return Colors.purple;
      case 'assigned_to_driver':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmée';
      case 'assigned_to_point':
        return 'Affectée au point';
      case 'assigned_to_driver':
        return 'Affectée au livreur';
      default:
        return status;
    }
  }

  void _showAssignTopMlawiDialog(BuildContext context, Commande order) {
    showDialog(
      context: context,
      builder: (context) => _AssignTopMlawiDialog(order: order),
    );
  }

  void _showAssignLivreurDialog(BuildContext context, Commande order) {
    showDialog(
      context: context,
      builder: (context) => _AssignLivreurDialog(order: order),
    );
  }
}

// Dialog for assigning to TopMlawi
class _AssignTopMlawiDialog extends StatelessWidget {
  final Commande order;

  const _AssignTopMlawiDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    final topMlawiService = Provider.of<TopMlawiService>(context);

    return AlertDialog(
      title: const Text('Affecter à un TopMlawi'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<TopMlawi>>(
          stream: topMlawiService.getAvailableTopMlawi(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final points = snapshot.data ?? [];

            if (points.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 48, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Aucun TopMlawi disponible'),
                ],
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: points.length,
              itemBuilder: (context, index) {
                final point = points[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: point.hasCapacity ? Colors.green : Colors.red,
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text(point.name),
                  subtitle: Text(
                    '${point.address}\nCapacité: ${point.currentCapacity}/${point.maxCapacity}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: point.hasCapacity
                        ? () async {
                            await topMlawiService.assignOrderToTopMlawi(order.id!, point.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Commande affectée à ${point.name}')),
                              );
                            }
                          }
                        : null,
                    child: const Text('Affecter'),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

// Dialog for assigning to Livreur
class _AssignLivreurDialog extends StatelessWidget {
  final Commande order;

  const _AssignLivreurDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    final livreurService = Provider.of<LivreurService>(context);

    return AlertDialog(
      title: const Text('Affecter à un Livreur'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<Livreur>>(
          stream: livreurService.getAvailableLivreurs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final livreurs = snapshot.data ?? [];

            if (livreurs.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 48, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Aucun livreur disponible'),
                ],
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: livreurs.length,
              itemBuilder: (context, index) {
                final livreur = livreurs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: livreur.canTakeOrder ? Colors.green : Colors.orange,
                    child: const Icon(Icons.delivery_dining, color: Colors.white),
                  ),
                  title: Text(livreur.name),
                  subtitle: Text(
                    '${livreur.phone}\nCommandes actives: ${livreur.activeOrders}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: livreur.canTakeOrder
                        ? () async {
                            await livreurService.assignOrderToLivreur(order.id!, livreur.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Commande affectée à ${livreur.name}')),
                              );
                            }
                          }
                        : null,
                    child: const Text('Affecter'),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
