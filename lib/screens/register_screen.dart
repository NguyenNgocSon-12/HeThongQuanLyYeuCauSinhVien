import 'package:flutter/material.dart';
import '../fake_user_db.dart';

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

  @override
  void dispose() {
    nameController.dispose();
    mssvController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  void handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    final mssv = mssvController.text.trim();
    final pass = passController.text.trim();

    /// CHECK TRÙNG
    final exist = FakeUserDB.users.any((u) => u["mssv"] == mssv);

    if (exist) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("MSSV đã tồn tại")),
      );
      return;
    }

    /// LƯU USER (thêm role luôn cho chuẩn)
    FakeUserDB.users.add({
      "name": nameController.text.trim(),
      "mssv": mssv,
      "pass": pass,
      "role": "student",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đăng ký thành công")),
    );

    Navigator.pop(context);
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
                child: Form(
                  key: _formKey,
                  child: Column(
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

                      /// NAME
                      TextFormField(
                        controller: nameController,
                        validator: (value) =>
                            value!.isEmpty ? "Không được để trống" : null,
                        decoration: InputDecoration(
                          labelText: "Họ tên",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// MSSV
                      TextFormField(
                        controller: mssvController,
                        validator: (value) =>
                            value!.isEmpty ? "Nhập MSSV" : null,
                        decoration: InputDecoration(
                          labelText: "MSSV",
                          prefixIcon: const Icon(Icons.badge),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// PASSWORD
                      TextFormField(
                        controller: passController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Nhập mật khẩu";
                          }
                          if (value.length < 3) {
                            return "Ít nhất 3 ký tự";
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

                      /// CONFIRM PASSWORD
                      TextFormField(
                        controller: confirmPassController,
                        obscureText: true,
                        validator: (value) {
                          if (value != passController.text) {
                            return "Mật khẩu không khớp";
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

                      const SizedBox(height: 20),

                      /// BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: handleRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Đăng ký"),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
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