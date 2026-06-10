import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Liên hệ hỗ trợ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Banner chào mừng
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Icon(Icons.support_agent_rounded, size: 60, color: colorScheme.primary),
                  const SizedBox(height: 15),
                  const Text(
                    "Chúng tôi luôn sẵn sàng hỗ trợ bạn",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Nếu bạn gặp khó khăn trong việc gửi yêu cầu hoặc có thắc mắc về quy trình, đừng ngần ngại liên hệ với chúng tôi.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Các kênh liên hệ
            _buildContactOption(
              icon: Icons.email_rounded,
              title: "Email hỗ trợ",
              subtitle: "huit.support@huit.edu.vn",
              color: Colors.redAccent,
              onTap: () {}, // Thêm logic mailto:
            ),
            _buildContactOption(
              icon: Icons.phone_in_talk_rounded,
              title: "Hotline (Giờ hành chính)",
              subtitle: "028 3894 0390",
              color: Colors.green,
              onTap: () {}, // Thêm logic tel:
            ),
            _buildContactOption(
              icon: Icons.location_on_rounded,
              title: "Địa chỉ Khoa",
              subtitle: "140 Lê Trọng Tấn, P. Tây Thạnh, Q. Tân Phú, TP.HCM",
              color: Colors.blue,
              onTap: () {}, // Thêm logic Google Maps
            ),

            const SizedBox(height: 30),
            // Nút "Gửi phản hồi nhanh"
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {}, // Thêm logic mở form phản hồi
                icon: const Icon(Icons.message_rounded),
                label: const Text("Gửi phản hồi cho chúng tôi"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, // Hoặc dùng theme.cardColor
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}