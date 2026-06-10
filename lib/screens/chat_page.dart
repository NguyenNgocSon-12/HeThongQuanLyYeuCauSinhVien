import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatelessWidget {
  final String chatId; // Dùng UID của sinh viên làm ID cuộc hội thoại
  final TextEditingController _controller = TextEditingController();

  ChatPage({super.key, required this.chatId});

  // --- HÀM GỬI TIN NHẮN TỰ ĐỘNG TẠO CẤU TRÚC ---
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final String messageText = _controller.text.trim();
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    _controller.clear();

    // Dùng WriteBatch để đảm bảo tính nhất quán dữ liệu
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // 1. Cập nhật document chat chính (để danh sách chat hiển thị đúng)
    DocumentReference chatRef = FirebaseFirestore.instance.collection('chats').doc(chatId);
    batch.set(chatRef, {
      'lastMessage': messageText,
      'updatedAt': FieldValue.serverTimestamp(),
      'userId': userId,
    }, SetOptions(merge: true));

    // 2. Thêm tin nhắn vào sub-collection 'messages'
    DocumentReference messageRef = chatRef.collection('messages').doc();
    batch.set(messageRef, {
      'senderId': userId,
      'text': messageText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hỗ trợ từ Khoa"),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // --- DANH SÁCH TIN NHẮN ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Tin nhắn mới nhất nằm ở dưới cùng
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data = messages[index].data() as Map<String, dynamic>;
                    bool isMe = data['senderId'] == currentUserId;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFF1565C0) : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isMe ? const Radius.circular(15) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(15),
                          ),
                        ),
                        child: Text(
                          data['text'] ?? "",
                          style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // --- Ô NHẬP TIN NHẮN ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: const Color(0xFF1565C0),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}