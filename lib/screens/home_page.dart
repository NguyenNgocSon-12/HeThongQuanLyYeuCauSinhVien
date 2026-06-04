import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// ================= HEADER =================
            Container(
              margin: const EdgeInsets.all(20),

              padding: const EdgeInsets.all(22),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),

                gradient: const LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.25),

                    blurRadius: 20,

                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                children: [
                  /// ================= USER INFO =================
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 32,

                        backgroundColor: Colors.white,

                        child: Icon(
                          Icons.person,
                          color: Color(0xFF1565C0),
                          size: 38,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: const [
                            Text(
                              "Xin chào 👋",

                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Nguyễn Văn A",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 3),

                            Text(
                              "MSSV: 22110234",

                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// ================= STATS =================
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "05",
                          "Đang xử lý",
                          Icons.pending_actions_rounded,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildStatCard(
                          "12",
                          "Hoàn thành",
                          Icons.check_circle_rounded,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildStatCard(
                          "02",
                          "Từ chối",
                          Icons.cancel_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ================= QUICK MENU =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  _quickMenu(Icons.history_rounded, "Tiến độ", Colors.orange),

                  _quickMenu(
                    Icons.analytics_rounded,
                    "Thống kê",
                    Colors.purple,
                  ),

                  _quickMenu(
                    Icons.support_agent_rounded,
                    "Hỗ trợ",
                    Colors.green,
                  ),

                  _quickMenu(Icons.help_outline_rounded, "FAQ", Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ================= TITLE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: const [
                  Text(
                    "Yêu cầu gần đây",

                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "Xem tất cả",

                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// ================= REQUEST LIST =================
            _buildRequestCard(
              icon: Icons.description_outlined,

              title: "Xin giấy xác nhận sinh viên",

              time: "2 giờ trước",

              status: "Đang xử lý",

              color: Colors.orange,
            ),

            _buildRequestCard(
              icon: Icons.school_outlined,

              title: "Đăng ký thực tập doanh nghiệp",

              time: "Hôm qua",

              status: "Hoàn thành",

              color: Colors.green,
            ),

            _buildRequestCard(
              icon: Icons.credit_card_outlined,

              title: "Cấp lại thẻ sinh viên",

              time: "3 ngày trước",

              status: "Từ chối",

              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// ================= STAT CARD =================
  Widget _buildStatCard(String value, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),

          const SizedBox(height: 8),

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,

            textAlign: TextAlign.center,

            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// ================= QUICK MENU =================
  Widget _quickMenu(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),

            shape: BoxShape.circle,
          ),

          child: Icon(icon, color: color, size: 28),
        ),

        const SizedBox(height: 8),

        Text(
          title,

          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }

  /// ================= REQUEST CARD =================
  Widget _buildRequestCard({
    required IconData icon,
    required String title,
    required String time,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),

            blurRadius: 10,
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  time,

                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),

              borderRadius: BorderRadius.circular(30),
            ),

            child: Text(
              status,

              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
