import 'package:cloud_firestore/cloud_firestore.dart';

class Commande {
  String? id;
  String? userId; // ID of the user who placed the order (if logged in)
  String clientName;
  String clientFirstName;
  String clientPhone;
  String clientAddress;
  List<Map<String, dynamic>> items;
  double totalPrice;
  DateTime orderDate;
  String status;
  String? topMlawiPoint; // New: To store the assigned TopMlawi point
  String? deliveryPerson; // New: To store the assigned delivery person

  Commande({
    this.id,
    this.userId,
    required this.clientName,
    required this.clientFirstName,
    required this.clientPhone,
    required this.clientAddress,
    required this.items,
    required this.totalPrice,
    required this.orderDate,
    this.status = 'Pending',
    this.topMlawiPoint,
    this.deliveryPerson,
  });

  // Convert Commande object to a map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'clientName': clientName,
      'clientFirstName': clientFirstName,
      'clientPhone': clientPhone,
      'clientAddress': clientAddress,
      'items': items,
      'totalPrice': totalPrice,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status,
      'topMlawiPoint': topMlawiPoint, // Include new field
      'deliveryPerson': deliveryPerson, // Include new field
    };
  }

  // Create Commande object from a Firestore map
  factory Commande.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Commande(
      id: doc.id,
      userId: data['userId'],
      clientName: data['clientName'],
      clientFirstName: data['clientFirstName'],
      clientPhone: data['clientPhone'],
      clientAddress: data['clientAddress'],
      items: List<Map<String, dynamic>>.from(data['items']),
      totalPrice: (data['totalPrice'] as num).toDouble(),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
      topMlawiPoint: data['topMlawiPoint'],
      deliveryPerson: data['deliveryPerson'],
    );
  }

  // Create Commande object from a map (for OrderService)
  factory Commande.fromJson(Map<String, dynamic> data) {
    return Commande(
      id: data['id'],
      userId: data['userId'],
      clientName: data['clientName'] ?? '',
      clientFirstName: data['clientFirstName'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      clientAddress: data['clientAddress'] ?? '',
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
      totalPrice: (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
      orderDate: data['orderDate'] is Timestamp 
          ? (data['orderDate'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] ?? 'pending',
      topMlawiPoint: data['topMlawiPoint'],
      deliveryPerson: data['deliveryPerson'],
    );
  }

  // Getter for totalAmount (alias for totalPrice)
  double get totalAmount => totalPrice;
}
