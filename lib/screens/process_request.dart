import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/request_model.dart';
import '../repository/firestore_request_repository.dart';
import '../services/firebase_storage_service.dart';
import '../services/firebase_notification_service.dart';

class ProcessRequestScreen extends StatefulWidget {
  final RequestModel request;

  const ProcessRequestScreen(this.request, {super.key});

  @override
  State<ProcessRequestScreen> createState() => _ProcessRequestScreenState();
}

class _ProcessRequestScreenState extends State<ProcessRequestScreen> {
  final TextEditingController noteController = TextEditingController();
  final FirestoreRequestRepository _repository =
      FirestoreRequestRepository();
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final FirebaseNotificationService _notificationService =
      FirebaseNotificationService();

  bool _isProcessing = false;
  File? _selectedFile;
  String? _uploadedFileUrl;

  @override
  void initState() {
    super.initState();
    noteController.text = widget.request.adminNote ?? '';
    _uploadedFileUrl = widget.request.evidenceFileUrl;
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick file: $e');
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) {
      _showErrorSnackBar('No file selected');
      return;
    }

    try {
      setState(() => _isProcessing = true);

      final fileUrl = await _storageService.uploadEvidenceFile(
        widget.request.id ?? 'temp',
        _selectedFile!,
      );

      setState(() {
        _uploadedFileUrl = fileUrl;
        _selectedFile = null;
      });

      _showSuccessSnackBar('File uploaded successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to upload file: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> updateStatus(RequestStatus newStatus) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text("Bạn có chắc muốn chuyển sang '${newStatus.text}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Huỷ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Đồng ý"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isProcessing = true);

      await _repository.processRequest(
        widget.request.id!,
        newStatus,
        noteController.text,
        "Admin",
        _uploadedFileUrl,
      );

      // Show notification
      await _notificationService.notifyRequestStatusUpdate(
        widget.request.studentId,
        newStatus.text,
      );

      _showSuccessSnackBar("Đã cập nhật: ${newStatus.text}");

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorSnackBar("Failed to update: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xử lý yêu cầu"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF21CBF3)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Text(
                    r.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// STUDENT INFO
                  Text("MSSV: ${r.studentId}"),
                  Text("Sinh viên: ${r.studentName}"),

                  const SizedBox(height: 10),

                  /// CONTENT
                  Text("Nội dung:\n${r.content}"),

                  const SizedBox(height: 20),

                  /// STATUS
                  Row(
                    children: [
                      const Text("Trạng thái: "),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: r.status.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r.status.text,
                          style: TextStyle(
                            color: r.status.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// ADMIN NOTE
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      labelText: "Ghi chú xử lý",
                      hintText: "Nhập lý do duyệt / từ chối...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// FILE UPLOAD SECTION
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.attach_file,
                                color: Colors.blue.shade600),
                            const SizedBox(width: 8),
                            const Text(
                              "Evidence File",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_uploadedFileUrl != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.check_circle,
                                          color: Colors.green.shade600),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          FirebaseStorageService
                                              .getFileNameFromUrl(
                                                  _uploadedFileUrl!),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: _isProcessing
                                      ? null
                                      : () async {
                                          try {
                                            await _storageService
                                                .deleteEvidenceFile(
                                                    _uploadedFileUrl!);
                                            setState(() =>
                                                _uploadedFileUrl = null);
                                            _showSuccessSnackBar(
                                                'File deleted');
                                          } catch (e) {
                                            _showErrorSnackBar(
                                                'Failed to delete file');
                                          }
                                        },
                                  tooltip: "Delete file",
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ] else if (_selectedFile != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.file_present,
                                          color: Colors.orange.shade600),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _selectedFile!.path
                                              .split('/')
                                              .last,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!_isProcessing)
                                  ElevatedButton.icon(
                                    onPressed: _uploadFile,
                                    icon: const Icon(Icons.cloud_upload,
                                        size: 16),
                                    label: const Text("Upload"),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _pickFile,
                          icon: const Icon(Icons.attach_file, size: 16),
                          label: Text(_selectedFile == null
                              ? "Choose File"
                              : "Change File"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ACTION BUTTONS
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.autorenew),
                        label: const Text("Đang xử lý"),
                        onPressed: _isProcessing
                            ? null
                            : () => updateStatus(RequestStatus.processing),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text("Duyệt"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () => updateStatus(RequestStatus.approved),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text("Từ chối"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: _isProcessing
                            ? null
                            : () => updateStatus(RequestStatus.rejected),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// PROCESSED INFO
                  if (widget.request.processedAt != null) ...[
                    const Divider(),
                    Text("Người xử lý: ${widget.request.processedBy ?? "N/A"}"),
                    Text(
                        "Thời gian: ${widget.request.processedAt.toString()}"),
                    if (widget.request.adminNote != null &&
                        widget.request.adminNote!.isNotEmpty)
                      Text("Ghi chú: ${widget.request.adminNote}"),
                  ],

                  const SizedBox(height: 10),

                  /// BACK BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () {
                        Navigator.pop(context, true);
                      },
                      child: const Text("Quay lại"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
