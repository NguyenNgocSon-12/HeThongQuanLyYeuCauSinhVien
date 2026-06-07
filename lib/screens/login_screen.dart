import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Cần thiết để đọc phân quyền role
import 'package:firebase_auth/firebase_auth.dart';
import 'student_home.dart';
import 'admin_home.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';
import '../utils/session_manager.dart'; // Quản lý session đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mssvController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final AuthService _authService = AuthService(); // Khởi tạo instance của AuthService

  bool _isLoading = false; // Quản lý trạng thái hiển thị loading vòng xoay

  @override
  void dispose() {
    mssvController.dispose();
    passController.dispose();
    super.dispose();
  }

  // Hàm xử lý Đăng nhập bất đồng bộ kết nối Firebase
  void handleLogin() async {
    final mssv = mssvController.text.trim();
    final pass = passController.text.trim();

    if (mssv.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ MSSV và mật khẩu")),
      );
      return;
    }

    setState(() => _isLoading = true); // Bật hiệu ứng loading khi bấm nút

    try {
      // 1. Gọi Firebase Auth thông qua dịch vụ AuthService đã viết
      User? user = await _authService.loginWithMSSV(mssv, pass);

      if (user != null) {
        // 2. Đọc thông tin 'role' (Vai trò) của tài khoản này từ Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String role = userData['role'] ?? 'student'; // Mặc định là student nếu trống
          await SessionManager.setLoggedIn(mssv);
          // 3. Phân quyền điều hướng màn hình dựa trên role cụ thể
          if (role == "admin") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHome()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StudentHome()),
            );
          }
        } else {
          // Trường hợp tài khoản có trên Auth nhưng không tìm thấy dữ liệu profile ở Firestore
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tài khoản lỗi thông tin hệ thống!")),
          );
        }
      }
    } catch (e) {
      // 4. Xử lý hiển thị thông báo lỗi chi tiết từ Firebase một cách trực quan
      String errorMsg = "Sai MSSV hoặc mật khẩu. Vui lòng kiểm tra lại!";
      String errString = e.toString().toLowerCase();

      if (errString.contains('user-not-found') || errString.contains('invalid-credential')) {
        errorMsg = "Thông tin đăng nhập không chính xác hoặc chưa đăng ký!";
      } else if (errString.contains('network-request-failed')) {
        errorMsg = "Lỗi kết nối Internet. Vui lòng thử lại!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Tắt hiệu ứng loading khi hoàn thành công việc
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0F172A), Color(0xFF1E293B)]
                : const [Color(0xFF2196F3), Color(0xFF21CBF3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.school, size: 60, color: Colors.blue),
                    const SizedBox(height: 10),
                    const Text(
                      "Hệ thống hỗ trợ Sinh viên",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    TextField(
                      controller: mssvController,
                      enabled: !_isLoading, // Khóa ô nhập liệu khi đang loading
                      decoration: InputDecoration(
                        labelText: "MSSV",
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: passController,
                      obscureText: true,
                      enabled: !_isLoading, // Khóa ô nhập liệu khi đang loading
                      decoration: InputDecoration(
                        labelText: "Mật khẩu",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        // Nếu đang chạy ngầm thì hiển thị vòng xoay, ngược lại hiện chữ Đăng nhập
                        onPressed: _isLoading ? null : handleLogin, 
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text("Đăng nhập", style: TextStyle(fontSize: 16)),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: _isLoading 
                          ? null 
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              );
                            },
                      child: const Text("Chưa có tài khoản? Đăng ký"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}