import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class FirestoreQueryHelper {
  static const String requestsCollection = 'requests';

  // Get requests with pagination
  static Future<List<RequestModel>> getRequestsWithPagination(
    int pageSize,
    DocumentSnapshot? lastDocument,
  ) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(requestsCollection)
          .orderBy('createdAt', descending: true)
          .limit(pageSize);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch paginated requests: $e');
    }
  }

  // Get requests with complex filtering
  static Future<List<RequestModel>> getFilteredRequests({
    RequestStatus? status,
    RequestType? type,
    String? studentId,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection(requestsCollection)
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.index);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.index);
      }

      if (studentId != null) {
        query = query.where('studentId', isEqualTo: studentId);
      }

      if (dateFrom != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateFrom));
      }

      if (dateTo != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(dateTo));
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch filtered requests: $e');
    }
  }

  // Get count of requests by status
  static Future<Map<RequestStatus, int>> getCountByStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(requestsCollection)
          .get();

      final countMap = <RequestStatus, int>{};
      for (final status in RequestStatus.values) {
        countMap[status] = 0;
      }

      for (final doc in snapshot.docs) {
        final status = RequestStatus.values[doc['status'] ?? 0];
        countMap[status] = (countMap[status] ?? 0) + 1;
      }

      return countMap;
    } catch (e) {
      throw Exception('Failed to get count by status: $e');
    }
  }

  // Get count of requests by type
  static Future<Map<RequestType, int>> getCountByType() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(requestsCollection)
          .get();

      final countMap = <RequestType, int>{};
      for (final type in RequestType.values) {
        countMap[type] = 0;
      }

      for (final doc in snapshot.docs) {
        final type = RequestType.values[doc['type'] ?? 0];
        countMap[type] = (countMap[type] ?? 0) + 1;
      }

      return countMap;
    } catch (e) {
      throw Exception('Failed to get count by type: $e');
    }
  }

  // Get requests for date range
  static Future<List<RequestModel>> getRequestsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(requestsCollection)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt',
              isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch requests for date range: $e');
    }
  }

  // Get requests with evidence files only
  static Future<List<RequestModel>> getRequestsWithEvidenceFiles() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(requestsCollection)
          .where('evidenceFileUrl', isNotEqualTo: null)
          .orderBy('evidenceFileUrl')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch requests with evidence: $e');
    }
  }

  // Get recently updated requests
  static Future<List<RequestModel>> getRecentlyUpdatedRequests(
      {int limit = 10}) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(requestsCollection)
          .where('processedAt', isNotEqualTo: null)
          .orderBy('processedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => _documentToRequest(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recently updated requests: $e');
    }
  }

  // Helper method to convert document to RequestModel
  static RequestModel _documentToRequest(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RequestModel(
      id: doc.id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      studentName: data['studentName'] ?? '',
      studentId: data['studentId'] ?? '',
      status: RequestStatus.values[data['status'] ?? 0],
      type: RequestType.values[data['type'] ?? 0],
      adminNote: data['adminNote'],
      processedBy: data['processedBy'],
      evidenceFileUrl: data['evidenceFileUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt: (data['processedAt'] as Timestamp?)?.toDate(),
    );
  }
}
