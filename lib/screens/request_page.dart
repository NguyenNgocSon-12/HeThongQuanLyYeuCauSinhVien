import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RequestPage extends StatelessWidget {
  const RequestPage({super.key});

  // HÀM CHUYỂN ĐỔI STATUS AN TOÀN
  String _getStatusText(dynamic status) {
    if (status is String) return status;
    switch (status) {
      case 0: return 'Chờ xử lý';
      case 1: return 'Đang xử lý';
      case 2: return 'Đã duyệt';
      case 3: return 'Từ chối';
      default: return 'Chờ duyệt';
    }
  }

  Color _getStatusColor(dynamic status, ColorScheme colorScheme) {
    String statusText = _getStatusText(status);
    switch (statusText) {
      case 'Đã duyệt': return Colors.green;
      case 'Từ chối': return Colors.red;
      default: return Colors.orange;
    }
  }

  IconData _getStatusIcon(dynamic status) {
    String statusText = _getStatusText(status);
    switch (statusText) {
      case 'Đã duyệt': return Icons.check_circle_rounded;
      case 'Từ chối': return Icons.cancel_rounded;
      default: return Icons.pending_actions_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Yêu cầu của tôi", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Lỗi hệ thống"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Chưa có yêu cầu nào."));
          }

          List<QueryDocumentSnapshot> requests = List.from(snapshot.data!.docs);
          requests.sort((a, b) {
            final t1 = (a.data() as Map)['createdAt'] as Timestamp?;
            final t2 = (b.data() as Map)['createdAt'] as Timestamp?;
            return (t2?.seconds ?? 0).compareTo(t1?.seconds ?? 0);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final data = requests[index].data() as Map<String, dynamic>;
              
              // Lấy dữ liệu thô (dynamic)
              final dynamic statusRaw = data['status'] ?? 'Chờ duyệt';
              final String statusText = _getStatusText(statusRaw);
              final Color statusColor = _getStatusColor(statusRaw, colorScheme);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                ),
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor.withOpacity(0.1),
                      child: Icon(_getStatusIcon(statusRaw), color: statusColor),
                    ),
                    title: Text(data['title'] ?? '...', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format((data['createdAt'] as Timestamp).toDate())),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          width: double.infinity,
                          decoration: BoxDecoration(color: theme.canvasColor, borderRadius: BorderRadius.circular(10)),
                          child: Text(data['content'] ?? '', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}