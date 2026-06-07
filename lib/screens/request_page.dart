import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; 

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  // Hàm cấu hình Màu sắc chủ đạo theo từng Trạng thái đơn
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã duyệt':
        return const Color(0xFF2E7D32); // Xanh lá cây sâu lắng
      case 'Từ chối':
        return const Color(0xFFC62828); // Đỏ quyền lực
      case 'Chờ duyệt':
      default:
        return const Color(0xFFEF6C00); // Cam hiện đại
    }
  }

  // Hàm cấu hình Icon hiển thị trực quan theo Trạng thái
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Đã duyệt':
        return Icons.check_circle_rounded;
      case 'Từ chối':
        return Icons.cancel_rounded;
      case 'Chờ duyệt':
      default:
        return Icons.pending_actions_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Vui lòng đăng nhập để xem danh sách", 
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Màu nền xám Slate cực nhẹ siêu sang trọng
      
      // CHUẨN UI MỚI: AppBar làm tiêu đề duy nhất, thanh thoát và tiết kiệm diện tích màn hình
      appBar: AppBar(
        title: const Text(
          "Yêu cầu của tôi",
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
            letterSpacing: 0.5,
            color: Color.fromARGB(255, 235, 240, 243),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 30, 95, 225), // Màu xanh đồng bộ hệ thống của bạn
        elevation: 0,
      ),
      
      body: StreamBuilder<QuerySnapshot>(
        // Lọc realtime theo User Đăng nhập (Xử lý sort bằng Dart ở dưới để KHÔNG BỊ BÁO LỖI INDEX)
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: currentUser.uid) 
            .snapshots(), 
        builder: (context, snapshot) {
          // 1. Trường hợp xảy ra lỗi hệ thống
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Đã xảy ra lỗi hệ thống: ${snapshot.error}",
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          // 2. Trường hợp đang tải dữ liệu từ Firestore lần đầu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
              ),
            );
          }

          // 3. Trường hợp danh sách trống (Sinh viên chưa tạo đơn nào)
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 85, color: Colors.blueGrey[200]),
                  const SizedBox(height: 16),
                  Text(
                    "Bạn chưa tạo yêu cầu hành chính nào.",
                    style: TextStyle(fontSize: 16, color: Colors.blueGrey[400], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }

          // CHUYỂN ĐỔI DỮ LIỆU & TỰ ĐỘNG SẮP XẾP BẰNG DART (Đơn mới nhất luôn lên đầu)
          List<QueryDocumentSnapshot> requests = List.from(snapshot.data!.docs);
          requests.sort((a, b) {
            final Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
            final Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;
            final Timestamp? timeA = dataA['createdAt'] as Timestamp?;
            final Timestamp? timeB = dataB['createdAt'] as Timestamp?;
            if (timeA == null && timeB == null) return 0;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            return timeB.compareTo(timeA);
          });

          // 4. Trường hợp hiển thị danh sách dạng thẻ Card thông minh
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestData = requests[index].data() as Map<String, dynamic>;
              
              final String title = requestData['title'] ?? 'Không có tiêu đề';
              final String content = requestData['content'] ?? 'Không có nội dung';
              final String status = requestData['status'] ?? 'Chờ duyệt';
              
              // Cấu hình định dạng hiển thị Thời gian Ngày/Tháng/Năm - Giờ:Phút
              String formattedDate = "Đang cập nhật...";
              if (requestData['createdAt'] != null && requestData['createdAt'] is Timestamp) {
                final Timestamp timestamp = requestData['createdAt'] as Timestamp;
                final DateTime dateTime = timestamp.toDate();
                formattedDate = DateFormat('dd/MM/yyyy - HH:mm').format(dateTime);
              }

              final Color statusColor = _getStatusColor(status);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16), // Bo tròn góc thẻ mượt mà
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03), // Đổ bóng mờ cực nhẹ
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Theme(
                  // Ẩn các đường lằn gạch ngang mặc định rất thô của ExpansionTile
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: ValueKey(requests[index].id),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    
                    // Khối hình tròn chứa Icon trạng thái bên trái thẻ
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1), // Nền nhạt đồng bộ màu trạng thái
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(status),
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                    
                    // Tiêu đề đơn yêu cầu
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 15, 
                        color: Color(0xFF1E293B) // Mã màu xám đậm Slate lịch lãm
                      ),
                    ),
                    
                    // Dòng hiển thị ngày tháng gửi đơn
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                    ),
                    
                    // Nhãn Badge trạng thái nằm góc bên phải thẻ đơn
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    
                    // Phần nội dung ẩn bên trong, tự động mở rộng ra khi Click bấm vào thẻ
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(color: Color(0xFFF1F5F9), thickness: 1), // Đường vạch chia nhẹ nhàng
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.description_rounded, size: 16, color: Colors.blueGrey[400]),
                                const SizedBox(width: 6),
                                const Text(
                                  "Chi tiết nội dung giải trình:",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: Color(0xFF475569),
                                    fontSize: 13
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            
                            // Hộp Container bo khung văn bản giải trình chi tiết
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                content,
                                style: const TextStyle(
                                  color: Color(0xFF334155), 
                                  height: 1.4,
                                  fontSize: 13
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
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