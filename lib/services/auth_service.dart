import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import '../utils/session_manager.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = firestore ?? FirebaseFirestore.instance;

  static const _schoolDomain = '@huit.edu.vn';

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<User?> registerWithMSSV({
    required String mssv,
    required String password,
    required String fullName,
    required String className,
  }) async {
    final normalizedMssv = mssv.trim().toUpperCase();
    final normalizedName = fullName.trim();
    final normalizedClass = className.trim().toUpperCase();

    if (normalizedMssv.length < 6 || normalizedMssv.length > 20) {
      throw ArgumentError('MSSV phải có từ 6 đến 20 ký tự.');
    }
    if (normalizedName.isEmpty) {
      throw ArgumentError('Họ tên không được để trống.');
    }

    final email = '${normalizedMssv.toLowerCase()}$_schoolDomain';
    User? createdUser;

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      createdUser = result.user;

      if (createdUser != null) {
        final profile = UserModel(
          uid: createdUser.uid,
          mssv: normalizedMssv,
          fullName: normalizedName,
          email: email,
          className: normalizedClass,
        );

        await _db
            .collection('users')
            .doc(createdUser.uid)
            .set(profile.toFirestore());
      }

      return createdUser;
    } catch (_) {
      // Tránh tài khoản Auth bị thiếu hồ sơ nếu bước ghi Firestore thất bại.
      try {
        await createdUser?.delete();
      } catch (_) {
        // Giữ lại lỗi gốc để giao diện báo đúng nguyên nhân đăng ký thất bại.
      }
      rethrow;
    }
  }

  Future<User?> loginWithMSSV(String mssv, String password) async {
    final normalizedMssv = mssv.trim().toUpperCase();
    final email = '${normalizedMssv.toLowerCase()}$_schoolDomain';
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.user != null) {
      await SessionManager.setLoggedIn(normalizedMssv, uid: result.user!.uid);
    }
    return result.user;
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final snapshot = await _db.collection('users').doc(uid).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return UserModel.fromMap(snapshot.id, data);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await SessionManager.logout();
  }
}
