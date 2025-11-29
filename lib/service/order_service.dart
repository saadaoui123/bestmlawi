import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of orders for the current user
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

  // Stream of all orders (for admin/management)
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

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  // Create a new order
  Future<String> createOrder(Commande order, NotificationService notificationService) async {
    final docRef = await _firestore.collection('orders').add(order.toJson());
    
    // Send notification to all managers
    await _notifyManagers(docRef.id, notificationService);
    
    return docRef.id;
  }
  
  // Helper method to notify all managers about new orders
  Future<void> _notifyManagers(String orderId, NotificationService notificationService) async {
    try {
      // Get all users with 'gerant' or 'manager' role
      final managersSnapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['gerant', 'manager'])
          .get();
      
      // Send notification to each manager
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

  // Get a single order by ID
  Future<Commande?> getOrderById(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    
    return Commande.fromJson({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  // Stream of a single order
  Stream<Commande> getOrderStream(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((doc) {
      return Commande.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    });
  }

  // Get pending orders (not yet assigned)
  Stream<List<Commande>> getPendingOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'confirmed', 'Pending', 'Confirmed'])
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Commande.fromJson({
          ...doc.data(),
          'id': doc.id,
        });
      }).toList()..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    });
  }

  // Get orders by TopMlawi
  Stream<List<Commande>> getOrdersByTopMlawi(String topMlawiId) {
    return _firestore
        .collection('orders')
        .where('topMlawiId', isEqualTo: topMlawiId)
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

  // Get orders by Livreur
  Stream<List<Commande>> getOrdersByLivreur(String livreurId) {
    return _firestore
        .collection('orders')
        .where('livreurId', isEqualTo: livreurId)
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

  // Mark order as picked up
  Future<void> markAsPickedUp(String orderId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'picked_up',
      'pickedUpAt': FieldValue.serverTimestamp(),
    });
  }

  // Mark order as delivered
  Future<void> markAsDelivered(String orderId, NotificationService notificationService) async {
    // Get order details first to get client info
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    final orderData = orderDoc.data();
    
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
    });
    
    // Send notification to client if they have a userId
    if (orderData != null && orderData['userId'] != null) {
      await notificationService.sendNotification(
        userId: orderData['userId'],
        title: 'Commande livrée',
        body: 'Votre commande a été livrée avec succès !',
        type: 'status_change',
        relatedId: orderId,
      );
    }
  }

  // Mark order as picked up (delivering) - legacy method
  Future<void> markOrderPickedUp(String orderId) async {
    await markAsPickedUp(orderId);
  }

  // Mark order as delivered - legacy method
  Future<void> markOrderDelivered(String orderId) async {
    // This method doesn't have access to NotificationService, so no notification sent
    await _firestore.collection('orders').doc(orderId).update({
      'status': 'delivered',
      'deliveredAt': FieldValue.serverTimestamp(),
    });
  }
}
