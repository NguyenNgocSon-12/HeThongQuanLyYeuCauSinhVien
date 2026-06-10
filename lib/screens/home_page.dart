import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'ten_requests_page.dart';
import 'chat_page.dart';
import 'user_processpage.dart';
import 'user_thongke.dart';
import 'faq_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  String name = "Sinh viên";
                  String mssv = "---";
                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    name = data['name'] ?? "Sinh viên";
                    mssv = data['mssv'] ?? "---";
                  }
                  return _buildHeader(name, mssv);
                },
              ),

              _buildFeatureRow(context),

              // --- TITLE ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Yêu cầu gần đây",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TenRequestsPage(),
                        ),
                      ),
                      child: const Text(
                        "Xem tất cả",
                        style: TextStyle(
                          color: Color(0xFF1565C0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- LIST YÊU CẦU ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('requests')
                    .where('userId', isEqualTo: user?.uid)
                    .orderBy('createdAt', descending: true)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      DateTime date = (data['createdAt'] is Timestamp)
                          ? (data['createdAt'] as Timestamp).toDate()
                          : DateTime.now();

                      // TRUYỀN THẲNG DỮ LIỆU THÔ VÀO ĐỂ HÀM TỰ XỬ LÝ
                      return _buildRequestCard(
                        context,
                        Icons.description_outlined,
                        data['title'] ?? 'Không tiêu đề',
                        DateFormat('dd/MM/yyyy').format(date),
                        data['status'], // Truyền dynamic: có thể là int 2, hoặc String "Chờ xử lý"
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HÀM TẠO 4 NÚT CHỨC NĂNG ---
  Widget _buildFeatureRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Thay đổi trong _buildFeatureRow của HomePage
          _buildCircleButton(
            icon: Icons.track_changes,
            label: "Tiến độ",
            color: Colors.blue.shade50,
            iconColor: Colors.blue,
            onTap: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              final snapshot = await FirebaseFirestore.instance
                  .collection('requests')
                  .where('userId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .get();

              if (snapshot.docs.isNotEmpty) {
                String latestRequestId = snapshot.docs.first.id;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProgressPage(requestId: latestRequestId),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Bạn chưa có yêu cầu nào để xem tiến độ"),
                  ),
                );
              }
            },
          ),
          _buildCircleButton(
            icon: Icons.bar_chart,
            label: "Thống kê",
            color: Colors.purple.shade50,
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsPage()),
              );
            },
          ),
          _buildCircleButton(
            icon: Icons.support_agent,
            label: "Hỗ trợ",
            color: Colors.green.shade50,
            iconColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatPage(chatId: FirebaseAuth.instance.currentUser!.uid),
                ),
              );
            },
          ),
          _buildCircleButton(
            icon: Icons.help_outline,
            label: "FAQ",
            color: Colors.orange.shade50,
            iconColor: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FAQPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String mssv) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 38),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Xin chào 👋",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "MSSV: $mssv",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- HÀM ĐÃ SỬA: XỬ LÝ AN TOÀN MỌI KIỂU DỮ LIỆU ---
  Widget _buildRequestCard(
    BuildContext context,
    IconData icon,
    String title,
    String time,
    dynamic statusRaw,
  ) {
    final theme = Theme.of(context);

    // Chuyển đổi mọi thứ về String hiển thị
    String statusText = "Chờ duyệt";
    if (statusRaw is int) {
      switch (statusRaw) {
        case 0:
          statusText = "Chờ xử lý";
          break;
        case 1:
          statusText = "Đang xử lý";
          break;
        case 2:
          statusText = "Đã duyệt";
          break;
        case 3:
          statusText = "Từ chối";
          break;
        default:
          statusText = statusRaw.toString();
      }
    } else if (statusRaw is String) {
      statusText = statusRaw;
    }

    // Xác định màu
    Color statusColor = statusText == 'Đã duyệt'
        ? Colors.green
        : (statusText == 'Từ chối' ? Colors.red : Colors.orange);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: statusColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: theme.hintColor, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
