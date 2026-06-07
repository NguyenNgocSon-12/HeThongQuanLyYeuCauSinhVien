import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../repository/firestore_request_repository.dart';
import '../widgets/request_admin_card.dart';

class AdminRequestListScreen extends StatefulWidget {
  final RequestStatus? initialStatus;
  const AdminRequestListScreen({super.key, this.initialStatus});

  @override
  State<AdminRequestListScreen> createState() =>
      _AdminRequestListScreenState();
}

class _AdminRequestListScreenState
    extends State<AdminRequestListScreen> {
  final FirestoreRequestRepository _repository =
      FirestoreRequestRepository();

  /// 🔍 SEARCH
  String searchText = "";

  /// 📂 FILTER STATUS
  RequestStatus? selectedStatus;

  /// 📂 FILTER TYPE
  RequestType? selectedType;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.initialStatus; 
  }

  List<RequestModel> _filterRequests(List<RequestModel> requests) {
    return requests.where((r) {
      // SEARCH
      final matchText =
          r.studentId.toLowerCase().contains(searchText.toLowerCase()) ||
          r.studentName.toLowerCase().contains(searchText.toLowerCase());

      // STATUS
      final matchStatus =
          selectedStatus == null || r.status == selectedStatus;

      // TYPE
      final matchType =
          selectedType == null || r.type == selectedType;

      return matchText && matchStatus && matchType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Danh sách yêu cầu"),
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
                    fillColor: Theme.of(context).cardColor,
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
                          color: Theme.of(context).cardColor,
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
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: isDark
                            ? Border.all(color: Colors.white.withOpacity(0.1)) 
                            : null,
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

          /// 🔥 REAL-TIME LIST FROM FIRESTORE
          Expanded(
            child: StreamBuilder<List<RequestModel>>(
              stream: _repository.getAllRequestsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("Không tìm thấy dữ liệu"),
                  );
                }

                final filteredList = _filterRequests(snapshot.data!);

                if (filteredList.isEmpty) {
                  return const Center(
                    child: Text("Không tìm thấy dữ liệu phù hợp"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return RequestAdminCard(
                      request: filteredList[index],
                      onUpdated: () {
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}