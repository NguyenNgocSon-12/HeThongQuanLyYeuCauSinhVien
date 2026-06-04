import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum RequestStatus {
  pending('pending', 'Chờ duyệt', Colors.orange),
  processing('processing', 'Đang xử lý', Colors.blue),
  approved('approved', 'Đã duyệt', Colors.green),
  rejected('rejected', 'Từ chối', Colors.red);

  const RequestStatus(this.value, this.text, this.color);

  final String value;
  final String text;
  final Color color;

  static RequestStatus fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();

    for (final status in RequestStatus.values) {
      if (status.value == normalized ||
          status.text.toLowerCase() == normalized) {
        return status;
      }
    }

    // Hỗ trợ dữ liệu cũ đã lưu bằng nhãn "Chờ xử lý".
    if (normalized == 'chờ xử lý') {
      return RequestStatus.pending;
    }

    return RequestStatus.pending;
  }
}

enum RequestType {
  confirm('confirm', 'Xác nhận'),
  leave('leave', 'Nghỉ học'),
  cardReplacement('card_replacement', 'Cấp lại thẻ'),
  courseRegistration('course_registration', 'Đăng ký học phần'),
  complaint('complaint', 'Khiếu nại'),
  other('other', 'Khác');

  const RequestType(this.value, this.text);

  final String value;
  final String text;

  Color get color {
    switch (this) {
      case RequestType.confirm:
        return Colors.purple;
      case RequestType.leave:
        return Colors.teal;
      case RequestType.cardReplacement:
        return Colors.indigo;
      case RequestType.courseRegistration:
        return Colors.blue;
      case RequestType.complaint:
        return Colors.redAccent;
      case RequestType.other:
        return Colors.blueGrey;
    }
  }

  static RequestType fromValue(Object? value, {String? title}) {
    final normalized = value?.toString().trim().toLowerCase();

    for (final type in RequestType.values) {
      if (type.value == normalized || type.text.toLowerCase() == normalized) {
        return type;
      }
    }

    return fromTitle(title ?? '');
  }

  static RequestType fromTitle(String title) {
    final normalized = title.trim().toLowerCase();

    if (normalized.contains('nghỉ')) return RequestType.leave;
    if (normalized.contains('thẻ')) return RequestType.cardReplacement;
    if (normalized.contains('học phần')) return RequestType.courseRegistration;
    if (normalized.contains('khiếu nại')) return RequestType.complaint;
    if (normalized.contains('xác nhận')) return RequestType.confirm;
    return RequestType.other;
  }
}

class RequestModel {
  static const Object _notProvided = Object();

  RequestModel({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.studentName,
    required this.studentId,
    this.status = RequestStatus.pending,
    this.type = RequestType.other,
    this.adminNote,
    this.processedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.processedAt,
    this.isSynced = true,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  final String? id;
  final String userId;
  final String title;
  final String content;
  final String studentName;
  final String studentId;
  final RequestStatus status;
  final RequestType type;
  final String? adminNote;
  final String? processedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? processedAt;

  /// Chỉ dùng ở SQLite để biết bản ghi đã được đẩy lên Firestore hay chưa.
  final bool isSynced;

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'studentId': studentId,
      'studentName': studentName,
      'studentNameLower': studentName.toLowerCase(),
      'title': title,
      'content': content,
      'status': status.value,
      'type': type.value,
      if (adminNote != null && adminNote!.isNotEmpty) 'adminNote': adminNote,
      if (processedBy != null && processedBy!.isNotEmpty)
        'processedBy': processedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (processedAt != null) 'processedAt': processedAt,
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'userId': userId,
      'studentName': studentName,
      'studentId': studentId,
      'title': title,
      'type': type.value,
      'content': content,
      'status': status.value,
      'adminNote': adminNote,
      'processedBy': processedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory RequestModel.fromMap(
    String id,
    Map<String, dynamic> map, {
    bool isSynced = true,
  }) {
    final title = (map['title'] ?? '').toString();
    final createdAt = _readDate(map['createdAt']) ?? DateTime.now();

    return RequestModel(
      id: id,
      userId: (map['userId'] ?? '').toString(),
      title: title,
      content: (map['content'] ?? '').toString(),
      studentName: (map['studentName'] ?? '').toString(),
      studentId: (map['studentId'] ?? map['studentMssv'] ?? '').toString(),
      status: RequestStatus.fromValue(map['status']),
      type: RequestType.fromValue(map['type'], title: title),
      adminNote: map['adminNote']?.toString(),
      processedBy: map['processedBy']?.toString(),
      createdAt: createdAt,
      updatedAt: _readDate(map['updatedAt']) ?? createdAt,
      processedAt: _readDate(map['processedAt']),
      isSynced: isSynced,
    );
  }

  factory RequestModel.fromLocalMap(Map<String, dynamic> map) {
    return RequestModel.fromMap(
      map['id'].toString(),
      map,
      isSynced: map['isSynced'] == 1,
    );
  }

  RequestModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? studentName,
    String? studentId,
    RequestStatus? status,
    RequestType? type,
    Object? adminNote = _notProvided,
    Object? processedBy = _notProvided,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? processedAt = _notProvided,
    bool? isSynced,
  }) {
    return RequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      studentName: studentName ?? this.studentName,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      type: type ?? this.type,
      adminNote: identical(adminNote, _notProvided)
          ? this.adminNote
          : adminNote as String?,
      processedBy: identical(processedBy, _notProvided)
          ? this.processedBy
          : processedBy as String?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      processedAt: identical(processedAt, _notProvided)
          ? this.processedAt
          : processedAt as DateTime?,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
