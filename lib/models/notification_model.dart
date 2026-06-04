import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.requestId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String userId;
  final String requestId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      userId: (map['userId'] ?? '').toString(),
      requestId: (map['requestId'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      message: (map['message'] ?? '').toString(),
      type: (map['type'] ?? '').toString(),
      isRead: map['isRead'] == true,
      createdAt: _readDate(map['createdAt']) ?? DateTime.now(),
      readAt: _readDate(map['readAt']),
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value != null) return DateTime.tryParse(value.toString());
    return null;
  }
}
