import 'package:cloud_firestore/cloud_firestore.dart'; // Thêm thư viện này
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Khởi tạo Firestore
  
  // Đuôi email cố định theo trường HUIT của bạn
  final String _schoolDomain = "@huit.edu.vn";

  // 1. Logic ĐĂNG KÝ bằng MSSV + Lưu thông tin cá nhân vào Firestore
  Future<User?> registerWithMSSV({
    required String mssv, 
    required String password,
    required String fullName, // Thêm Họ tên sinh viên
    required String className, // Thêm Lớp (Ví dụ: 12DHTh01)
  }) async {
    try {
      String emailFromMSSV = mssv.trim().toLowerCase() + _schoolDomain;

      // Tạo tài khoản trên Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: emailFromMSSV, password: password);
      
      User? user = result.user;

      // Nếu tạo Auth thành công, tiến hành lưu profile sinh viên vào Firestore collection 'users'
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'mssv': mssv.trim().toUpperCase(),
          'fullName': fullName.trim(),
          'className': className.trim().toUpperCase(),
          'role': 'student', // Mặc định là sinh viên
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      print("Lỗi đăng ký: ${e.toString()}");
      rethrow;
    }
  }

  // 2. Logic ĐĂNG NHẬP bằng MSSV + Lưu Session (SharedPreferences)
  Future<User?> loginWithMSSV(String mssv, String password) async {
    try {
      String emailFromMSSV = mssv.trim().toLowerCase() + _schoolDomain;

      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: emailFromMSSV, password: password);
      
      if (result.user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('studentMssv', mssv.trim().toUpperCase());
        await prefs.setString('uid', result.user!.uid); // Nên lưu thêm UID để dễ truy vấn sau này
      }
      return result.user;
    } catch (e) {
      print("Lỗi đăng nhập: ${e.toString()}");
      rethrow;
    }
  }

  // 3. Logic ĐĂNG XUẤT + Xóa Session
  Future<void> signOut() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 
  }
}