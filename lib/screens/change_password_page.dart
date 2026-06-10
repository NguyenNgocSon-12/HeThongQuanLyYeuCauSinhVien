import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureText = true; // Trạng thái ẩn/hiện mật khẩu

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      User user = FirebaseAuth.instance.currentUser!;
      
      // 1. Xác thực lại
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, 
        password: _oldPasswordController.text
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Đổi mật khẩu
      await user.updatePassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đổi mật khẩu thành công!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.message}"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đổi mật khẩu"), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bảo mật tài khoản", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const Text("Nhập thông tin để thay đổi mật khẩu của bạn.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),

              _buildPasswordField(_oldPasswordController, "Mật khẩu cũ", Icons.lock_outline),
              const SizedBox(height: 15),
              _buildPasswordField(_newPasswordController, "Mật khẩu mới", Icons.lock),
              const SizedBox(height: 15),
              _buildPasswordField(_confirmPasswordController, "Xác nhận mật khẩu mới", Icons.check_circle_outline, 
                isConfirm: true),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _changePassword,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Xác nhận đổi", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label, IconData icon, {bool isConfirm = false}) {
    return TextFormField(
      controller: controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) {
        if (val!.isEmpty) return "Vui lòng nhập trường này";
        if (isConfirm && val != _newPasswordController.text) return "Mật khẩu không khớp";
        if (!isConfirm && val.length < 6) return "Tối thiểu 6 ký tự";
        return null;
      },
    );
  }
}