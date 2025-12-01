// C:/Users/DELL/AndroidStudioProjects/projet_best_mlewi/lib/vue/management/assign_dialogs.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/service/order_service.dart'; // Service principal pour les actions
import 'package:projet_best_mlewi/service/notification_service.dart'; // Pour les notifications
import 'package:projet_best_mlewi/model/commande.dart';

// --- DÉBUT DES MODIFICATIONS ---
// Importer le service et le modèle pour TopMlawi
import 'package:projet_best_mlewi/service/top_mlawi_service.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart';
// --- FIN DES MODIFICATIONS ---

// --- DIALOGUE POUR ASSIGNER UN POINT DE VENTE ---
class AssignTopMlawiDialog extends StatelessWidget {
  final Commande order;
  const AssignTopMlawiDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // On utilise OrderService pour l'action d'assignation
    final orderService = Provider.of<OrderService>(context, listen: false);
    // --- MODIFIÉ : On utilise TopMlawiService pour charger les données ---
    final topMlawiService = Provider.of<TopMlawiService>(context, listen: false);

    return AlertDialog(
      title: const Text('Assigner à un Point de Vente'),
      content: SizedBox(
        width: double.maxFinite,
        // --- MODIFIÉ : Le StreamBuilder utilise maintenant TopMlawiService ---
        child: StreamBuilder<List<TopMlawi>>(
          // On appelle la méthode de TopMlawiService
          stream: topMlawiService.getAllTopMlawi(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Erreur de chargement: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucun point de vente trouvé.'));
            }
            // --- MODIFIÉ : On travaille avec une liste d'objets TopMlawi ---
            final points = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: points.length,
              itemBuilder: (context, index) {
                final point = points[index];
                return ListTile(
                  leading: const Icon(Icons.store, color: Colors.blue),
                  // On utilise les propriétés du modèle TopMlawi
                  title: Text(point.name),
                  subtitle: Text(point.address),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // L'action d'assignation reste dans OrderService, ce qui est correct
                      orderService.assignToTopMlawi(order.id!, point.id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Commande assignée à ${point.name}')),
                      );
                    },
                    child: const Text('Assigner'),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
      ],
    );
  }
}

// --- DIALOGUE POUR ASSIGNER UN LIVREUR ---
// (Cette partie reste inchangée et est déjà correcte)
class AssignLivreurDialog extends StatelessWidget {
  final Commande order;
  const AssignLivreurDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    return AlertDialog(
      title: const Text('Affecter à un Livreur'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: orderService.getLivreurs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Aucun livreur trouvé.'));
            }
            final livreurs = snapshot.data!.docs;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: livreurs.length,
              itemBuilder: (context, index) {
                final livreur = livreurs[index];
                final data = livreur.data() as Map<String, dynamic>;

                final nom = "${data['lastName'] ?? ''} ${data['firstName'] ?? ''}".trim();
                final isAvailable = data['isAvailable'] ?? false;
                final activeOrders = data['activeOrders'] ?? 0;
                final canTakeOrder = isAvailable;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: canTakeOrder ? Colors.green : Colors.grey,
                    child: const Icon(Icons.delivery_dining, color: Colors.white),
                  ),
                  title: Text(nom.isEmpty ? 'Livreur sans nom' : nom),
                  subtitle: Text('Commandes actives: $activeOrders'),
                  trailing: ElevatedButton(
                    onPressed: canTakeOrder
                        ? () {
                      orderService.assignToLivreur(order.id!, livreur.id, notificationService);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Commande assignée à $nom')),
                      );
                    }
                        : null,
                    child: const Text('Assigner'),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
      ],
    );
  }
}
