import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String? id;
  String userId;
  String title;
  String body;
  String type; // 'order_assigned', 'status_change', 'new_order'
  String relatedId; // e.g., Order ID
  bool read;
  DateTime createdAt;

  NotificationModel({
    this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.relatedId,
    this.read = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'read': read,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      relatedId: data['relatedId'] ?? '',
      read: data['read'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
