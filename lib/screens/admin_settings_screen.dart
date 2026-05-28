import 'package:flutter/material.dart';
import 'login_screen.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool isDarkMode = false;
  bool isNotification = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),

      appBar: AppBar(
        title: const Text("Cài đặt"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🔹 ACCOUNT
          _section("Tài khoản", [
            _tile(Icons.person, "Thông tin admin", () {}),
            _divider(),
            _tile(Icons.lock, "Đổi mật khẩu", () {}),
          ]),

          const SizedBox(height: 16),

          /// 🔹 SYSTEM
          _section("Hệ thống", [
            SwitchListTile(
              value: isNotification,
              onChanged: (v) {
                setState(() => isNotification = v);
              },
              title: const Text("Thông báo"),
              secondary: const Icon(Icons.notifications),
            ),
            _divider(),
            SwitchListTile(
              value: isDarkMode,
              onChanged: (v) {
                setState(() => isDarkMode = v);
              },
              title: const Text("Dark mode"),
              secondary: const Icon(Icons.dark_mode),
            ),
          ]),

          const SizedBox(height: 16),

          /// 🔹 LOGOUT
          _section("", [
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Đăng xuất",
                style: TextStyle(color: Colors.red),
              ),
              onTap: _logout,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  void _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
        (route) => false,
      );
    }
  }
}