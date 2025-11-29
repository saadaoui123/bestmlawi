import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:projet_best_mlewi/model/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send a notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    required String relatedId,
  }) async {
    try {
      final notification = NotificationModel(
        userId: userId,
        title: title,
        body: body,
        type: type,
        relatedId: relatedId,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toJson());
      notifyListeners();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Stream of notifications for a specific user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final notifications = snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList();
      // Sort client-side to avoid needing a Firestore index
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  // Stream of unread count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'read': true,
      });
      notifyListeners();
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Mark all as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }
}
