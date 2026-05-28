import 'package:flutter/material.dart';

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

  /// INDEX BOTTOM NAV
  int _bottomIndex = 0;

  /// PAGE HIỂN THỊ
  final List<Widget> pages = [
    const HomePage(),
    const RequestPage(),
    const ProfilePage(),
  ];

  /// MAP INDEX
  Widget get currentPage {
    if (_bottomIndex == 0) {
      return pages[0]; // Home
    }

    if (_bottomIndex == 2) {
      return pages[1]; // Request
    }

    return pages[2]; // Profile
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      /// ================= APPBAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        title: const Text(
          "Hệ thống yêu cầu sinh viên",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                ),

                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mở trang thông báo"),
                    ),
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
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1565C0),
              ),

              accountName: const Text("Nguyễn Văn A"),

              accountEmail: const Text(
                "22110234@student.edu.vn",
              ),

              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,

                child: Icon(
                  Icons.person,
                  color: Colors.blue,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("Giới thiệu"),
            ),

            ListTile(
              leading: const Icon(Icons.help),
              title: const Text("Hướng dẫn"),
            ),

            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text("Liên hệ hỗ trợ"),
            ),

            /// SETTINGS
            ListTile(
              leading: const Icon(Icons.settings),

              title: const Text("Cài đặt"),

              onTap: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
            ),

            const Spacer(),

            const Divider(),

            /// LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),

              title: const Text("Đăng xuất"),

              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      /// ================= BODY =================
      body: currentPage,

      /// ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF1565C0),

        unselectedItemColor: Colors.grey,

        onTap: (value) {

          /// TẠO YÊU CẦU
          if (value == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateRequestScreen(),
              ),
            );

            return;
          }

          /// CHUYỂN TAB
          setState(() {
            _bottomIndex = value;
          });
        },

        items: const [

          /// HOME
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),

          /// CREATE REQUEST
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: "Tạo yêu cầu",
          ),

          /// REQUEST
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_rounded),
            label: "Yêu cầu",
          ),

          /// PROFILE
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Cá nhân",
          ),
        ],
      ),
    );
  }
}