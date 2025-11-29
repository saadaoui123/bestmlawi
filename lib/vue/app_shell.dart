import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_best_mlewi/service/cart_service.dart';import 'package:projet_best_mlewi/service/settings_service.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/navigation/app_router.dart';
import 'package:projet_best_mlewi/navigation/nested_navigator.dart';
import 'package:projet_best_mlewi/vue/home/home_content_page.dart';
import 'package:projet_best_mlewi/vue/orders/orders_page.dart';
import 'package:projet_best_mlewi/vue/map/map_page.dart';
import 'package:projet_best_mlewi/vue/management/management_page.dart';
// Importez votre page de connexion existante
import 'package:projet_best_mlewi/vue/authentification/login.page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  PageController? _pageController;
  bool _isManager = false;

  List<Widget> _buildClientPages(bool isUserLoggedIn, SettingsService settings) {
    return <Widget>[
      const HomeContentPage(),
      // Utilisation de la LoginPage si l'utilisateur n'est pas connecté
      isUserLoggedIn
          ? const OrdersPage()
      // Enveloppez LoginPage dans un Scaffold pour qu'elle s'affiche correctement dans le corps de l'AppShell
          : const Scaffold(body: LoginPage()),
      const MapPage(),
    ];
  }

  List<Widget> _buildManagerPages(SettingsService settings) {
    // Les managers sont toujours connectés pour accéder à cet onglet
    return <Widget>[
      const HomeContentPage(),
      const OrdersPage(),
      const MapPage(),
      const ManagementPage(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final authService = AuthService();
    final isManager = await authService.isManager();

    setState(() {
      _isManager = isManager;
      // Start on Management tab (index 3) for managers, Home tab (index 0) for clients
      _selectedIndex = isManager ? 3 : 0;
      _pageController = PageController(initialPage: isManager ? 3 : 0);
    });

    // Debug: Print role to console
    print('User is manager: $isManager');
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    // Si l'utilisateur n'est pas connecté et clique sur l'onglet "Commandes" (index 1),
    // on le redirige vers la page de connexion complète plutôt que de l'afficher dans l'onglet.
    final isUserLoggedIn = FirebaseAuth.instance.currentUser != null;
    if (!isUserLoggedIn && index == 1) {
      AppRouter.pushNamed('/login');
      return; // Empêche de changer l'onglet
    }

    setState(() {
      _selectedIndex = index;
      _pageController?.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final settings = Provider.of<SettingsService>(context);
    final l10n = settings.localizations;

    final isUserLoggedIn = FirebaseAuth.instance.currentUser != null;

    // Nous modifions légèrement la logique ici pour une meilleure redirection
    final List<Widget> clientPages = [
      const HomeContentPage(),
      // Si l'utilisateur est connecté, on montre la page des commandes.
      // Sinon, on met un conteneur vide. La redirection sera gérée dans _onItemTapped.
      isUserLoggedIn ? const OrdersPage() : Container(),
      const MapPage(),
    ];

    final mainPages = _isManager ? _buildManagerPages(settings) : clientPages;

    // Show loading while checking role
    if (_pageController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: GestureDetector(
          onTap: () => _onItemTapped(0),
          child: Text(
            'BESTMLAWI',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          // TEMPORARY: Admin Setup Button
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.orange),
            onPressed: () => Navigator.of(context).pushNamed('/admin/setup'),
            tooltip: 'Configuration Admin',
          ),
          // Notification Bell
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, authSnapshot) {
              if (!authSnapshot.hasData) return const SizedBox.shrink();

              final notificationService = Provider.of<NotificationService>(context);
              return StreamBuilder<int>(
                stream: notificationService.getUnreadCount(authSnapshot.data!.uid),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                        onPressed: () => Navigator.of(context).pushNamed('/notifications'),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                onPressed: () => Navigator.of(context).pushNamed('/cart'),
              ),
              if (cartService.totalItems > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartService.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return GestureDetector(
                  onTap: () => AppRouter.pushNamed('/profile'),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                    ),
                  ),
                );
              } else {
                return TextButton(
                  onPressed: () => AppRouter.pushNamed('/login'),
                  child: Text(l10n.login),
                );
              }
            },
          ),
        ],
      ),
      body: NestedNavigator(pageController: _pageController!, mainPages: mainPages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long),
              label: l10n.orders,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.map_outlined),
              activeIcon: const Icon(Icons.map),
              label: l10n.map,
            ),
            if (_isManager)
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings),
                label: l10n.management,
              ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        ),
      ),
    );
  }
}
