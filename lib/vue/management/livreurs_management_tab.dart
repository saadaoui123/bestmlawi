import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LivreursManagementTab extends StatelessWidget {
  const LivreursManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Le Stream pointe maintenant vers la collection 'users' et filtre par rôle
    final Stream<QuerySnapshot> livreursStream = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'livreur')
        .snapshots();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: livreursStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun livreur trouvé'));
          }

          final livreurs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: livreurs.length,
            itemBuilder: (context, index) {
              final livreurDoc = livreurs[index];
              final data = livreurDoc.data() as Map<String, dynamic>;

              // Extraction des données du document utilisateur
              final String name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
              final String email = data['email'] ?? 'Email inconnu';
              final String phone = data['phone'] ?? 'Téléphone non fourni';
              final bool isAvailable = data['isAvailable'] ?? false; // Disponibilité du livreur

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.delivery_dining),
                  ),
                  title: Text(name),
                  subtitle: Text('$email\n$phone'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Dispo: '),
                      Switch(
                        value: isAvailable,
                        onChanged: (value) {
                          // Mettre à jour la disponibilité directement dans Firestore
                          _updateAvailability(context, livreurDoc.id, value);
                        },
                      ),
                      // Vous pouvez ajouter d'autres actions ici si nécessaire,
                      // comme la suppression ou la modification, en suivant le modèle
                      // de 'collaborators_management_tab.dart'
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Le bouton flottant n'est plus nécessaire ici car la création se fait
      // via l'onglet "Collaborateurs", qui assigne ensuite le rôle de livreur.
      // floatingActionButton: FloatingActionButton( ... ),
    );
  }

  // Fonction pour mettre à jour le statut de disponibilité dans Firestore
  Future<void> _updateAvailability(BuildContext context, String uid, bool isAvailable) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'isAvailable': isAvailable});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disponibilité mise à jour.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
      );
    }
  }
}
