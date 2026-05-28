import 'package:flutter/material.dart';
import 'student_home.dart';
import 'admin_home.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mssvController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  @override
  void dispose() {
    mssvController.dispose();
    passController.dispose();
    super.dispose();
  }

  void handleLogin() {
    final mssv = mssvController.text.trim();
    final pass = passController.text.trim();

    final user = AuthService.login(mssv, pass);

    if (user != null) {
      if (user["role"] == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => StudentHome()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sai MSSV hoặc mật khẩu")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
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
                      child: ElevatedButton(
                        onPressed: handleLogin,
                        child: const Text("Đăng nhập"),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
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