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
      case '/admin/setup':
        return MaterialPageRoute(builder: (_) => const AdminSetupPage());
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
