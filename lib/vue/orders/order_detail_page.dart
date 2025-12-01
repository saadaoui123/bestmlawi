import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';

// Importer le fichier centralisé et les constantes de statut
import 'package:projet_best_mlewi/utils/status_utils.dart';

class OrderDetailPage extends StatefulWidget {
  final Commande order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {

  Future<void> _cancelOrder(BuildContext context, Commande currentOrder) async {
    final orderService = Provider.of<OrderService>(context, listen: false);

    // --- CORRECTION DE LA LOGIQUE D'ANNULATION ---
    // On vérifie de nouveau ici, par sécurité, avant d'envoyer la requête.
    if (currentOrder.status.toLowerCase() != OrderStatus.pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'annuler une commande qui n\'est plus en attente.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // --- FIN DE LA CORRECTION ---

    try {
      // On utilise la méthode centralisée du service avec le statut standard
      await orderService.updateOrderStatus(currentOrder.id!, OrderStatus.cancelled);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande annulée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Revenir à la liste
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'annulation : ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Commande'),
      ),
      body: StreamBuilder<Commande>(
        stream: orderService.getOrderStream(widget.order.id!),
        initialData: widget.order,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          final currentOrder = snapshot.data!;
          final status = currentOrder.status.toLowerCase();

          // --- CORRECTION MAJEURE ---
          // Déterminer si le bouton d'annulation doit être affiché.
          // La commande ne peut être annulée QUE si son statut est 'pending'.
          final canCancel = (status == OrderStatus.pending);
          // --- FIN DE LA CORRECTION MAJEURE ---

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commande #${currentOrder.id!.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  'Statut',
                  getStatusText(currentOrder.status),
                  getStatusColor(currentOrder.status),
                ),
                _buildDetailRow('Date de commande', DateFormat('dd/MM/yyyy HH:mm').format(currentOrder.orderDate)),
                const Divider(height: 32),
                const Text(
                  'Informations du Client',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Nom', '${currentOrder.clientName} ${currentOrder.clientFirstName}'),
                _buildDetailRow('Téléphone', currentOrder.clientPhone),
                _buildDetailRow('Adresse', currentOrder.clientAddress),
                const Divider(height: 32),
                const Text(
                  'Articles Commandés',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentOrder.items.length,
                  itemBuilder: (context, index) {
                    final item = currentOrder.items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['name']} x${item['quantity']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${((item['price'] as num) * (item['quantity'] as num)).toStringAsFixed(2)} DT',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(height: 32),
                _buildDetailRow('Total', '${currentOrder.totalPrice.toStringAsFixed(2)} DT', Colors.amber[800]),
                const SizedBox(height: 24),
                if (canCancel)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelOrder(context, currentOrder),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Annuler la commande', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
