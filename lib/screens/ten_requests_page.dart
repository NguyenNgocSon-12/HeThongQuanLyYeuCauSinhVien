import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TenRequestsPage extends StatelessWidget {
  const TenRequestsPage({super.key});

  // Hàm chuyển đổi status an toàn (Dùng chung cho cả int và String)
  String _getStatusText(dynamic status) {
    if (status is String) return status;
    switch (status) {
      case 0: return 'Chờ xử lý';
      case 1: return 'Đang xử lý';
      case 2: return 'Đã duyệt';
      case 3: return 'Từ chối';
      default: return 'Khác';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("10 Yêu cầu gần nhất", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có yêu cầu nào"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              
              // Lấy status dưới dạng dynamic
              final dynamic statusRaw = data['status'];
              final String statusText = _getStatusText(statusRaw);
              
              final DateTime date = (data['createdAt'] is Timestamp) 
                  ? (data['createdAt'] as Timestamp).toDate() 
                  : DateTime.now();
              
              // Màu sắc theo trạng thái đã được chuyển đổi sang chữ
              Color statusColor;
              if (statusText == 'Đã duyệt') {
                statusColor = Colors.green;
              } else if (statusText == 'Từ chối') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.orange;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Icon(Icons.assignment_rounded, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['title'] ?? 'Không tiêu đề', 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(DateFormat('HH:mm - dd/MM/yyyy').format(date), 
                              style: TextStyle(color: theme.hintColor, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}