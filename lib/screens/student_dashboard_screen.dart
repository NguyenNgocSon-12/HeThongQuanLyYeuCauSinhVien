import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({Key? key}) : super(key: key);

  @override
  _StudentDashboardScreenState createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  String _currentMssv = "";

  @override
  void initState() {
    super.initState();
    _loadStudentSession();
  }

  void _loadStudentSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentMssv = prefs.getString('studentMssv') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sinh viên: $_currentMssv'),
        actions: [
          // Nút bật/tắt Dark Mode bằng Provider
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          )
        ],
      ),
      body: _currentMssv.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              // Thực hiện xử lý FutureBuilder/StreamBuilder lấy dữ liệu động realtime
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('studentMssv', isEqualTo: _currentMssv)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Xử lý loading snapshot
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2. Xử lý error từ Firebase
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
                }

                // 3. Xử lý danh sách trống
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Bạn chưa tạo yêu cầu nào hành chính nào.'));
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    var doc = requests[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      child: ListTile(
                        title: Text(doc['title'] ?? 'Không tiêu đề'),
                        subtitle: Text(doc['content'] ?? ''),
                        trailing: Chip(
                          label: Text(doc['status'] ?? 'Chờ duyệt'),
                          backgroundColor: doc['status'] == 'Đã duyệt' ? Colors.green.shade200 : Colors.orange.shade200,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}