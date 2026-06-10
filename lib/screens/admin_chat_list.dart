import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doanltddfinal/screens/chat_page.dart';

class AdminChatList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hỗ trợ sinh viên"),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(child: Text("Không có yêu cầu hỗ trợ nào"));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final studentId = chats[index].id;
              final data = chats[index].data() as Map<String, dynamic>;

              // Sử dụng FutureBuilder để lấy tên sinh viên từ collection 'users'
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(studentId).get(),
                builder: (context, userSnapshot) {
                  String studentName = "Đang tải...";
                  
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    studentName = userData['name'] ?? "Sinh viên";
                  } else if (userSnapshot.hasError) {
                    studentName = "Lỗi tải tên";
                  }

                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF1565C0),
                      child: Icon(Icons.school, color: Colors.white),
                    ),
                    title: Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      data['lastMessage'] ?? "Bắt đầu hội thoại",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(chatId: studentId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}