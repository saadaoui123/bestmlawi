import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CollaborateurDashboardPage extends StatefulWidget {
  const CollaborateurDashboardPage({super.key});

  @override
  State<CollaborateurDashboardPage> createState() => _CollaborateurDashboardPageState();
}

class _CollaborateurDashboardPageState extends State<CollaborateurDashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour mettre à jour la disponibilité dans Firestore
  Future<void> _updateAvailability(bool isAvailable) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'isAvailable': isAvailable});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isAvailable
                  ? 'Vous êtes maintenant visible comme disponible.'
                  : 'Vous êtes maintenant invisible.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
        );
      }
    }
  }

  // Fonction pour se déconnecter
  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Collaborateur'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Impossible de charger vos informations.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String name = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          final bool isAvailable = userData['isAvailable'] ?? false;
          final String role = userData['role'] ?? 'collaborateur';

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: Icon(_getIconForRole(role), size: 50),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenue, $name',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rôle: ${role.toUpperCase()}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Je suis disponible',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Switch(
                            value: isAvailable,
                            onChanged: (newValue) {
                              _updateAvailability(newValue);
                            },
                            activeColor: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Activez ce bouton pour apparaître dans les listes de disponibilité.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForRole(String role) {
    switch (role) {
      case 'livreur':
        return Icons.delivery_dining;
      case 'coordinateur':
        return Icons.event_note;
      case 'collaborateur':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }
}
