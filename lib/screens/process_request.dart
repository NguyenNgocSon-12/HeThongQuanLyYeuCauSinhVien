import 'package:flutter/material.dart';
import 'package:doanltddfinal/models/request_model.dart';

class ProcessRequestScreen extends StatefulWidget {
  final RequestModel r;

  const ProcessRequestScreen(this.r, {super.key});

  @override
  State<ProcessRequestScreen> createState() => _ProcessRequestScreenState();
}

class _ProcessRequestScreenState extends State<ProcessRequestScreen> {

  final TextEditingController noteController = TextEditingController();

  void updateStatus(RequestStatus newStatus) async {
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

    setState(() {
      widget.r.status = newStatus;
      widget.r.adminNote = noteController.text;
      widget.r.processedBy = "Admin"; // sau này lấy từ login
      widget.r.processedAt = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Đã cập nhật: ${newStatus.text}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;

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

                /// STUDENT
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

                /// NOTE
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Ghi chú xử lý",
                    hintText: "Nhập lý do duyệt / từ chối...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// BUTTONS
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.autorenew),
                      label: const Text("Đang xử lý"),
                      onPressed: () =>
                          updateStatus(RequestStatus.processing),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("Duyệt"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () =>
                          updateStatus(RequestStatus.approved),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text("Từ chối"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () =>
                          updateStatus(RequestStatus.rejected),
                    ),
                  ],
                ),

                const Spacer(),

                /// INFO XỬ LÝ
                if (r.processedAt != null) ...[
                  const Divider(),
                  Text("Người xử lý: ${r.processedBy ?? "N/A"}"),
                  Text("Thời gian: ${r.processedAt}"),
                  if (r.adminNote != null && r.adminNote!.isNotEmpty)
                    Text("Ghi chú: ${r.adminNote}"),
                ],

                const SizedBox(height: 10),

                /// BACK
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
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
    );
  }
}