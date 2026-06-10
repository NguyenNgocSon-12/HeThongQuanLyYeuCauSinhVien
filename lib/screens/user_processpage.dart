import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPage extends StatelessWidget {
  final String requestId;

  const ProgressPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tiến độ xử lý")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').doc(requestId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final int currentStatus = data['status'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(data['title'] ?? "Yêu cầu", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildTimelineItem("Chờ xử lý", "Yêu cầu của bạn đã được ghi nhận.", 0, currentStatus, true),
              _buildTimelineItem("Đang xử lý", "Phòng ban chức năng đang xem xét.", 1, currentStatus, false),
              _buildTimelineItem("Đã hoàn tất", "Kết quả đã được cập nhật.", 2, currentStatus, true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(String title, String desc, int index, int current, bool isLast) {
    bool isCompleted = current >= index;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.blue : Colors.grey.shade300,
              ),
              child: Icon(isCompleted ? Icons.check : Icons.circle, color: Colors.white, size: 16),
            ),
            if (!isLast)
              Container(width: 2, height: 50, color: isCompleted ? Colors.blue : Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isCompleted ? Colors.blue : Colors.grey)),
              Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }
}