import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/request_model.dart';
import '../repository/request_repository.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  static final RequestRepository _repository = RequestRepository();

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để xem danh sách')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Yêu cầu của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 30, 95, 225),
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: _repository.watchStudentRequests(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Không thể tải yêu cầu: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!;
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 85,
                    color: Colors.blueGrey[200],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn chưa tạo yêu cầu hành chính nào.',
                    style: TextStyle(color: Colors.blueGrey[400]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) =>
                _RequestTile(request: requests[index]),
          );
        },
      ),
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    final statusColor = request.status.color;
    final formattedDate = DateFormat(
      'dd/MM/yyyy - HH:mm',
    ).format(request.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: ValueKey(request.id),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_statusIcon(request.status), color: statusColor),
          ),
          title: Text(
            request.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1E293B),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Text(formattedDate, style: TextStyle(color: Colors.grey[500])),
                if (!request.isSynced) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.cloud_off, size: 14, color: Colors.orange),
                ],
              ],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              request.status.text,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  Text(
                    request.content,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                  if (request.adminNote != null &&
                      request.adminNote!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Ghi chú xử lý: ${request.adminNote}',
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Icons.pending_actions_rounded;
      case RequestStatus.processing:
        return Icons.autorenew_rounded;
      case RequestStatus.approved:
        return Icons.check_circle_rounded;
      case RequestStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}
