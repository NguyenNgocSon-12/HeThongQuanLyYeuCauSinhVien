import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class FirestoreNotificationService {
  FirestoreNotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  Stream<List<NotificationModel>> watchForUser(
    String userId, {
    int limit = 50,
  }) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> markAsRead(String id) {
    return _notifications.doc(id).update({
      'isRead': true,
      'readAt': DateTime.now(),
    });
  }
}
