import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanltddfinal/models/request_model.dart';
import 'package:doanltddfinal/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_request_list.dart';
import 'admin_settings_screen.dart';
import 'admin_statistical_dashboard.dart';
import 'user_management_screen.dart';
import '../services/firebase_notification_service.dart';
// Đảm bảo bạn đã import file này:
import 'admin_chat_list.dart'; 

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String adminName = "Đang tải...";
  String adminEmail = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadAdminData();
  }

  Future<void> _initializeNotifications() async {
    try {
      await FirebaseNotificationService().initialize();
      await FirebaseNotificationService().subscribeAdminToUpdates();
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }

  Future<void> _loadAdminData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        setState(() {
          adminEmail = currentUser.email ?? "admin@example.com";
        });
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('name')) {
            setState(() {
              adminName = data['name'];
            });
          } else {
            setState(() {
              adminName = "Administrator";
            });
          }
        }
      }
    } catch (e) {
      print("Lỗi tải thông tin Admin: $e");
      setState(() {
        adminName = "Lỗi kết nối";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1565C0)),
              accountName: Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              accountEmail: Text(adminEmail),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, color: Color(0xFF1565C0), size: 40),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Bảng điều khiển"),
              onTap: () => Navigator.pop(context),
            ),

            // 🔥 MỤC TIN NHẮN MỚI
            ListTile(
              leading: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('chats').where('isRead', isEqualTo: false).snapshots(),
                builder: (context, snapshot) {
                  int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.chat_bubble),
                  );
                },
              ),
              title: const Text("Tin nhắn hỗ trợ"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminChatList()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Quản lý tài khoản"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen()));
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Nhật ký hoạt động"),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Cài đặt hệ thống"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen()));
              },
            ),

            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminSettingsScreen())),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Xin chào $adminName 👋", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildCard(icon: Icons.analytics, title: "Thống kê", color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminStatisticalDashboard()))),
                  _buildCard(icon: Icons.list_alt, title: "Tất cả yêu cầu", color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestListScreen()))),
                  _buildCard(icon: Icons.pending_actions, title: "Chờ xử lý", color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestListScreen(initialStatus: RequestStatus.pending)))),
                  _buildCard(icon: Icons.engineering, title: "Đang xử lý", color: Colors.indigo, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestListScreen(initialStatus: RequestStatus.processing)))),
                  _buildCard(icon: Icons.check_circle, title: "Đã duyệt", color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestListScreen(initialStatus: RequestStatus.approved)))),
                  _buildCard(icon: Icons.cancel, title: "Từ chối", color: Colors.red, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminRequestListScreen(initialStatus: RequestStatus.rejected)))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn đăng xuất không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Huỷ")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Đăng xuất")),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }
}