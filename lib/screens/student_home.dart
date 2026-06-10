import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about_page.dart';
import 'guide_page.dart';
import 'support_page.dart';
import 'home_page.dart';
import 'request_page.dart';
import 'profile_page.dart';
import 'login_screen.dart';
import 'settings_page.dart';
import 'create_request.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _bottomIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const RequestPage(),
    const ProfilePage(),
  ];

  Widget get currentPage {
    if (_bottomIndex == 0) return pages[0];
    if (_bottomIndex == 2) return pages[1];
    return pages[2];
  }

  @override
  Widget build(BuildContext context) {
    // Lấy màu từ theme hiện tại để đảm bảo tính đồng bộ
    final theme = Theme.of(context);

    return Scaffold(
      // Dùng màu nền của Scaffold từ Theme
      backgroundColor: theme.scaffoldBackgroundColor,

      /// ================= APPBAR =================
      appBar: AppBar(
        elevation: 0,
        // Xóa backgroundColor: Colors.white và foregroundColor: Colors.black
        // để nó tự động nhận từ appBarTheme trong main.dart
        title: const Text(
          "Hệ thống yêu cầu sinh viên",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Mở trang thông báo")),
                  );
                },
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      /// ================= DRAWER =================
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            String name = "Đang tải...";
            String email = FirebaseAuth.instance.currentUser?.email ?? "---";

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              name = data['name'] ?? "Người dùng";
            }

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(color: Color(0xFF1565C0)),
                  accountName: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(email),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text("Giới thiệu"),
                  onTap: () {
                    Navigator.pop(context); // Đóng drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text("Hướng dẫn"),
                  onTap: () {
                    Navigator.pop(context); // Đóng drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GuidePage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.support_agent_rounded),
                  title: const Text("Liên hệ hỗ trợ"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportPage()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Cài đặt"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    );
                  },
                ),
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Đăng xuất"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),

      /// ================= BODY =================
      body: currentPage,

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        type: BottomNavigationBarType.fixed,
        // Dùng colorScheme thay vì màu cố định để đẹp hơn trên nền tối
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          if (value == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
            );
            return;
          }
          setState(() {
            _bottomIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: "Tạo yêu cầu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: "Yêu cầu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }
}
