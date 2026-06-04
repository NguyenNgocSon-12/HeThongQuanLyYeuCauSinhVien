import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/request_model.dart';
import '../repository/request_repository.dart';
import '../services/request_validator.dart';

class ProcessRequestScreen extends StatefulWidget {
  const ProcessRequestScreen(this.request, {super.key});

  final RequestModel request;

  @override
  State<ProcessRequestScreen> createState() => _ProcessRequestScreenState();
}

class _ProcessRequestScreenState extends State<ProcessRequestScreen> {
  final RequestRepository _repository = RequestRepository();
  final TextEditingController noteController = TextEditingController();

  late RequestModel _request;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    noteController.text = _request.adminNote ?? '';
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  Future<void> updateStatus(RequestStatus newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text("Bạn có chắc muốn chuyển sang '${newStatus.text}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final adminId = FirebaseAuth.instance.currentUser?.uid;
    if (adminId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phiên đăng nhập admin đã hết hạn.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updated = await _repository.updateStatus(
        request: _request,
        status: newStatus,
        adminId: adminId,
        note: noteController.text,
      );

      if (!mounted) return;
      setState(() => _request = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã cập nhật: ${newStatus.text}')));
    } on RequestValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.orange),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể cập nhật yêu cầu: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xử lý yêu cầu'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _request.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text('MSSV: ${_request.studentId}'),
                Text('Sinh viên: ${_request.studentName}'),
                const SizedBox(height: 10),
                Text('Nội dung:\n${_request.content}'),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Trạng thái: '),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _request.status.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _request.status.text,
                        style: TextStyle(
                          color: _request.status.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Ghi chú xử lý',
                    hintText: 'Nhập lý do duyệt / từ chối...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.autorenew),
                        label: const Text('Đang xử lý'),
                        onPressed: () => updateStatus(RequestStatus.processing),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Duyệt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () => updateStatus(RequestStatus.approved),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Từ chối'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => updateStatus(RequestStatus.rejected),
                      ),
                    ],
                  ),
                if (_request.processedAt != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  Text('Người xử lý: ${_request.processedBy ?? "N/A"}'),
                  Text(
                    'Thời gian: ${DateFormat("dd/MM/yyyy HH:mm").format(_request.processedAt!)}',
                  ),
                  if (_request.adminNote != null &&
                      _request.adminNote!.isNotEmpty)
                    Text('Ghi chú: ${_request.adminNote}'),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Quay lại'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
