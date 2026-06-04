import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Sử dụng đường dẫn tương đối để tránh lỗi package không tồn tại
import '../providers/theme_provider.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationEnabled = true;
  @override
  Widget build(BuildContext context) {
    // Lấy instance của Provider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("Cài đặt"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ... (Phần Header giữ nguyên)
          const SizedBox(height: 25),

          _sectionTitle("Thông báo"),
          const SizedBox(height: 12),
          _buildCard(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_active, color: Colors.orange),
              title: const Text("Nhận thông báo"),
              subtitle: const Text("Cập nhật trạng thái yêu cầu"),
              value: notificationEnabled,
              onChanged: (value) => setState(() => notificationEnabled = value),
            ),
          ),

          const SizedBox(height: 25),

          _sectionTitle("Giao diện"),
          const SizedBox(height: 12),
          _buildCard(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode, color: Colors.indigo),
              title: const Text("Dark Mode"),
              subtitle: const Text("Bật chế độ nền tối"),
              // Kết nối value với themeProvider
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                // Gọi hàm toggle của provider
                themeProvider.toggleTheme();
              },
            ),
          ),
          
          // ... (Phần App Info giữ nguyên)
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1565C0)));
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }
}