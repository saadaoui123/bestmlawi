import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:intl/intl.dart';

// --- DÉBUT DES AJOUTS ---
// Importer le fichier centralisé pour les statuts
import 'package:projet_best_mlewi/utils/status_utils.dart';
// Importer la page de détail pour une navigation propre
import 'package:projet_best_mlewi/vue/orders/order_detail_page.dart';
// --- FIN DES AJOUTS ---

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  // Plus besoin de _auth ou _firestore ici, on passe par le service centralisé

  @override
  Widget build(BuildContext context) {
    // On utilise Provider pour accéder au service, c'est plus propre et efficace
    final orderService = Provider.of<OrderService>(context);

    // On utilise un Scaffold pour avoir une structure de page standard
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Commandes'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Cache le bouton retour
      ),
      body: StreamBuilder<List<Commande>>(
        // Le stream vient maintenant du service, qui gère la logique de l'utilisateur
        stream: orderService.getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Vous n\'avez pas encore de commande.', style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          // Le service trie déjà les commandes, pas besoin de le refaire ici
          final orders = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // --- CORRECTION : Navigation directe vers le widget de détail ---
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OrderDetailPage(order: order),
                    ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Commande #${order.id!.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            // --- CORRECTION MAJEURE : Utilisation de status_utils.dart ---
                            Chip(
                              label: Text(getStatusText(order.status)),
                              backgroundColor: getStatusColor(order.status).withOpacity(0.2),
                              labelStyle: TextStyle(
                                color: getStatusColor(order.status),
                                fontWeight: FontWeight.bold,
                              ),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date', style: TextStyle(color: Colors.grey)),
                                // Utilisation du package intl pour un formatage propre
                                Text(DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Total', style: TextStyle(color: Colors.grey)),
                                Text(
                                  // Utilisation de totalPrice qui est plus correct pour le client
                                  '${order.totalPrice.toStringAsFixed(2)} DT',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Le bouton "Voir les détails" est supprimé car la carte entière est cliquable
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
