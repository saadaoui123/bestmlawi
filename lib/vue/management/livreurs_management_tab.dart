import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/livreur_service.dart';
import 'package:projet_best_mlewi/model/livreur.dart';
import 'edit_livreur_dialog.dart';

class LivreursManagementTab extends StatelessWidget {
  const LivreursManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final livreurService = Provider.of<LivreurService>(context);

    return Scaffold(
      body: StreamBuilder<List<Livreur>>(
        stream: livreurService.getAllLivreurs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final livreurs = snapshot.data ?? [];

          if (livreurs.isEmpty) {
            return const Center(child: Text('Aucun livreur trouvé'));
          }

          return ListView.builder(
            itemCount: livreurs.length,
            itemBuilder: (context, index) {
              final livreur = livreurs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: livreur.photoUrl != null ? NetworkImage(livreur.photoUrl!) : null,
                  child: livreur.photoUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(livreur.name),
                subtitle: Text('${livreur.phone}\nCommandes actives: ${livreur.activeOrders}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: livreur.isAvailable,
                      onChanged: (value) {
                        livreurService.updateLivreurStatus(livreur.id, value);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await showDialog<Livreur>(
                          context: context,
                          builder: (context) => EditLivreurDialog(livreur: livreur),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text('Voulez-vous vraiment supprimer ${livreur.name} ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  livreurService.deleteLivreur(livreur.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog<Livreur>(
            context: context,
            builder: (context) => const EditLivreurDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
