// lib/vue/management/management_page.dart
import 'package:flutter/material.dart';
import 'livreurs_management_tab.dart';
import 'users_management_tab.dart';
import 'products_management_tab.dart';
import 'orders_management_tab.dart';
import 'collaborators_management_tab.dart';
// --- DÉBUT DE L'AJOUT ---
import 'top_mlawi_management_tab.dart'; // Importer le nouvel onglet
// --- FIN DE L'AJOUT ---

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // --- MODIFIÉ : Mettre à jour la longueur à 6 ---
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Commandes'),
              Tab(text: 'Plats'),
              Tab(text: 'Utilisateurs'),
              Tab(text: 'Livreurs'),
              Tab(text: 'Collaborateurs'),
              Tab(text: 'Points de Vente'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrdersManagementTab(),
            ProductsManagementTab(),
            UsersManagementTab(),
            LivreursManagementTab(),
            CollaboratorsManagementTab(),
            TopMlawiManagementTab(),
          ],
        ),
      ),
    );
  }
}
