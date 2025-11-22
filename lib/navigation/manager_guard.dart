import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';

/// A widget that ensures only users with manager (gerant) role can access its child.
/// If the user is not a manager, a simple message is shown.
class ManagerGuard extends StatelessWidget {
  final Widget child;

  const ManagerGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isManager(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isManager = snapshot.data ?? false;
        if (isManager) {
          return child;
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Accès refusé')),
          body: const Center(
            child: Text('Vous n\'avez pas les droits nécessaires pour accéder à cette page.'),
          ),
        );
      },
    );
  }
}
