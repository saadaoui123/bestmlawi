import 'package:cloud_firestore/cloud_firestore.dart';

class Livreur {
  final String id;
  final String name;
  final String phone;
  final bool isAvailable;
  final GeoPoint? currentLocation;
  final int activeOrders;
  final String? photoUrl;

  Livreur({
    required this.id,
    required this.name,
    required this.phone,
    required this.isAvailable,
    this.currentLocation,
    required this.activeOrders,
    this.photoUrl,
  });

  factory Livreur.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Livreur(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      currentLocation: data['currentLocation'],
      activeOrders: data['activeOrders'] ?? 0,
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'isAvailable': isAvailable,
      'currentLocation': currentLocation,
      'activeOrders': activeOrders,
      'photoUrl': photoUrl,
    };
  }

  bool get canTakeOrder => isAvailable && activeOrders < 3;
}
