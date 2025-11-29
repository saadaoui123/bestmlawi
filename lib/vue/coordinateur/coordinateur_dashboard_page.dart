import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/service/coordinateur_service.dart';
import 'package:provider/provider.dart';

class CoordinateurDashboardPage extends StatefulWidget {
  const CoordinateurDashboardPage({super.key});

  @override
  State<CoordinateurDashboardPage> createState() => _CoordinateurDashboardPageState();
}

class _CoordinateurDashboardPageState extends State<CoordinateurDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentSnapshot> _getUserData(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coordinateurService = Provider.of<CoordinateurService>(context, listen: false);
    final user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Coordinateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _getUserData(user.uid),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text('Impossible de charger les informations du coordinateur.'));
          }

          final userData = userSnapshot.data!.data() as Map<String, dynamic>;
          final String? topMlawiId = userData['topMlawiId'];

          if (topMlawiId == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Votre compte n\'est associé à aucun point de vente. Veuillez contacter un administrateur.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Commandes à Gérer',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Commande>>(
                  stream: coordinateurService.getCommandesForTopMlawi(topMlawiId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Aucune commande à préparer.'),
                      );
                    }

                    final commandes = snapshot.data!;

                    return ListView.builder(
                      itemCount: commandes.length,
                      itemBuilder: (context, index) {
                        final commande = commandes[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text('Commande #${commande.id?.substring(0, 6) ?? 'N/A'}'),
                            subtitle: Text(
                              'Client: ${commande.clientName} ${commande.clientFirstName}\n'
                                  'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(commande.orderDate)}',
                            ),
                            trailing: Text(
                              _getStatusText(commande.status), // Utilisation d'un texte plus lisible
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(commande.status),
                              ),
                            ),
                            onTap: () {
                              _showUpdateStatusDialog(context, commande, coordinateurService);
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- MÉTHODES UTILITAIRES POUR L'AFFICHAGE ---
  String _getStatusText(String status) {
    switch(status.toLowerCase()) {
      case 'assigned_topmlawi':
        return 'Assignée';
      case 'preparing':
        return 'En Préparation';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'assigned_topmlawi':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // --- DIALOGUE DE MISE À JOUR AMÉLIORÉ ---
  void _showUpdateStatusDialog(BuildContext context, Commande commande, CoordinateurService service) {
    if (commande.id == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changer le statut de la commande #${commande.id!.substring(0, 6)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Option visible seulement si la commande n'est pas déjà en préparation
              if (commande.status != 'preparing')
                ListTile(
                  leading: const Icon(Icons.soup_kitchen_outlined),
                  title: const Text('Mettre en préparation'),
                  onTap: () {
                    service.marquerCommandeEnPreparation(commande.id!);
                    Navigator.of(context).pop();
                  },
                ),

              // Option toujours visible pour marquer comme prête
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('Prête pour la livraison'),
                onTap: () {
                  service.marquerCommandePretePourLivraison(commande.id!);
                  Navigator.of(context).pop();
                },
              ),

              const Divider(),

              // Annulation
              ListTile(
                leading: const Icon(Icons.cancel_outlined, color: Colors.red),
                title: const Text('Annuler la commande', style: TextStyle(color: Colors.red)),
                onTap: () {
                  service.annulerCommande(commande.id!);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
