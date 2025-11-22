import 'package:flutter/material.dart';
import 'livreurs_management_tab.dart';
import 'users_management_tab.dart';
import 'products_management_tab.dart';
import 'orders_management_tab.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion'),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Livreurs'),
              Tab(text: 'Utilisateurs'),
              Tab(text: 'Produits'),
              Tab(text: 'Commandes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            LivreursManagementTab(),
            UsersManagementTab(),
            ProductsManagementTab(),
            OrdersManagementTab(),
          ],
        ),
      ),
    );
  }
}
