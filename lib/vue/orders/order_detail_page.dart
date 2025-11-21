import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/model/commande.dart'; // Corrected Import Commande model
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class OrderDetailPage extends StatefulWidget {
  final Commande order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Commande _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
  }

  Future<void> _cancelOrder() async {
    if (_currentOrder.status == 'En livraison') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d\'annuler une commande déjà en livraison.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(_currentOrder.id)
          .update({'status': 'Annulée'});

      setState(() {
        _currentOrder.status = 'Annulée'; // Update local state
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande annulée avec succès !')),
      );
      Navigator.pop(context); // Go back to orders list
    } catch (e) {
      print('Error cancelling order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'annulation de la commande: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la Commande'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commande #${_currentOrder.id!.substring(0, 8).toUpperCase()}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Statut', _currentOrder.status, _currentOrder.status == 'Pending' ? Colors.orange : (_currentOrder.status == 'Annulée' ? Colors.red : Colors.green)),
            _buildDetailRow('Date de commande', DateFormat('dd/MM/yyyy HH:mm').format(_currentOrder.orderDate)),
            const Divider(height: 32),
            const Text(
              'Informations du Client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Nom', '${_currentOrder.clientName} ${_currentOrder.clientFirstName}'),
            _buildDetailRow('Téléphone', _currentOrder.clientPhone),
            _buildDetailRow('Adresse', _currentOrder.clientAddress),
            const Divider(height: 32),
            const Text(
              'Articles Commandés',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentOrder.items.length,
              itemBuilder: (context, index) {
                final item = _currentOrder.items[index];
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
                        '${(item['price'] * item['quantity']).toStringAsFixed(2)} DT',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(height: 32),
            _buildDetailRow('Total (incl. frais de livraison)', '${_currentOrder.totalPrice.toStringAsFixed(2)} DT', Colors.amber[800]),
            const SizedBox(height: 24),
            if (_currentOrder.status != 'Annulée' && _currentOrder.status != 'Livrée' && _currentOrder.status != 'En livraison')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Annuler la commande', style: TextStyle(fontSize: 18)),
                ),
              ),
          ],
        ),
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
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
