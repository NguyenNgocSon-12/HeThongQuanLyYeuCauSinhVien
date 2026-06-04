import 'package:flutter/material.dart';

import '../models/request_model.dart';
import '../repository/request_repository.dart';
import '../widgets/request_admin_card.dart';

class AdminRequestListScreen extends StatefulWidget {
  const AdminRequestListScreen({super.key});

  @override
  State<AdminRequestListScreen> createState() => _AdminRequestListScreenState();
}

class _AdminRequestListScreenState extends State<AdminRequestListScreen> {
  final RequestRepository _repository = RequestRepository();

  String searchText = '';
  RequestStatus? selectedStatus;
  RequestType? selectedType;
  late Stream<List<RequestModel>> _requestsStream;

  @override
  void initState() {
    super.initState();
    _refreshStream();
  }

  void _refreshStream() {
    _requestsStream = _repository.watchAdminRequests(
      status: selectedStatus,
      type: selectedType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F5),
      appBar: AppBar(
        title: const Text('Danh sách yêu cầu'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => searchText = value),
                  decoration: InputDecoration(
                    hintText: 'Tìm MSSV, tên hoặc tiêu đề...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _FilterBox(
                        child: DropdownButton<RequestStatus?>(
                          value: selectedStatus,
                          underline: const SizedBox(),
                          hint: const Text('Trạng thái'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả trạng thái'),
                            ),
                            ...RequestStatus.values.map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.text),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                              _refreshStream();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _FilterBox(
                        child: DropdownButton<RequestType?>(
                          value: selectedType,
                          underline: const SizedBox(),
                          hint: const Text('Loại'),
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả loại'),
                            ),
                            ...RequestType.values.map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.text),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedType = value;
                              _refreshStream();
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
          Expanded(
            child: StreamBuilder<List<RequestModel>>(
              stream: _requestsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Không thể tải dữ liệu: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = _filterBySearch(snapshot.data!);
                if (requests.isEmpty) {
                  return const Center(child: Text('Không tìm thấy dữ liệu'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return RequestAdminCard(
                      request: requests[index],
                      onUpdated: () {},
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

  List<RequestModel> _filterBySearch(List<RequestModel> requests) {
    final keyword = searchText.trim().toLowerCase();
    if (keyword.isEmpty) return requests;

    return requests.where((request) {
      return request.studentId.toLowerCase().contains(keyword) ||
          request.studentName.toLowerCase().contains(keyword) ||
          request.title.toLowerCase().contains(keyword);
    }).toList();
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
