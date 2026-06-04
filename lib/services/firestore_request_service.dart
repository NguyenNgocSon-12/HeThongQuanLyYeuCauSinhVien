import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/request_model.dart';
import 'request_validator.dart';

class RequestPageResult {
  const RequestPageResult({
    required this.items,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<RequestModel> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

class FirestoreRequestService {
  FirestoreRequestService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('requests');

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  String newDocumentId() => _requests.doc().id;

  Future<RequestModel> createRequest(RequestModel request) async {
    final normalized = RequestValidator.normalizeForCreate(request);
    final id = normalized.id ?? newDocumentId();
    final savedRequest = normalized.copyWith(id: id, isSynced: true);

    await _requests.doc(id).set(savedRequest.toFirestore());
    return savedRequest;
  }

  Future<RequestModel?> getRequest(String id) async {
    final snapshot = await _requests.doc(id).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return RequestModel.fromMap(snapshot.id, data);
  }

  Stream<List<RequestModel>> watchStudentRequests(
    String userId, {
    int limit = 50,
  }) {
    return _requests
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_mapSnapshot);
  }

  Stream<List<RequestModel>> watchAdminRequests({
    RequestStatus? status,
    RequestType? type,
    int limit = 100,
  }) {
    Query<Map<String, dynamic>> query = _requests.orderBy(
      'createdAt',
      descending: true,
    );

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.value);
    }

    return query.limit(limit).snapshots().map(_mapSnapshot);
  }

  Future<RequestPageResult> getAdminRequestsPage({
    RequestStatus? status,
    RequestType? type,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> query = _requests.orderBy(
      'createdAt',
      descending: true,
    );

    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }
    if (type != null) {
      query = query.where('type', isEqualTo: type.value);
    }
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.limit(limit).get();
    return RequestPageResult(
      items: _mapSnapshot(snapshot),
      lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
      hasMore: snapshot.docs.length == limit,
    );
  }

  Future<RequestModel> updateStatus({
    required RequestModel request,
    required RequestStatus status,
    required String adminId,
    required String note,
  }) async {
    if (request.id == null) {
      throw const RequestValidationException('Yêu cầu chưa có mã tài liệu.');
    }

    final normalizedNote = RequestValidator.normalizeAdminNote(status, note);
    final now = DateTime.now();
    final updatedRequest = request.copyWith(
      status: status,
      adminNote: normalizedNote,
      processedBy: adminId,
      processedAt: now,
      updatedAt: now,
      isSynced: true,
    );

    final requestRef = _requests.doc(request.id);
    final notificationRef = _notifications.doc();
    final batch = _firestore.batch();

    batch.update(requestRef, {
      'status': status.value,
      'adminNote': normalizedNote,
      'processedBy': adminId,
      'processedAt': now,
      'updatedAt': now,
    });

    batch.set(notificationRef, {
      'userId': request.userId,
      'requestId': request.id,
      'title': 'Yêu cầu đã được cập nhật',
      'message': '${request.title}: ${status.text}',
      'type': 'request_status',
      'isRead': false,
      'createdAt': now,
    });

    await batch.commit();
    return updatedRequest;
  }

  Future<void> deleteRequest(String id) => _requests.doc(id).delete();

  List<RequestModel> _mapSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((doc) => RequestModel.fromMap(doc.id, doc.data()))
        .toList();
  }
}
