import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  admin;

  static UserRole fromValue(Object? value) {
    return value?.toString().toLowerCase() == 'admin'
        ? UserRole.admin
        : UserRole.student;
  }
}

class UserModel {
  UserModel({
    required this.uid,
    required this.mssv,
    required this.fullName,
    required this.email,
    required this.className,
    this.role = UserRole.student,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String uid;
  final String mssv;
  final String fullName;
  final String email;
  final String className;
  final UserRole role;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'mssv': mssv,
      'fullName': fullName,
      'fullNameLower': fullName.toLowerCase(),
      'email': email,
      'className': className,
      'role': role.name,
      'createdAt': createdAt,
    };
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      mssv: (map['mssv'] ?? '').toString(),
      fullName: (map['fullName'] ?? map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      className: (map['className'] ?? '').toString(),
      role: UserRole.fromValue(map['role']),
      createdAt: _readDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  static DateTime? _readDate(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value != null) return DateTime.tryParse(value.toString());
    return null;
  }
}
