import 'package:flutter/material.dart';
import 'livreurs_management_tab.dart';
import 'users_management_tab.dart';
import 'products_management_tab.dart';
import 'orders_management_tab.dart';
import 'collaborators_management_tab.dart'; // Importez le nouveau fichier

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Mettez à jour la longueur à 5
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion'),
          automaticallyImplyLeading: false,
          // Rendre la TabBar scrollable pour une meilleure visibilité sur les petits écrans
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Commandes'),
              Tab(text: 'Plats'),
              Tab(text: 'Utilisateurs'),
              Tab(text: 'Livreurs'),
              Tab(text: 'Collaborateurs'), // Nouvel onglet
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersManagementTab(),
            ProductsManagementTab(),
            UsersManagementTab(),
            LivreursManagementTab(),
            CollaboratorsManagementTab(), // Ajoutez la nouvelle vue ici
          ],
        ),
      ),
    );
  }
}
