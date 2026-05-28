import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../widgets/request_admin_card.dart';

class AdminRequestListScreen extends StatefulWidget {
  const AdminRequestListScreen({super.key});

  @override
  State<AdminRequestListScreen> createState() =>
      _AdminRequestListScreenState();
}

class _AdminRequestListScreenState
    extends State<AdminRequestListScreen> {

  List<RequestModel> requests = [
    RequestModel(
      id: 1,
      title: "Xin giấy xác nhận",
      content: "Cần xác nhận sinh viên",
      studentName: "Nguyễn Văn A",
      studentId: "SV001",
      type: RequestType.confirm, // 🔥 thêm
    ),
    RequestModel(
      id: 2,
      title: "Xin nghỉ học",
      content: "Bận việc gia đình",
      studentName: "Trần Văn B",
      studentId: "SV002",
      type: RequestType.leave, // 🔥 thêm
    ),
  ];

  /// 🔍 SEARCH
  String searchText = "";

  /// 📂 FILTER STATUS
  RequestStatus? selectedStatus;

  /// 📂 FILTER TYPE 🔥
  RequestType? selectedType;

  List<RequestModel> get filteredList {
    return requests.where((r) {

      /// SEARCH
      final matchText =
          r.studentId.toLowerCase().contains(searchText.toLowerCase()) ||
          r.studentName.toLowerCase().contains(searchText.toLowerCase());

      /// STATUS
      final matchStatus =
          selectedStatus == null || r.status == selectedStatus;

      /// TYPE 🔥
      final matchType =
          selectedType == null || r.type == selectedType;

      return matchText && matchStatus && matchType;

    }).toList();
  }

  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F5),

      appBar: AppBar(
        title: const Text("Danh sách yêu cầu"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: Column(
        children: [

          /// 🔍 SEARCH + FILTER
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// SEARCH
                TextField(
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Tìm MSSV hoặc tên...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔥 FILTER ROW
                Row(
                  children: [

                    /// STATUS FILTER
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<RequestStatus?>(
                          value: selectedStatus,
                          underline: const SizedBox(),
                          hint: const Text("Trạng thái"),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Tất cả"),
                            ),
                            ...RequestStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.text),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    /// TYPE FILTER 🔥
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<RequestType?>(
                          value: selectedType,
                          underline: const SizedBox(),
                          hint: const Text("Loại"),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Tất cả"),
                            ),
                            ...RequestType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.text),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔥 LIST
          Expanded(
            child: filteredList.isEmpty
                ? const Center(
                    child: Text("Không tìm thấy dữ liệu"),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return RequestAdminCard(
                        request: filteredList[index],
                        onUpdated: reload,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}