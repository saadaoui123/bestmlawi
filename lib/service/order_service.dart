import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:projet_best_mlewi/model/commande.dart';

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
  Future<String> createOrder(Commande order) async {
    final docRef = await _firestore.collection('orders').add(order.toJson());
    return docRef.id;
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

  // Get pending orders (not yet assigned)
  Stream<List<Commande>> getPendingOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'confirmed'])
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
}
