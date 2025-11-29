import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'add_collaborator_dialog.dart'; // Nous allons créer ce dialogue juste après

class CollaboratorsManagementTab extends StatelessWidget {
  const CollaboratorsManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream pour récupérer les utilisateurs qui sont des collaborateurs (pas des clients)
    final Stream<QuerySnapshot> collaboratorsStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', whereIn: ['collaborateur', 'livreur', 'coordinateur'])
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: collaboratorsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun collaborateur trouvé.'));
          }

          final collaborators = snapshot.data!.docs;

          return ListView.builder(
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index];
              final data = collaborator.data() as Map<String, dynamic>;
              final String role = data['role'] ?? 'N/A';
              final String email = data['email'] ?? 'Email inconnu';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(_getIconForRole(role)),
                  title: Text('${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'),
                  subtitle: Text('$email - ${role.toUpperCase()}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      _updateRole(context, collaborator.id, value);
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'collaborateur',
                        child: Text('Définir comme Collaborateur'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'livreur',
                        child: Text('Définir comme Livreur'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'coordinateur',
                        child: Text('Définir comme Coordinateur'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const AddCollaboratorDialog();
            },
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un collaborateur',
      ),
    );
  }

  // Helper pour afficher une icône selon le rôle
  IconData _getIconForRole(String role) {
    switch (role) {
      case 'livreur':
        return Icons.delivery_dining;
      case 'coordinateur':
        return Icons.event_note;
      case 'collaborateur':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  // Mettre à jour le rôle dans Firestore
  Future<void> _updateRole(BuildContext context, String uid, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rôle mis à jour avec succès vers $newRole.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du rôle: $e')),
      );
    }
  }
}

