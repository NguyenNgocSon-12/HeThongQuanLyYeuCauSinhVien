import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/request_model.dart';
import '../repository/request_repository.dart';
import '../services/auth_service.dart';
import '../services/request_validator.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final TextEditingController contentController = TextEditingController();
  final AuthService _authService = AuthService();
  final RequestRepository _requestRepository = RequestRepository();

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

  Future<void> _submitRequest() async {
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
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw const RequestValidationException(
          'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        );
      }

      final profile = await _authService.getUserProfile(currentUser.uid);
      final fallbackMssv = currentUser.email?.split('@').first ?? '';

      final request = RequestModel(
        userId: currentUser.uid,
        studentId: profile?.mssv ?? fallbackMssv,
        studentName: profile?.fullName ?? 'Chưa cập nhật họ tên',
        title: selectedTemplate!,
        content: contentController.text,
        type: RequestType.fromTitle(selectedTemplate!),
      );

      final savedRequest = await _requestRepository.createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              savedRequest.isSynced
                  ? 'Gửi thành công yêu cầu: $selectedTemplate'
                  : 'Đã lưu ngoại tuyến. Yêu cầu sẽ tự đồng bộ khi có mạng.',
            ),
            backgroundColor: savedRequest.isSynced
                ? Colors.green
                : Colors.orange,
          ),
        );
        Navigator.pop(context); // Quay về màn hình Dashboard sinh viên
      }
    } on RequestValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi yêu cầu: $e'),
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF1565C0),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    "Hệ thống đang gửi dữ liệu lên Firestore...",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                  ),
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
                        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.2),
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
                          style: TextStyle(color: Colors.white70, fontSize: 14),
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
                          color: Colors.black.withValues(alpha: 0.05),
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
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: selectedTemplate,
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
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                                content: Text(
                                  "Chức năng upload file minh chứng sẽ được cập nhật ở phiên bản sau",
                                ),
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
