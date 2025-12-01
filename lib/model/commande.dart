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
  String? topMlawiId; // To store the assigned TopMlawi point ID
  String? livreurId; // To store the assigned delivery person ID
  DateTime? pickedUpAt;
  DateTime? deliveredAt;
  final DateTime? updatedAt;

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
    this.updatedAt,
    this.status = 'Pending',
    this.topMlawiId,
    this.livreurId,
    this.pickedUpAt,
    this.deliveredAt,
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
      'topMlawiId': topMlawiId,
      'livreurId': livreurId,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
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
      topMlawiId: data['topMlawiId'],
      livreurId: data['livreurId'],
      pickedUpAt: data['pickedUpAt'] != null ? (data['pickedUpAt'] as Timestamp).toDate() : null,
      deliveredAt: data['deliveredAt'] != null ? (data['deliveredAt'] as Timestamp).toDate() : null,
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
      topMlawiId: data['topMlawiId'],
      livreurId: data['livreurId'],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      pickedUpAt: data['pickedUpAt'] != null 
          ? (data['pickedUpAt'] is Timestamp 
              ? (data['pickedUpAt'] as Timestamp).toDate() 
              : null) 
          : null,
      deliveredAt: data['deliveredAt'] != null 
          ? (data['deliveredAt'] is Timestamp 
              ? (data['deliveredAt'] as Timestamp).toDate() 
              : null) 
          : null,
    );
  }

  // Getter for totalAmount (alias for totalPrice)
  double get totalAmount => totalPrice;
}
