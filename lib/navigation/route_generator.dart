import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/vue/app_shell.dart';
import 'package:projet_best_mlewi/vue/authentification/login.page.dart';
import 'package:projet_best_mlewi/vue/authentification/register.page.dart';
import 'package:projet_best_mlewi/vue/cart/cart_page.dart';
import 'package:projet_best_mlewi/vue/checkout/checkout_page.dart';
import 'package:projet_best_mlewi/vue/profile/profile_page.dart';
import 'package:projet_best_mlewi/vue/blog/blog_list_page.dart';
import 'package:projet_best_mlewi/vue/blog/blog_detail_page.dart';
import 'package:projet_best_mlewi/vue/admin/admin_setup_page.dart';
import 'package:projet_best_mlewi/service/blog_service.dart';
import 'package:projet_best_mlewi/vue/livreur/livreur_dashboard.dart';
import 'package:projet_best_mlewi/vue/product_detail/product_detail_page.dart';
import 'package:projet_best_mlewi/vue/orders/order_detail_page.dart';
import 'package:projet_best_mlewi/vue/profile/edit_profile_page.dart';
import 'package:projet_best_mlewi/vue/profile/addresses_page.dart';
import 'package:projet_best_mlewi/vue/profile/settings_page.dart';
import 'package:projet_best_mlewi/vue/profile/help_support_page.dart';
import 'package:projet_best_mlewi/vue/notifications/notification_page.dart';
import 'package:projet_best_mlewi/model/commande.dart';

import '../vue/collaborateur/collaborateur_dashboard_page.dart';
import '../vue/coordinateur/coordinateur_dashboard_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AppShell());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/cart':
        return MaterialPageRoute(builder: (_) => const CartPage());
      case '/checkout':
        return MaterialPageRoute(builder: (_) => const CheckoutPage());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/blog':
        return MaterialPageRoute(builder: (_) => const BlogListPage());
      case '/blog/detail':
        if (args is BlogPost) {
          return MaterialPageRoute(builder: (_) => BlogDetailPage(post: args));
        }
        return _errorRoute();
      case '/management':
        return MaterialPageRoute(builder: (_) => const AppShell());
      case '/livreur_dashboard':
        return MaterialPageRoute(builder: (_) => const LivreurDashboard());

      case '/collaborateur_dashboard': // Nouvelle route
        return MaterialPageRoute(builder: (_) => const CollaborateurDashboardPage());

      case '/coordinateur_dashboard': // Nouvelle route
        return MaterialPageRoute(builder: (_) => const CoordinateurDashboardPage());
      case '/admin/setup':
        return MaterialPageRoute(builder: (_) => const AdminSetupPage());
      case '/product_detail':
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(builder: (_) => ProductDetailPage(product: args));
        }
        return _errorRoute();
      case '/order_detail':
        if (args is Commande) {
          return MaterialPageRoute(builder: (_) => OrderDetailPage(order: args));
        }
        return _errorRoute();
      case '/profile/edit':
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case '/profile/addresses':
        return MaterialPageRoute(builder: (_) => const AddressesPage());
      case '/profile/settings':
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case '/profile/help':
        return MaterialPageRoute(builder: (_) => const HelpSupportPage());
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Page non trouvée')),
      );
    });
  }
}
