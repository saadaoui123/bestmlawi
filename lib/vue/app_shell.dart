import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projet_best_mlewi/service/cart_service.dart';
import 'package:projet_best_mlewi/service/settings_service.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/navigation/app_router.dart';
import 'package:projet_best_mlewi/navigation/nested_navigator.dart';
import 'package:projet_best_mlewi/vue/home/home_content_page.dart';
import 'package:projet_best_mlewi/vue/orders/orders_page.dart';
import 'package:projet_best_mlewi/vue/map/map_page.dart';
import 'package:projet_best_mlewi/vue/management/management_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  PageController? _pageController;
  bool _isManager = false;

  final List<Widget> _clientPages = <Widget>[
    const HomeContentPage(),
    const OrdersPage(),
    const MapPage(),
  ];

  final List<Widget> _managerPages = <Widget>[
    const HomeContentPage(),
    const OrdersPage(),
    const MapPage(),
    const ManagementPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final authService = AuthService();
    final isManager = await authService.isManager();
    
    // TEMPORARY: Force show management tab for debugging
    setState(() {
      _isManager = true; // Force to true for testing
      _selectedIndex = 0; // Start on home
      _pageController = PageController(initialPage: 0);
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
    final mainPages = _isManager ? _managerPages : _clientPages;

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
