import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/commande.dart'; // Corrected Import Commande model

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser; // Get current logged-in user

    return Column(
      children: [
        AppBar(
          title: const Text('Mes Livraisons'),
          automaticallyImplyLeading: false, // Hide back button as it's part of the main shell
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: currentUser != null
                ? _firestore
                    .collection('orders')
                    .where('userId', isEqualTo: currentUser.uid)
                    .orderBy('orderDate', descending: true)
                    .snapshots()
                : _firestore.collection('orders').orderBy('orderDate', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('Aucune commande trouvée.'));
              }

              final orders = snapshot.data!.docs.map((doc) => Commande.fromFirestore(doc)).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'MAL-${order.id!.substring(0, 8).toUpperCase()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Chip(
                                label: Text(order.status),
                                backgroundColor: order.status == 'Pending' ? Colors.orange[100] : Colors.green[100],
                                labelStyle: TextStyle(
                                  color: order.status == 'Pending' ? Colors.orange[800] : Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Client: ${order.clientName} ${order.clientFirstName}',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text('Adresse: ${order.clientAddress}', style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'Date: ${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year} ${order.orderDate.hour}:${order.orderDate.minute}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                // Navigate to Order Detail Page
                                Navigator.pushNamed(
                                  context,
                                  '/order_detail',
                                  arguments: order,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.amber[800],
                                side: BorderSide(color: Colors.amber[800]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Voir les détails'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
