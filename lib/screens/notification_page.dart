import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  Future<void> _markAsRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'isRead': true});
  }

  Future<void> _markAllAsRead(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông báo"),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(user!.uid),
            child: const Text("Đọc tất cả",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty)
            return const Center(child: Text("Không có thông báo nào"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;
              final date = (data['createdAt'] as Timestamp?)?.toDate();

              return ListTile(
                tileColor: isRead ? null : Colors.blue.shade50,
                leading: CircleAvatar(
                  backgroundColor:
                      isRead ? Colors.grey.shade200 : Colors.blue.shade100,
                  child: Icon(
                    Icons.notifications,
                    color: isRead ? Colors.grey : Colors.blue,
                  ),
                ),
                title: Text(
                  data['title'] ?? '',
                  style: TextStyle(
                    fontWeight:
                        isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['body'] ?? ''),
                    if (date != null)
                      Text(
                        DateFormat('HH:mm dd/MM/yyyy').format(date),
                        style: const TextStyle(fontSize: 11),
                      ),
                  ],
                ),
                onTap: () => _markAsRead(docs[index].id),
              );
            },
          );
        },
      ),
    );
  }
}