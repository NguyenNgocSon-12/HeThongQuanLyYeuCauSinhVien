import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Header với SLiiverAppBar để hiệu ứng đẹp hơn
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("HUIT APP - Giới thiệu"),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded, size: 80, color: Colors.white24),
                ),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle("Trường Đại học Công Thương TP.HCM"),
                _buildBodyText("HUIT là ngôi trường tiên phong trong lĩnh vực đào tạo thực hành, gắn kết chặt chẽ với nhu cầu của doanh nghiệp và xã hội. Ứng dụng này là cầu nối số giúp sinh viên và nhà trường gần nhau hơn."),
                
                const SizedBox(height: 25),
                _buildSectionTitle("Về Ứng dụng"),
                _buildBodyText("HUIT Request Manager là giải pháp chuyển đổi số toàn diện cho quy trình hành chính tại Khoa. Ứng dụng giúp bạn:"),
                const SizedBox(height: 10),
                _buildFeatureItem(Icons.document_scanner, "Gửi đơn từ trực tuyến mọi lúc mọi nơi."),
                _buildFeatureItem(Icons.notifications_active, "Nhận thông báo trạng thái xử lý tức thời."),
                _buildFeatureItem(Icons.history_edu, "Tra cứu lịch sử yêu cầu minh bạch."),
                _buildFeatureItem(Icons.security, "Bảo mật dữ liệu cá nhân theo quy định."),

                const SizedBox(height: 25),
                _buildSectionTitle("Liên hệ hỗ trợ"),
                _buildContactCard(context),

                const SizedBox(height: 30),
                Center(
                  child: Text("Phiên bản 1.0.0 | © 2026 HUIT Tech", 
                    style: TextStyle(color: theme.hintColor, fontSize: 12)),
                ),
                const SizedBox(height: 50),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(text, style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700]));
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text("Email Khoa"),
              subtitle: const Text("KhoaCNTT@huit.edu.vn"),
              onTap: () {}, // Thêm logic mở mail
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.web),
              title: const Text("Website Trường"),
              subtitle: const Text("huit.edu.vn"),
              onTap: () {}, // Thêm logic mở web
            ),
          ],
        ),
      ),
    );
  }
}