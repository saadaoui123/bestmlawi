import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/livreur.dart';

class LivreurService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available drivers
  Stream<List<Livreur>> getAvailableLivreurs() {
    return _firestore
        .collection('livreurs')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Livreur.fromFirestore(doc))
            .where((livreur) => livreur.canTakeOrder)
            .toList());
  }

  // Get all drivers
  Stream<List<Livreur>> getAllLivreurs() {
    return _firestore
        .collection('livreurs')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Livreur.fromFirestore(doc))
            .toList());
  }

  // Assign order to driver
  Future<void> assignOrderToLivreur(String orderId, String livreurId) async {
    final batch = _firestore.batch();

    // Update order
    batch.update(
      _firestore.collection('orders').doc(orderId),
      {
        'livreurId': livreurId,
        'assignedToLivreurAt': FieldValue.serverTimestamp(),
        'status': 'assigned_to_driver',
      },
    );

    // Increment driver's active orders
    batch.update(
      _firestore.collection('livreurs').doc(livreurId),
      {'activeOrders': FieldValue.increment(1)},
    );

    await batch.commit();
    
    // Send notification
    await sendNotificationToLivreur(livreurId, orderId);
    
    notifyListeners();
  }

  // Send notification to driver (placeholder for now)
  Future<void> sendNotificationToLivreur(String livreurId, String orderId) async {
    // TODO: Implement Firebase Cloud Messaging
    // For now, just create a notification document
    await _firestore.collection('notifications').add({
      'livreurId': livreurId,
      'orderId': orderId,
      'type': 'new_order',
      'message': 'Nouvelle commande assignée',
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  // Update driver status
  Future<void> updateLivreurStatus(String livreurId, bool isAvailable) async {
    await _firestore.collection('livreurs').doc(livreurId).update({
      'isAvailable': isAvailable,
    });
    notifyListeners();
  }

  // Create a new driver (for testing)
  Future<void> createLivreur(Livreur livreur) async {
    await _firestore.collection('livreurs').add(livreur.toMap());
    notifyListeners();
  }
}
