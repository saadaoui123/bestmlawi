import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:projet_best_mlewi/model/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final notificationService = Provider.of<NotificationService>(context);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Veuillez vous connecter pour voir vos notifications')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tout marquer comme lu',
            onPressed: () => notificationService.markAllAsRead(currentUser.uid),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: notificationService.getUserNotifications(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.read ? Colors.grey[300] : Theme.of(context).primaryColor.withOpacity(0.2),
                  child: Icon(
                    _getIconForType(notification.type),
                    color: notification.read ? Colors.grey : Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM HH:mm').format(notification.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                tileColor: notification.read ? null : Theme.of(context).primaryColor.withOpacity(0.05),
                onTap: () {
                  if (!notification.read) {
                    notificationService.markAsRead(notification.id!);
                  }
                  // Navigate based on type if needed
                  // if (notification.type == 'order_assigned') ...
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order_assigned':
        return Icons.motorcycle;
      case 'status_change':
        return Icons.info;
      case 'new_order':
        return Icons.receipt_long;
      default:
        return Icons.notifications;
    }
  }
}
