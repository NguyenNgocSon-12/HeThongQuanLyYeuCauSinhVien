import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class FirestoreRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'requests';

  // Create a new request
  Future<String> createRequest(RequestModel request) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'title': request.title,
        'content': request.content,
        'studentName': request.studentName,
        'studentId': request.studentId,
        'status': request.status.index,
        'type': request.type.index,
        'adminNote': request.adminNote,
        'processedBy': request.processedBy,
        'evidenceFileUrl': request.evidenceFileUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'processedAt': request.processedAt?.toIso8601String(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create request: $e');
    }
  }

  // Get all requests (with optional filtering)
  Future<List<RequestModel>> getAllRequests() async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch requests: $e');
    }
  }

  // Get requests by student ID
  Future<List<RequestModel>> getRequestsByStudentId(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch student requests: $e');
    }
  }

  // Get requests by status
  Future<List<RequestModel>> getRequestsByStatus(RequestStatus status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.index)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch requests by status: $e');
    }
  }

  // Get requests by type
  Future<List<RequestModel>> getRequestsByType(RequestType type) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('type', isEqualTo: type.index)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch requests by type: $e');
    }
  }

  // Search requests by student ID or name
  Future<List<RequestModel>> searchRequests(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      final lowerQuery = query.toLowerCase();
      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .where((request) =>
              request.studentId.toLowerCase().contains(lowerQuery) ||
              request.studentName.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw Exception('Failed to search requests: $e');
    }
  }

  // Update request status
  Future<void> updateRequestStatus(
      String requestId, RequestStatus newStatus) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': newStatus.index,
        'processedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }

  // Update request with full processing details
  Future<void> processRequest(
    String requestId,
    RequestStatus newStatus,
    String? adminNote,
    String processedBy,
    String? evidenceFileUrl,
  ) async {
    try {
      final updateData = {
        'status': newStatus.index,
        'adminNote': adminNote,
        'processedBy': processedBy,
        'processedAt': FieldValue.serverTimestamp(),
      };
      if (evidenceFileUrl != null) {
        updateData['evidenceFileUrl'] = evidenceFileUrl;
      }
      await _firestore
          .collection(_collection)
          .doc(requestId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to process request: $e');
    }
  }

  // Get a single request by ID
  Future<RequestModel?> getRequestById(String requestId) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(requestId)
          .get();
      if (doc.exists) {
        return _documentToRequest(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch request: $e');
    }
  }

  // Real-time stream of all requests
  Stream<List<RequestModel>> getAllRequestsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _documentToRequest(doc)).toList());
  }

  // Real-time stream of requests by status
  Stream<List<RequestModel>> getRequestsStreamByStatus(RequestStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.index)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _documentToRequest(doc)).toList());
  }

  // Get dashboard statistics
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      int total = snapshot.docs.length;
      int pending = 0;
      int processing = 0;
      int approved = 0;
      int rejected = 0;

      for (var doc in snapshot.docs) {
        final status = RequestStatus.values[doc['status'] ?? 0];
        switch (status) {
          case RequestStatus.pending:
            pending++;
            break;
          case RequestStatus.processing:
            processing++;
            break;
          case RequestStatus.approved:
            approved++;
            break;
          case RequestStatus.rejected:
            rejected++;
            break;
        }
      }

      return {
        'total': total,
        'pending': pending,
        'processing': processing,
        'approved': approved,
        'rejected': rejected,
      };
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

  // Real-time stream of dashboard statistics
  Stream<Map<String, int>> getDashboardStatsStream() {
    return _firestore.collection(_collection).snapshots().map((snapshot) {
      int total = snapshot.docs.length;
      int pending = 0;
      int processing = 0;
      int approved = 0;
      int rejected = 0;

      for (var doc in snapshot.docs) {
        final status = RequestStatus.values[doc['status'] ?? 0];
        switch (status) {
          case RequestStatus.pending:
            pending++;
            break;
          case RequestStatus.processing:
            processing++;
            break;
          case RequestStatus.approved:
            approved++;
            break;
          case RequestStatus.rejected:
            rejected++;
            break;
        }
      }

      return {
        'total': total,
        'pending': pending,
        'processing': processing,
        'approved': approved,
        'rejected': rejected,
      };
    });
  }

  // Delete request
  Future<void> deleteRequest(String requestId) async {
    try {
      await _firestore.collection(_collection).doc(requestId).delete();
    } catch (e) {
      throw Exception('Failed to delete request: $e');
    }
  }

  // Helper method to convert Firestore document to RequestModel
  RequestModel _documentToRequest(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  
  // Xử lý đọc trạng thái thông minh chống crash
  RequestStatus parsedStatus = RequestStatus.pending; // Giá trị mặc định nếu lỗi
  
  if (data['status'] != null) {
    if (data['status'] is int) {
      // Nếu database lưu dạng số nguyên (0, 1, 2...)
      parsedStatus = RequestStatus.values[data['status']];
    } else if (data['status'] is String) {
      // Nếu database lưu dạng chữ ("Chờ xử lý", "pending"...)
      final statusString = data['status'].toString();
      
      if (statusString == "Chờ xử lý" || statusString.toLowerCase() == "pending") {
        parsedStatus = RequestStatus.pending;
      } else if (statusString == "Đang xử lý" || statusString.toLowerCase() == "processing") {
        parsedStatus = RequestStatus.processing;
      } else if (statusString == "Đã duyệt" || statusString.toLowerCase() == "approved") {
        parsedStatus = RequestStatus.approved;
      } else if (statusString == "Từ chối" || statusString.toLowerCase() == "rejected") {
        parsedStatus = RequestStatus.rejected;
      }
    }
  }

  return RequestModel(
    id: doc.id,
    title: data['title'] ?? '',
    content: data['content'] ?? '',
    studentName: data['studentName'] ?? '',
    studentId: data['studentId'] ?? '',
    status: parsedStatus,
    type: RequestType.values[data['type'] is int ? data['type'] : 0],
    adminNote: data['adminNote'],
    processedBy: data['processedBy'],
    userId: data['userId'], 
    evidenceFileUrl: data['imageUrl'] ?? data['evidenceFileUrl'],
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    processedAt: (data['processedAt'] as Timestamp?)?.toDate(),
  );
}
}
