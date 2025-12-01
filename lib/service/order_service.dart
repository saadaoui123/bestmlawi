import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';
import 'package:projet_best_mlewi/utils/status_utils.dart'; // IMPORTANT : Importer le nouveau fichier

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- LECTURE DES COMMANDES ---

  /// Récupère un flux (stream) pour une seule commande (pour les pages de détail).
  Stream<Commande> getOrderStream(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception("La commande avec l'ID $orderId n'existe plus.");
      }
      return Commande.fromJson({
        ...doc.data()!,
        'id': doc.id,
      }); // <--- POINT-VIRGULE MANQUANT CORRIGÉ ICI
    });
  }

  /// Récupère toutes les commandes d'un utilisateur spécifique (client).
  Stream<List<Commande>> getUserOrders() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Commande.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    });
  }

  /// Récupère toutes les commandes pour la gestion (admin/manager).
  Stream<List<Commande>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Commande.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList();
    });
  }

  /// Optimisé : Récupère UNIQUEMENT les commandes actives pour un livreur.
  Stream<List<Commande>> getLivreurActiveOrders(String livreurId) {
    return _firestore
        .collection('orders')
        .where('livreurId', isEqualTo: livreurId)
        .where('status', whereIn: [OrderStatus.assignedToDriver, OrderStatus.delivering])
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Commande.fromJson({...doc.data()!, 'id': doc.id}))
        .toList());
  }

  /// Optimisé : Récupère UNIQUEMENT l'historique des commandes pour un livreur.
  Stream<List<Commande>> getLivreurHistoryOrders(String livreurId) {
    return _firestore
        .collection('orders')
        .where('livreurId', isEqualTo: livreurId)

        // Tri par la date de mise à jour
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Commande.fromJson({...doc.data(), 'id': doc.id}))
        .toList());
  }

  // --- ÉCRITURE ET MODIFICATION DES COMMANDES ---

  /// Crée une nouvelle commande.
  Future<String> createOrder(Commande order, NotificationService notificationService) async {
    final docRef = await _firestore.collection('orders').add(order.toJson());
    await _notifyManagers(docRef.id, notificationService);
    return docRef.id;
  }

  /// Met à jour le statut d'une commande.
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Assigne une commande à un point de vente.
  Future<void> assignToTopMlawi(String orderId, String topMlawiId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.assignedToPoint,
      'topMlawiId': topMlawiId,
      'assignedToTopMlawiAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Assigne une commande à un livreur.
  Future<void> assignToLivreur(String orderId, String livreurId, NotificationService notificationService) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('orders').doc(orderId), {
      'status': OrderStatus.assignedToDriver,
      'livreurId': livreurId,
      'assignedToLivreurAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('users').doc(livreurId), {
      'activeOrders': FieldValue.increment(1),
    });
    await batch.commit();
    await notificationService.sendNotification(
      userId: livreurId,
      title: 'Nouvelle commande assignée',
      body: 'La commande #${orderId.substring(0, 6)} vous a été assignée.',
      type: 'order_assigned',
      relatedId: orderId,
    );
  }

  /// Marque une commande comme récupérée par le livreur.
  Future<void> markAsPickedUp(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': OrderStatus.delivering,
      'pickedUpAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marque une commande comme livrée.
  Future<void> markAsDelivered(String orderId, NotificationService notificationService) async {
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    final orderData = orderDoc.data();
    if (orderData == null) return;
    final batch = _firestore.batch();
    batch.update(_firestore.collection('orders').doc(orderId), {
      'status': OrderStatus.delivered,
      'deliveredAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (orderData['livreurId'] != null) {
      final livreurRef = _firestore.collection('users').doc(orderData['livreurId']);
      batch.update(livreurRef, {'activeOrders': FieldValue.increment(-1)});
    }
    await batch.commit();
    if (orderData['userId'] != null) {
      await notificationService.sendNotification(
        userId: orderData['userId'],
        title: 'Commande livrée',
        body: 'Votre commande a été livrée avec succès !',
        type: 'status_change',
        relatedId: orderId,
      );
    }
  }

  // --- MÉTHODES UTILITAIRES ---

  /// Notifie tous les managers/gérants d'une nouvelle commande.
  Future<void> _notifyManagers(String orderId, NotificationService notificationService) async {
    try {
      final managersSnapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['gerant', 'manager'])
          .get();
      for (var doc in managersSnapshot.docs) {
        await notificationService.sendNotification(
          userId: doc.id,
          title: 'Nouvelle commande',
          body: 'Une nouvelle commande a été passée',
          type: 'new_order',
          relatedId: orderId,
        );
      }
    } catch (e) {
      print('Error notifying managers: $e');
    }
  }

  /// Récupère la liste des livreurs (pour les dialogues d'assignation).
  Stream<QuerySnapshot> getLivreurs() {
    return _firestore.collection('users').where('role', isEqualTo: 'livreur').snapshots();
  }
}
