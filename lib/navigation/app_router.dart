import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/vue/auth/auth_wrapper.dart';
import 'package:projet_best_mlewi/vue/auth/login_page.dart';
import 'package:projet_best_mlewi/vue/auth/signup_page.dart';
import 'package:projet_best_mlewi/vue/home/home_page.dart';
import 'package:projet_best_mlewi/vue/management/management_page.dart';
import 'package:projet_best_mlewi/navigation/manager_guard.dart';
import 'package:projet_best_mlewi/vue/livreur/livreur_dashboard.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/management':
        return MaterialPageRoute(builder: (_) => const ManagerGuard(child: ManagementPage()));
      case '/livreur_dashboard':
        return MaterialPageRoute(builder: (_) => const LivreurDashboard());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
