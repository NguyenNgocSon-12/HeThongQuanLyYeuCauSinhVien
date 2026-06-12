import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart'; // Import thư viện

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final TextEditingController contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // Khởi tạo Cloudinary (Thay bằng thông tin của bạn)
  final cloudinary = CloudinaryPublic('dzn50c2ri', 'qlycsv', cache: false);

  final List<String> templates = [
    "Xin giấy xác nhận sinh viên",
    "Xin nghỉ học",
    "Xin cấp lại thẻ sinh viên",
    "Xin hoãn thi",
    "Đăng ký học phần",
    "Đăng ký học phần lại",
    "Đăng ký học phần thay thế",
    "Khác",
  ];

  String? selectedTemplate;
  bool _isLoading = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh: $e");
    }
  }

  void _submitRequest() async {
    if (selectedTemplate == null || contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ thông tin!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // 1. Upload ảnh lên Cloudinary thay vì Firebase Storage
      if (_selectedImage != null) {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImage!.path,
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        imageUrl = response.secureUrl; // Lấy URL từ Cloudinary
      }

      // 2. Lưu vào Firestore
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'title': selectedTemplate,
        'content': contentController.text,
        'status': "Chờ duyệt",
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl, // Lưu đường dẫn ảnh từ Cloudinary
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gửi yêu cầu thành công!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Lỗi khi gửi: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  // ... (Phần UI build giữ nguyên như cũ) ...
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Tạo yêu cầu mới"), centerTitle: true),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ... UI giữ nguyên các thành phần khác ...
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
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
                          "Điền đầy đủ thông tin để Khoa xử lý nhanh hơn.",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: selectedTemplate,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.list_alt),
                            filled: true,
                            fillColor: theme.canvasColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            labelText: "Loại yêu cầu",
                          ),
                          items: templates
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedTemplate = v),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: contentController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: "Nội dung yêu cầu...",
                            filled: true,
                            fillColor: theme.canvasColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Material(
                          color: theme.canvasColor,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _pickImage,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.attach_file,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _selectedImage == null
                                          ? "Đính kèm minh chứng"
                                          : "Đã chọn ảnh",
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_selectedImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_selectedImage!, height: 120),
                            ),
                          ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
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
                ],
              ),
            ),
    );
  }
}
