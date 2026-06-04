import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/request_model.dart';
import '../providers/theme_provider.dart';
import '../repository/request_repository.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  static final RequestRepository _repository = RequestRepository();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Sinh viên: ${currentUser?.email?.split("@").first ?? ""}'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: Text('Vui lòng đăng nhập lại.'))
          : StreamBuilder<List<RequestModel>>(
              stream: _repository.watchStudentRequests(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Lỗi tải dữ liệu: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Bạn chưa tạo yêu cầu hành chính nào.'),
                  );
                }

                final requests = snapshot.data!;
                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(request.title),
                        subtitle: Text(request.content),
                        trailing: Chip(
                          label: Text(request.status.text),
                          backgroundColor: request.status.color.withValues(
                            alpha: 0.2,
                          ),
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
