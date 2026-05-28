import 'package:flutter/material.dart';

/// ================== STATUS ==================
enum RequestStatus {
  pending,
  processing,
  approved,
  rejected,
}

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


enum RequestType {
  confirm,    
  leave,      
  complaint,  
}

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
  int? id;

  String title;
  String content;

  String studentName;
  String studentId;

  RequestStatus status;
  RequestType type; 

  String? adminNote;
  String? processedBy;

  DateTime createdAt;
  DateTime? processedAt;

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
    DateTime? createdAt,
    this.processedAt,
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
      'createdAt': createdAt.toIso8601String(),
      'processedAt': processedAt?.toIso8601String(),
    };
  }

  /// ================== FROM MAP ==================
  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      studentName: map['studentName'],
      studentId: map['studentId'],
      status: RequestStatus.values[map['status']],
      type: RequestType.values[map['type'] ?? 0], 
      adminNote: map['adminNote'],
      processedBy: map['processedBy'],
      createdAt: DateTime.parse(map['createdAt']),
      processedAt: map['processedAt'] != null
          ? DateTime.parse(map['processedAt'])
          : null,
    );
  }
}