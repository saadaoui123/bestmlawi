import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/user.service.dart';
import 'package:projet_best_mlewi/model/user.dart';

class UsersManagementTab extends StatelessWidget {
  const UsersManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    return Scaffold(
      body: StreamBuilder<List<User>>(
        stream: userService.getAllUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(user.nom?.substring(0, 1).toUpperCase() ?? 'U'),
                ),
                title: Text('${user.nom ?? ""} ${user.prenom ?? ""}'),
                subtitle: Text('${user.email}\nRôle: ${user.role ?? "client"}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (String newRole) {
                    if (user.id != null) {
                      userService.updateUserRole(user.id!, newRole);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'client',
                      child: Text('Client'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'manager',
                      child: Text('Manager'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'livreur',
                      child: Text('Livreur'),
                    ),
                  ],
                  icon: const Icon(Icons.edit),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement manual user creation if needed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('La création manuelle n\'est pas encore implémentée')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
