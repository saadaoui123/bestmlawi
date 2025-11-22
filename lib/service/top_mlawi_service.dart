import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart';
import 'dart:math' show cos, sqrt, asin;

class TopMlawiService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all available TopMlawi points
  Stream<List<TopMlawi>> getAvailableTopMlawi() {
    return _firestore
        .collection('topmlawi')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TopMlawi.fromFirestore(doc))
            .toList());
  }

  // Get all TopMlawi points
  Stream<List<TopMlawi>> getAllTopMlawi() {
    return _firestore
        .collection('topmlawi')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TopMlawi.fromFirestore(doc))
            .toList());
  }

  // Assign order to TopMlawi
  Future<void> assignOrderToTopMlawi(String orderId, String topMlawiId) async {
    final batch = _firestore.batch();

    // Update order
    batch.update(
      _firestore.collection('orders').doc(orderId),
      {
        'topMlawiId': topMlawiId,
        'assignedToTopMlawiAt': FieldValue.serverTimestamp(),
        'status': 'assigned_to_point',
      },
    );

    // Increment TopMlawi capacity
    batch.update(
      _firestore.collection('topmlawi').doc(topMlawiId),
      {'currentCapacity': FieldValue.increment(1)},
    );

    await batch.commit();
    notifyListeners();
  }

  // Calculate distance between two points (Haversine formula)
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    const double earthRadius = 6371; // km
    
    final lat1 = point1.latitude * (3.14159 / 180);
    final lat2 = point2.latitude * (3.14159 / 180);
    final dLat = (point2.latitude - point1.latitude) * (3.14159 / 180);
    final dLon = (point2.longitude - point1.longitude) * (3.14159 / 180);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;

  // Find optimal TopMlawi based on distance and capacity
  Future<TopMlawi?> getOptimalTopMlawi(GeoPoint orderLocation) async {
    final snapshot = await _firestore
        .collection('topmlawi')
        .where('isAvailable', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) return null;

    final points = snapshot.docs
        .map((doc) => TopMlawi.fromFirestore(doc))
        .where((point) => point.hasCapacity)
        .toList();

    if (points.isEmpty) return null;

    // Sort by distance
    points.sort((a, b) {
      final distA = calculateDistance(orderLocation, a.location);
      final distB = calculateDistance(orderLocation, b.location);
      return distA.compareTo(distB);
    });

    return points.first;
  }

  // Create a new TopMlawi point (for testing)
  Future<void> createTopMlawi(TopMlawi topMlawi) async {
    await _firestore.collection('topmlawi').add(topMlawi.toMap());
    notifyListeners();
  }
}
