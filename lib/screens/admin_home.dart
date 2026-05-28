import 'package:flutter/material.dart';
import 'admin_request_list.dart';
import 'admin_settings_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F5), // 🔥 nền xám chuẩn

      /// 🔥 APPBAR
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,

        /// ⚙️ SETTINGS BUTTON
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),

      /// 🔥 BODY
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 👋 HEADER
            const Text(
              "Xin chào Admin 👋",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 GRID DASHBOARD
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [

                  _buildCard(
                    icon: Icons.list_alt,
                    title: "Tất cả yêu cầu",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AdminRequestListScreen(),
                        ),
                      );
                    },
                  ),

                  _buildCard(
                    icon: Icons.pending_actions,
                    title: "Chờ xử lý",
                    color: Colors.orange,
                    onTap: () {},
                  ),

                  _buildCard(
                    icon: Icons.engineering,
                    title: "Đang xử lý",
                    color: Colors.indigo,
                    onTap: () {},
                  ),

                  _buildCard(
                    icon: Icons.check_circle,
                    title: "Hoàn thành",
                    color: Colors.green,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 CARD DASHBOARD ĐẸP HƠN
  Widget _buildCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // 🔥 card nổi
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}