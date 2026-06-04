import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mssvController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Biến trạng thái hiển thị vòng xoay tải dữ liệu

  @override
  void dispose() {
    nameController.dispose();
    mssvController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = nameController.text.trim();
    final mssv = mssvController.text.trim();
    final pass = passController.text.trim();
    
    // Tạo email ảo tự động dựa trên MSSV đồng bộ với màn hình Đăng nhập
    final email = "$mssv@huit.edu.vn"; 

    setState(() {
      _isLoading = true;
    });

    try {
      // BƯỚC 1: Tạo tài khoản trên hệ thống Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      final uid = userCredential.user?.uid;

      if (uid != null) {
        // BƯỚC 2: Đồng bộ thông tin chi tiết của Sinh viên lên Cloud Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          "uid": uid,
          "name": name,
          "mssv": mssv,
          "email": email,
          "role": "student", // Gán quyền tự động cho tài khoản đăng ký là sinh viên
          "createdAt": FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đăng ký tài khoản thành công!"),
            backgroundColor: Colors.green,
          ),
        );

        // Đăng ký xong, đưa sinh viên quay lại màn hình đăng nhập
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Đăng ký thất bại!";
      
      // Bắt các trường hợp lỗi Firebase phản hồi về
      if (e.code == 'email-already-in-use') {
        errorMsg = "Mã số sinh viên này đã được đăng ký tài khoản!";
      } else if (e.code == 'weak-password') {
        errorMsg = "Mật khẩu quá ngắn hoặc quá yếu!";
      } else if (e.code == 'network-request-failed') {
        errorMsg = "Lỗi kết nối mạng đến Server Firebase!";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hệ thống gặp sự cố: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.app_registration,
                          size: 60, color: Colors.blue),
                      const SizedBox(height: 10),

                      const Text(
                        "Đăng ký tài khoản",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 20),

                      /// FIELD HỌ TÊN
                      TextFormField(
                        controller: nameController,
                        enabled: !_isLoading,
                        validator: (value) =>
                            value!.isEmpty ? "Không được để trống họ tên" : null,
                        decoration: InputDecoration(
                          labelText: "Họ tên",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// FIELD MSSV
                      TextFormField(
                        controller: mssvController,
                        enabled: !_isLoading,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? "Vui lòng nhập MSSV" : null,
                        decoration: InputDecoration(
                          labelText: "MSSV",
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// FIELD MẬT KHẨU
                      TextFormField(
                        controller: passController,
                        enabled: !_isLoading,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập mật khẩu";
                          }
                          if (value.length < 6) {
                            return "Mật khẩu Firebase yêu cầu ít nhất 6 ký tự";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Mật khẩu",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// FIELD XÁC NHẬN MẬT KHẨU
                      TextFormField(
                        controller: confirmPassController,
                        enabled: !_isLoading,
                        obscureText: true,
                        validator: (value) {
                          if (value != passController.text) {
                            return "Mật khẩu xác nhận không trùng khớp";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Xác nhận mật khẩu",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// NÚT ĐĂNG KÝ / LOADING BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Đăng ký",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text("Quay lại đăng nhập"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}