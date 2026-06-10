import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'request_page.dart';
import 'change_password_page.dart';
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("Không tìm thấy thông tin người dùng"),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String name = data['name'] ?? "Chưa cập nhật";
          final String mssv = data['mssv'] ?? "Chưa cập nhật";
          final String email = data['e-mail'] ?? user?.email ?? "---";
          final String role = data['role'] ?? "student";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // --- HEADER ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade700, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 35, color: Colors.blue),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "MSSV: $mssv",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Vai trò: $role",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- THÔNG TIN CÁ NHÂN ---
              const Text(
                "Thông tin cá nhân",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.blue),
                      title: const Text("Email"),
                      subtitle: Text(email),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.badge, color: Colors.green),
                      title: const Text("MSSV"),
                      subtitle: Text(mssv),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- TÀI KHOẢN ---
              const Text(
                "Tài khoản",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildMenuTile(
                      Icons.edit,
                      "Chỉnh sửa thông tin",
                      Colors.orange,
                      () => _showEditNameDialog(context, name),
                    ),
                    _buildMenuTile(
                      Icons.history,
                      "Lịch sử yêu cầu",
                      Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestPage(),
                          ),
                        );
                      },
                    ),
                    _buildMenuTile(
                      Icons.lock,
                      "Đổi mật khẩu",
                      Colors.red,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HÀM HỖ TRỢ MENU ---
  Widget _buildMenuTile(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: color),
          title: Text(title),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  // --- LOGIC: CHỈNH SỬA TÊN ---
  void _showEditNameDialog(BuildContext context, String currentName) {
    final TextEditingController ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cập nhật tên"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Tên mới"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid)
                  .update({'name': ctrl.text});
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: ĐỔI MẬT KHẨU ---
  void _handlePasswordReset(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: FirebaseAuth.instance.currentUser?.email ?? "",
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi email khôi phục mật khẩu!")),
        );
      }
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }
}
