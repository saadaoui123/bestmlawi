import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/vue/app_shell.dart';
import 'package:projet_best_mlewi/vue/authentification/login.page.dart';


import 'collaborateur/collaborateur_dashboard_page.dart';
import 'coordinateur/coordinateur_dashboard_page.dart';
import 'livreur/livreur_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder écoute les changements d'état d'authentification
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // En attente de la vérification
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Si l'utilisateur est connecté
        if (snapshot.hasData) {
          // On a un utilisateur, maintenant vérifions son rôle
          return RoleDispatcher(user: snapshot.data!);
        }

        // Si l'utilisateur n'est pas connecté
        return const LoginPage();
      },
    );
  }
}

class RoleDispatcher extends StatelessWidget {
  final User user;
  const RoleDispatcher({super.key, required this.user});

  Future<String> _getUserRole() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return doc.data()?['role'] ?? 'client';
    }
    // Si le document n'existe pas, on considère que c'est un client.
    return 'client';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        // En attente de la récupération du rôle
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          final role = snapshot.data!;
          // Redirige en fonction du rôle
          switch (role) {
            case 'manager':
            case 'gerant':
            case 'client': // Le client et le manager utilisent l'AppShell
              return const AppShell();
            case 'livreur':
              return const LivreurDashboard();
            case 'collaborateur':
              return const CollaborateurDashboardPage();
            case 'coordinateur':
              return const CoordinateurDashboardPage();
            default:
              return const AppShell(); // Fallback pour les clients
          }
        }

        // En cas d'erreur ou si pas de données, on va à la page de connexion
        return const LoginPage();
      },
    );
  }
}
