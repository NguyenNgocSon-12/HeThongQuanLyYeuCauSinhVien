import 'package:flutter/material.dart';

/// ================== STATUS ==================
enum RequestStatus { pending, processing, approved, rejected }

extension RequestStatusExtension on RequestStatus {
  String get text {
    switch (this) {
      case RequestStatus.pending:
        return "Chờ xử lý";
      case RequestStatus.processing:
        return "Đang xử lý";
      case RequestStatus.approved:
        return "Đã duyệt";
      case RequestStatus.rejected:
        return "Từ chối";
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.processing:
        return Colors.blue;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
    }
  }
}

enum RequestType { confirm, leave, complaint }

extension RequestTypeExtension on RequestType {
  String get text {
    switch (this) {
      case RequestType.confirm:
        return "Xác nhận";
      case RequestType.leave:
        return "Nghỉ học";
      case RequestType.complaint:
        return "Khiếu nại";
    }
  }

  Color get color {
    switch (this) {
      case RequestType.confirm:
        return Colors.purple;
      case RequestType.leave:
        return Colors.teal;
      case RequestType.complaint:
        return Colors.redAccent;
    }
  }
}

/// ================== MODEL ==================
class RequestModel {
  String? id;

  String title;
  String content;

  String studentName;
  String studentId;

  RequestStatus status;
  RequestType type;

  String? adminNote;
  String? processedBy;
  String? evidenceFileUrl;

  DateTime createdAt;
  DateTime? processedAt;
  String? userId;
  RequestModel({
    this.id,
    required this.title,
    required this.content,
    required this.studentName,
    required this.studentId,
    this.status = RequestStatus.pending,
    this.type = RequestType.confirm,
    this.adminNote,
    this.processedBy,
    this.evidenceFileUrl,
    DateTime? createdAt,
    this.processedAt,
    this.userId,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ================== TO MAP ==================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'studentName': studentName,
      'studentId': studentId,
      'status': status.index,
      'type': type.index,
      'adminNote': adminNote,
      'processedBy': processedBy,
      'evidenceFileUrl': evidenceFileUrl,
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  /// ================== FROM MAP ==================
  factory RequestModel.fromMap(Map<String, dynamic> map) {
    // 1. Xử lý status an toàn: Đọc được cả String (cũ) và int (mới)
    RequestStatus status;
    final statusRaw = map['status'];

    if (statusRaw is int) {
      status = RequestStatus.values[statusRaw];
    } else if (statusRaw is String) {
      // Chuyển đổi từ text cũ về Enum
      if (statusRaw == "Chờ xử lý")
        status = RequestStatus.pending;
      else if (statusRaw == "Đang xử lý")
        status = RequestStatus.processing;
      else if (statusRaw == "Đã duyệt")
        status = RequestStatus.approved;
      else if (statusRaw == "Từ chối")
        status = RequestStatus.rejected;
      else
        status = RequestStatus.pending;
    } else {
      status = RequestStatus.pending;
    }
    // Trong fromMap, thêm trước return:
    print("DEBUG imageUrl: ${map['imageUrl']}");
    print("DEBUG evidenceFileUrl: ${map['evidenceFileUrl']}");
    print("DEBUG all keys: ${map.keys.toList()}");
    return RequestModel(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['thrilled'] ?? map['content'] ?? '',
      studentName: map['studentName'] ?? '',
      studentId: map['studentMssv'] ?? map['studentId'] ?? '',
      status: status,
      type: (map['type'] is int)
          ? RequestType.values[map['type']]
          : RequestType.confirm,
      adminNote: map['adminNote'],
      processedBy: map['processedBy'],
      evidenceFileUrl: map['imageUrl'] ?? map['evidenceFileUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      processedAt:
          map['processedAt'] !=
              null // ← THÊM ĐOẠN NÀY
          ? DateTime.parse(map['processedAt'])
          : null,
    );
  }
}
