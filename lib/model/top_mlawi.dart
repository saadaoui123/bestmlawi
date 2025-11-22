import 'package:cloud_firestore/cloud_firestore.dart';

class TopMlawi {
  final String id;
  final String name;
  final GeoPoint location;
  final bool isAvailable;
  final int currentCapacity;
  final int maxCapacity;
  final String address;

  TopMlawi({
    required this.id,
    required this.name,
    required this.location,
    required this.isAvailable,
    required this.currentCapacity,
    required this.maxCapacity,
    required this.address,
  });

  factory TopMlawi.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopMlawi(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] ?? const GeoPoint(0, 0),
      isAvailable: data['isAvailable'] ?? true,
      currentCapacity: data['currentCapacity'] ?? 0,
      maxCapacity: data['maxCapacity'] ?? 10,
      address: data['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'isAvailable': isAvailable,
      'currentCapacity': currentCapacity,
      'maxCapacity': maxCapacity,
      'address': address,
    };
  }

  bool get hasCapacity => currentCapacity < maxCapacity;
  double get capacityPercentage => (currentCapacity / maxCapacity) * 100;
}
