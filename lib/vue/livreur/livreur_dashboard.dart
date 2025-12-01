import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:intl/intl.dart';
import 'package:projet_best_mlewi/vue/profile/profile_page.dart';
// IMPORTANT : Importer le fichier centralisé
import 'package:projet_best_mlewi/utils/status_utils.dart';

class LivreurDashboard extends StatefulWidget {
  const LivreurDashboard({super.key});

  @override
  State<LivreurDashboard> createState() => _LivreurDashboardState();
}

class _LivreurDashboardState extends State<LivreurDashboard> {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final orderService = Provider.of<OrderService>(context);
    final currentUserId = authService.currentUser?.uid;

    if (currentUserId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tableau de bord Livreur'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'En cours', icon: Icon(Icons.motorcycle)),
              Tab(text: 'Historique', icon: Icon(Icons.history)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Mon Profil',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Se déconnecter',
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              },
            ),
          ],
        ),
        // --- NOUVELLE STRUCTURE ---
        body: TabBarView(
          children: [
            // Onglet "En cours" avec son propre StreamBuilder
            _buildActiveOrdersTab(context, orderService, currentUserId),
            // Onglet "Historique" avec son propre StreamBuilder
            _buildHistoryTab(context, orderService, currentUserId),
          ],
        ),
      ),
    );
  }

  // Widget pour l'onglet "En cours"
  Widget _buildActiveOrdersTab(BuildContext context, OrderService orderService, String userId) {
    return StreamBuilder<List<Commande>>(
      // On utilise la nouvelle méthode optimisée
      stream: orderService.getLivreurActiveOrders(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur (vérifiez la console pour le lien d\'indexation):\n${snapshot.error}'));
        }
        final activeOrders = snapshot.data ?? [];
        if (activeOrders.isEmpty) {
          return _buildEmptyState('Aucune commande en cours');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: activeOrders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(context, activeOrders[index], orderService, isActive: true);
          },
        );
      },
    );
  }

  // Widget pour l'onglet "Historique"
  Widget _buildHistoryTab(BuildContext context, OrderService orderService, String userId) {
    return Column(
      children: [
        // Le StreamBuilder pour les stats est séparé pour plus de clarté
        _buildStatsCard(orderService, userId),
        Expanded(
          child: StreamBuilder<List<Commande>>(
            // On utilise la deuxième méthode optimisée
            stream: orderService.getLivreurHistoryOrders(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur (vérifiez la console pour le lien d\'indexation):\n${snapshot.error}'));
              }
              final historyOrders = snapshot.data ?? [];
              if (historyOrders.isEmpty) {
                return _buildEmptyState('Aucun historique de commande');
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: historyOrders.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(context, historyOrders[index], null, isActive: false);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Les Stats sont maintenant un widget à part entière avec son propre Stream
  Widget _buildStatsCard(OrderService orderService, String userId) {
    return StreamBuilder<List<Commande>>(
      stream: orderService.getLivreurHistoryOrders(userId),
      builder: (context, snapshot) {
        final totalDelivered = snapshot.data
            ?.where((o) => o.status == OrderStatus.delivered)
            .length ?? 0;
        final totalEarnings = totalDelivered * 5.0; // Exemple: 5 DT

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(totalDelivered.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                      const Text('Livraisons', textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      Text('${totalEarnings.toStringAsFixed(1)} TND', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                      const Text('Gains (Est.)', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Le reste des widgets (EmptyState, InfoRow, OrderCard) reste presque identique
  // mais utilise les fonctions centralisées getStatusText et getStatusColor
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Commande order, OrderService? orderService, {required bool isActive}) {
    // Utilisation des constantes et fonctions centralisées
    final status = order.status.toLowerCase();
    final statusColor = getStatusColor(status);
    final statusText = getStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('Commande #${order.id?.substring(0, 8) ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(Icons.person, '${order.clientFirstName} ${order.clientName}'),
            if (isActive) _buildInfoRow(Icons.phone, order.clientPhone),
            if (isActive) _buildInfoRow(Icons.location_on, order.clientAddress),
            if (!isActive)
              _buildInfoRow(
                status == OrderStatus.delivered ? Icons.event_available : Icons.cancel,
                'Terminée le: ${DateFormat('dd/MM/yyyy à HH:mm').format(order.updatedAt ?? order.orderDate)}',
                color: statusColor,
              ),
            const SizedBox(height: 16),
            const Text('Articles:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('- ${item['quantity']}x ${item['name']}'),
            )),
            if (isActive && orderService != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (status == OrderStatus.delivering) {
                      final notificationService = Provider.of<NotificationService>(context, listen: false);
                      await orderService.markAsDelivered(order.id!, notificationService);
                    } else { // status == assigned_to_driver
                      await orderService.markAsPickedUp(order.id!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == OrderStatus.delivering ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(status == OrderStatus.delivering ? Icons.check_circle_outline : Icons.directions_run),
                  label: Text(
                    status == OrderStatus.delivering ? 'Confirmer la Livraison' : 'Récupérer la Commande',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
