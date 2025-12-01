// lib/vue/management/top_mlawi_management_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart';
import 'package:projet_best_mlewi/service/top_mlawi_service.dart';
import 'add_edit_top_mlawi_dialog.dart'; // Nous allons créer ce fichier juste après

class TopMlawiManagementTab extends StatelessWidget {
  const TopMlawiManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final topMlawiService = Provider.of<TopMlawiService>(context, listen: false);

    return Scaffold(
      body: StreamBuilder<List<TopMlawi>>(
        stream: topMlawiService.getAllTopMlawi(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun point de vente trouvé.'));
          }

          final points = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Espace pour le FAB
            itemCount: points.length,
            itemBuilder: (context, index) {
              final point = points[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.store, color: Theme.of(context).primaryColor),
                  title: Text(point.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${point.address}\nCapacité: ${point.currentCapacity}/${point.maxCapacity}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddEditDialog(context, point: point),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteConfirmation(context, point),
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
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un point de vente',
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {TopMlawi? point}) {
    showDialog(
      context: context,
      builder: (_) => AddEditTopMlawiDialog(topMlawi: point),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TopMlawi point) {
    final topMlawiService = Provider.of<TopMlawiService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le point de vente "${point.name}" ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
            onPressed: () {
              topMlawiService.deleteTopMlawi(point.id);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
