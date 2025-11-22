import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/top_mlawi_service.dart';
import 'package:projet_best_mlewi/service/livreur_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart';
import 'package:projet_best_mlewi/model/livreur.dart';

class AssignTopMlawiDialog extends StatelessWidget {
  final Commande order;

  const AssignTopMlawiDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final topMlawiService = Provider.of<TopMlawiService>(context);

    return AlertDialog(
      title: const Text('Affecter à un TopMlawi'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<TopMlawi>>(
          stream: topMlawiService.getAvailableTopMlawi(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final points = snapshot.data ?? [];

            if (points.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 48, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Aucun TopMlawi disponible'),
                ],
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: points.length,
              itemBuilder: (context, index) {
                final point = points[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: point.hasCapacity ? Colors.green : Colors.red,
                    child: const Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text(point.name),
                  subtitle: Text(
                    '${point.address}\nCapacité: ${point.currentCapacity}/${point.maxCapacity}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: point.hasCapacity
                        ? () async {
                            await topMlawiService.assignOrderToTopMlawi(order.id!, point.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Commande affectée à ${point.name}')),
                              );
                            }
                          }
                        : null,
                    child: const Text('Affecter'),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

class AssignLivreurDialog extends StatelessWidget {
  final Commande order;

  const AssignLivreurDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final livreurService = Provider.of<LivreurService>(context);

    return AlertDialog(
      title: const Text('Affecter à un Livreur'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<List<Livreur>>(
          stream: livreurService.getAvailableLivreurs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final livreurs = snapshot.data ?? [];

            if (livreurs.isEmpty) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 48, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Aucun livreur disponible'),
                ],
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: livreurs.length,
              itemBuilder: (context, index) {
                final livreur = livreurs[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: livreur.canTakeOrder ? Colors.green : Colors.orange,
                    child: const Icon(Icons.delivery_dining, color: Colors.white),
                  ),
                  title: Text(livreur.name),
                  subtitle: Text(
                    '${livreur.phone}\nCommandes actives: ${livreur.activeOrders}',
                  ),
                  trailing: ElevatedButton(
                    onPressed: livreur.canTakeOrder
                        ? () async {
                            await livreurService.assignOrderToLivreur(order.id!, livreur.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Commande affectée à ${livreur.name}')),
                              );
                            }
                          }
                        : null,
                    child: const Text('Affecter'),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}
