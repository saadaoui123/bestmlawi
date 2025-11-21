import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_best_mlewi/vue/authentification/login.page.dart';
import 'package:projet_best_mlewi/vue/authentification/register.page.dart';
import 'package:projet_best_mlewi/vue/profile/profile_page.dart';
import 'package:projet_best_mlewi/vue/cart/cart_page.dart';
import 'package:projet_best_mlewi/vue/product_detail/product_detail_page.dart';
import 'package:projet_best_mlewi/vue/orders/orders_page.dart';
import 'package:projet_best_mlewi/vue/map/map_page.dart';
import 'package:projet_best_mlewi/vue/management/management_page.dart';
import 'package:projet_best_mlewi/vue/home/home_content_page.dart'; // Import HomeContentPage

// Renommons l'ancienne HomePage en AppShell pour encapsuler la navigation principale
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0; // Gère l'onglet sélectionné
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Toutes les pages principales gérées par la BottomNavigationBar
  final List<Widget> _mainPages = <Widget>[
    const HomeContentPage(), // Utilise HomeContentPage pour le contenu de l'accueil
    const OrdersPage(),
    const MapPage(),
    const ManagementPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BESTMLAWI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Gérer l'icône de notification
            },
          ),
          StreamBuilder<User?>( // Écoute les changements d'état d'authentification
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // L'utilisateur est connecté, afficher l'avatar de profil
                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/user_avatar.png'), // Avatar de l'utilisateur
                    ),
                  ),
                );
              } else {
                // L'utilisateur n'est pas connecté, afficher les options de connexion/inscription
                return Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Se connecter', style: TextStyle(color: Colors.black)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('S\'inscrire', style: TextStyle(color: Colors.black)), // Corrected: escape apostrophe
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _mainPages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Commandes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Carte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Gestion',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
