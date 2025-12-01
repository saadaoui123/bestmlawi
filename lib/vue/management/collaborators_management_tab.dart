import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'add_collaborator_dialog.dart';
import 'edit_collaborator_dialog.dart'; // Importer le nouveau dialogue

class CollaboratorsManagementTab extends StatelessWidget {
  const CollaboratorsManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> collaboratorsStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', whereIn: ['collaborateur', 'livreur', 'coordinateur', 'manager', 'gerant']) // Ajout des managers/gérants
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
            padding: const EdgeInsets.only(bottom: 80), // Espace pour le FAB
            itemCount: collaborators.length,
            itemBuilder: (context, index) {
              final collaborator = collaborators[index];
              final data = collaborator.data() as Map<String, dynamic>;
              final String role = data['role'] ?? 'N/A';
              final String email = data['email'] ?? 'Email inconnu';
              final bool isCurrentUser = fb_auth.FirebaseAuth.instance.currentUser?.uid == collaborator.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(_getIconForRole(role), color: Theme.of(context).primaryColor),
                  title: Text('${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$email - ${role.toUpperCase()}'),
                  trailing: isCurrentUser
                      ? const Chip(label: Text('VOUS'), backgroundColor: Colors.grey)
                      : PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(context, collaborator);
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, collaborator.id, email);
                      } else {
                        _updateRole(context, collaborator.id, value);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      // --- Modifier ---
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(leading: Icon(Icons.edit), title: Text('Modifier')),
                      ),
                      const PopupMenuDivider(),
                      // --- Changer le rôle ---
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
                      const PopupMenuItem<String>(
                        value: 'gerant',
                        child: Text('Définir comme Gérant'),
                      ),
                      const PopupMenuDivider(),
                      // --- Supprimer ---
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Supprimer', style: TextStyle(color: Colors.red)),
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

  IconData _getIconForRole(String role) {
    switch (role) {
      case 'livreur':
        return Icons.delivery_dining;
      case 'coordinateur':
        return Icons.event_note;
      case 'collaborateur':
        return Icons.person;
      case 'gerant':
      case 'manager':
        return Icons.manage_accounts;
      default:
        return Icons.person_outline;
    }
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot collaborator) {
    showDialog(
      context: context,
      builder: (context) => EditCollaboratorDialog(collaborator: collaborator),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String uid, String email) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Voulez-vous vraiment supprimer le collaborateur avec l\'email "$email" ?\n\nCette action est irréversible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Supprimer'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue de confirmation
                _deleteCollaborator(context, uid);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteCollaborator(BuildContext context, String uid) async {
    // Attention : cette fonction supprime uniquement le document Firestore.
    // La suppression du compte d'authentification est une opération sensible
    // qui nécessite des privilèges élevés (Cloud Function).
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collaborateur supprimé de la base de données.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
    }
  }

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
