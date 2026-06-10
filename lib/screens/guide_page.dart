import 'package:flutter/material.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> steps = [
      {"icon": Icons.login_rounded, "title": "Đăng nhập", "desc": "Sử dụng email sinh viên HUIT để truy cập vào hệ thống an toàn."},
      {"icon": Icons.add_circle_outline_rounded, "title": "Tạo yêu cầu", "desc": "Chọn loại yêu cầu phù hợp và nhập nội dung cụ thể để Khoa xử lý."},
      {"icon": Icons.attach_file_rounded, "title": "Đính kèm minh chứng", "desc": "Tải ảnh hoặc tài liệu liên quan giúp yêu cầu của bạn thêm thuyết phục."},
      {"icon": Icons.send_rounded, "title": "Gửi yêu cầu", "desc": "Nhấn nút 'Gửi' và hệ thống sẽ tự động chuyển yêu cầu đến bộ phận tiếp nhận."},
      {"icon": Icons.notifications_active_rounded, "title": "Theo dõi kết quả", "desc": "Nhận thông báo cập nhật trạng thái xử lý ngay khi có kết quả mới."},
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Hướng dẫn sử dụng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Header mô tả ngắn gọn
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Các bước thực hiện:",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // Danh sách các bước dạng Card
            ...List.generate(steps.length, (index) {
              return _buildModernStepCard(steps[index], index + 1, theme, colorScheme);
            }),

            const SizedBox(height: 20),
            // Footer hỗ trợ
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.support_agent_rounded, size: 32, color: colorScheme.primary),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bạn cần trợ giúp?", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                        const Text("Liên hệ bộ phận kỹ thuật qua email hoặc Hotline trong phần Cài đặt.", style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStepCard(Map<String, dynamic> step, int number, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Số thứ tự nổi bật
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text("$number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              ),
            ),
            const SizedBox(width: 16),
            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(step['icon'], size: 16, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(step['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(step['desc'], style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}