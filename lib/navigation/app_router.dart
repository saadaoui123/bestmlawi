import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/vue/authentification/login.page.dart';
import 'package:projet_best_mlewi/vue/authentification/register.page.dart';
import 'package:projet_best_mlewi/vue/app_shell.dart';
import 'package:projet_best_mlewi/vue/management/management_page.dart';
import 'package:projet_best_mlewi/navigation/manager_guard.dart';
import 'package:projet_best_mlewi/vue/livreur/livreur_dashboard.dart';

import '../vue/collaborateur/collaborateur_dashboard_page.dart';
import '../vue/coordinateur/coordinateur_dashboard_page.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(String routeName, {TO? result, Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed<T, TO>(routeName, arguments: arguments);
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(String newRouteName, RoutePredicate predicate, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil<T>(newRouteName, predicate, arguments: arguments);
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home':
        return MaterialPageRoute(builder: (_) => const AppShell());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case '/management':
        return MaterialPageRoute(builder: (_) => const ManagerGuard(child: ManagementPage()));
      case '/livreur_dashboard':
        return MaterialPageRoute(builder: (_) => const LivreurDashboard());

      case '/collaborateur_dashboard': // Nouvelle route
        return MaterialPageRoute(builder: (_) => const CollaborateurDashboardPage());

      case '/coordinateur_dashboard': // Nouvelle route
        return MaterialPageRoute(builder: (_) => const CoordinateurDashboardPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
