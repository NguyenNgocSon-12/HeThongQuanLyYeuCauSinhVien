import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final TextEditingController contentController = TextEditingController();

  final List<String> templates = [
    "Xin giấy xác nhận sinh viên",
    "Xin nghỉ học",
    "Xin cấp lại thẻ sinh viên",
    "Đăng ký học phần",
    "Khác",
  ];

  String? selectedTemplate;
  bool _isLoading = false; // Quản lý trạng thái vòng xoay loading

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  // Logic đẩy dữ liệu yêu cầu hành chính lên Firebase Firestore
  void _submitRequest() async {
    if (selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn loại yêu cầu"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập nội dung chi tiết"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true); // Bật hiệu ứng loading, khóa UI

    try {
      // 1. LẤY LIÊN KẾT TÀI KHOẢN ĐANG LOGIN TỪ FIREBASE AUTH (Cực kỳ bảo mật)
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      String mssv = "UNKNOWN";
      String studentName = "Ẩn danh";

      if (currentUser != null) {
        // Tận dụng email để cắt ra MSSV phòng trường hợp SharedPreferences lỗi
        if (currentUser.email != null && currentUser.email!.contains('@')) {
          mssv = currentUser.email!.split('@')[0];
        }

        // Truy vấn ngược vào Firestore để lấy thêm Họ Tên thật của sinh viên
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
            
        if (userDoc.exists && userDoc.data() != null) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          studentName = userData['name'] ?? "Ẩn danh";
          if (userData['mssv'] != null) mssv = userData['mssv'];
        }
      }

      // Dự phòng: Nếu Firebase Auth trục trặc, vẫn cố gắng đọc từ SharedPreferences
      if (mssv == "UNKNOWN") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        mssv = prefs.getString('studentMssv') ?? prefs.getString('mssv') ?? "UNKNOWN";
      }

      // 2. ĐẨY DATA REALTIME LÊN FIRESTORE COLLECTION 'REQUESTS'
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': currentUser?.uid ?? "",         // ID tài khoản để phân quyền bộ lọc về sau
        'studentMssv': mssv,                      // Mã số sinh viên
        'studentName': studentName,              // Họ tên sinh viên (Thêm mới giúp Cán bộ dễ đọc)
        'title': selectedTemplate,                // Loại yêu cầu hành chính
        'content': contentController.text.trim(), // Nội dung giải trình
        'status': 'Chờ duyệt',                     // Trạng thái khởi tạo mặc định
        'createdAt': FieldValue.serverTimestamp(),// Thời gian máy chủ Firebase
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gửi thành công yêu cầu: $selectedTemplate'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Quay về màn hình Dashboard sinh viên
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối Firebase: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // Tắt hiệu ứng loading
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      /// ================= APPBAR =================
      appBar: AppBar(
        title: const Text("Tạo yêu cầu mới"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),

      /// ================= BODY =================
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1565C0)),
                  ),
                  SizedBox(height: 15),
                  Text("Hệ thống đang gửi dữ liệu lên Firestore...", 
                       style: TextStyle(color: Colors.blueGrey, fontSize: 14)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// ================= HEADER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1565C0),
                          Color(0xFF42A5F5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.edit_document,
                              color: Colors.white,
                              size: 32,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Gửi yêu cầu",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          "Điền đầy đủ thông tin để Khoa CNTT xử lý nhanh hơn.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ================= FORM CARD =================
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ================= REQUEST TYPE =================
                        const Text(
                          "Loại yêu cầu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedTemplate,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.list_alt),
                            hintText: "Chọn loại yêu cầu",
                            filled: true,
                            fillColor: const Color(0xFFF3F6FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: templates.map((template) {
                            return DropdownMenuItem(
                              value: template,
                              child: Text(template),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTemplate = value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        /// ================= CONTENT =================
                        const Text(
                          "Nội dung chi tiết",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: contentController,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: "Nhập nội dung yêu cầu cụ thể...",
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: const Color(0xFFF3F6FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ================= ATTACH FILE =================
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Chức năng upload file minh chứng sẽ được cập nhật ở phiên bản sau"),
                              ),
                            );
                          },
                          icon: const Icon(Icons.attach_file),
                          label: const Text("Đính kèm minh chứng"),
                        ),

                        const SizedBox(height: 28),

                        /// ================= SUBMIT BUTTON =================
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1565C0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _submitRequest, 
                            icon: const Icon(Icons.send, color: Colors.white),
                            label: const Text(
                              "Gửi yêu cầu",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
}