import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/service/livreur_service.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/model/livreur.dart';
import 'package:intl/intl.dart';
import 'package:projet_best_mlewi/vue/management/assign_dialogs.dart';

class ManagementOrderDetailPage extends StatelessWidget {
  final Commande order;

  const ManagementOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Commande #${order.id?.substring(0, 8) ?? "N/A"}'),
        elevation: 0,
      ),
      body: StreamBuilder<Commande>(
        stream: orderService.getOrderStream(order.id!),
        initialData: order,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentOrder = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(currentOrder),
                const SizedBox(height: 16),
                _buildClientInfoCard(currentOrder),
                const SizedBox(height: 16),
                _buildOrderItemsCard(currentOrder),
                const SizedBox(height: 16),
                _buildPaymentInfoCard(currentOrder),
                const SizedBox(height: 16),
                _buildAssignmentCard(context, currentOrder),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(Commande order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'État de la commande',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('dd MMM yyyy, HH:mm').format(order.orderDate),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(Commande order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Informations Client',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Nom', '${order.clientFirstName} ${order.clientName}'),
            _buildInfoRow('Téléphone', order.clientPhone),
            _buildInfoRow('Adresse', order.clientAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(Commande order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Articles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item['image'] != null
                        ? Image.network(
                            item['image'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey[200], width: 50, height: 50),
                          )
                        : Container(color: Colors.grey[200], width: 50, height: 50),
                  ),
                  title: Text(item['name'] ?? 'Produit'),
                  subtitle: Text('${item['price']} DT x ${item['quantity']}'),
                  trailing: Text(
                    '${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(2)} DT',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard(Commande order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.payment, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Paiement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  '${order.totalAmount.toStringAsFixed(2)} DT',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Commande order) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_ind, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Affectation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (order.livreurId != null)
              FutureBuilder<Livreur?>(
                future: Provider.of<LivreurService>(context, listen: false).getLivreurById(order.livreurId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildInfoRow('Livreur', 'Chargement...');
                  }
                  final livreurName = snapshot.data?.nom ?? 'ID: ${order.livreurId}';
                  return _buildInfoRow('Livreur', livreurName);
                },
              )
            else if (order.topMlawiId != null)
              _buildInfoRow('TopMlawi', 'ID: ${order.topMlawiId}')
            else
              const Text('Non affectée', style: TextStyle(color: Colors.red)),
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAssignTopMlawiDialog(context, order),
                    icon: const Icon(Icons.store),
                    label: const Text('TopMlawi'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAssignLivreurDialog(context, order),
                    icon: const Icon(Icons.motorcycle),
                    label: const Text('Livreur'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
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
        return 'Au point de vente';
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
