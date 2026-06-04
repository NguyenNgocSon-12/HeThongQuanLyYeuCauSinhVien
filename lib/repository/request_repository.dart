import 'package:cloud_firestore/cloud_firestore.dart';

import '../database/db_helper.dart';
import '../models/request_model.dart';
import '../services/firestore_request_service.dart';
import '../services/request_validator.dart';

class RequestRepository {
  RequestRepository({FirestoreRequestService? remote})
    : _remote = remote ?? FirestoreRequestService();

  final FirestoreRequestService _remote;

  Future<RequestModel> createRequest(RequestModel request) async {
    final normalized = RequestValidator.normalizeForCreate(request);
    final id = normalized.id ?? _remote.newDocumentId();
    final localRequest = normalized.copyWith(id: id, isSynced: false);

    await _cacheRequest(localRequest);

    try {
      final savedRequest = await _remote.createRequest(localRequest);
      await _cacheRequest(savedRequest);
      return savedRequest;
    } on FirebaseException catch (error) {
      if (_isRetryable(error)) {
        return localRequest;
      }
      rethrow;
    }
  }

  Stream<List<RequestModel>> watchStudentRequests(
    String userId, {
    int limit = 50,
  }) async* {
    final cachedRequests = await _getCachedRequests(userId);
    if (cachedRequests.isNotEmpty) {
      yield cachedRequests;
    }

    await _trySyncPending(userId);

    await for (final requests in _remote.watchStudentRequests(
      userId,
      limit: limit,
    )) {
      for (final request in requests) {
        await _cacheRequest(request);
      }
      yield requests;
    }
  }

  Stream<List<RequestModel>> watchAdminRequests({
    RequestStatus? status,
    RequestType? type,
    int limit = 100,
  }) {
    return _remote.watchAdminRequests(status: status, type: type, limit: limit);
  }

  Future<RequestPageResult> getAdminRequestsPage({
    RequestStatus? status,
    RequestType? type,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = 20,
  }) {
    return _remote.getAdminRequestsPage(
      status: status,
      type: type,
      startAfter: startAfter,
      limit: limit,
    );
  }

  Future<RequestModel> updateStatus({
    required RequestModel request,
    required RequestStatus status,
    required String adminId,
    required String note,
  }) async {
    final updatedRequest = await _remote.updateStatus(
      request: request,
      status: status,
      adminId: adminId,
      note: note,
    );
    await _cacheRequest(updatedRequest);
    return updatedRequest;
  }

  Future<void> deleteRequest(String id) async {
    await _remote.deleteRequest(id);
    try {
      await DBHelper.deleteRequest(id);
    } catch (_) {
      // Firestore là nguồn dữ liệu chính; lỗi cache không được làm hỏng thao tác.
    }
  }

  Future<void> syncPendingRequests({String? userId}) async {
    final pendingRequests = await DBHelper.getPendingSync(userId: userId);

    for (final request in pendingRequests) {
      final savedRequest = await _remote.createRequest(request);
      await _cacheRequest(savedRequest);
    }
  }

  Future<void> _trySyncPending(String userId) async {
    try {
      await syncPendingRequests(userId: userId);
    } on FirebaseException catch (error) {
      if (!_isRetryable(error)) rethrow;
    } catch (_) {
      // Bỏ qua lỗi SQLite vì Firestore vẫn là nguồn dữ liệu chính.
    }
  }

  Future<List<RequestModel>> _getCachedRequests(String userId) async {
    try {
      return await DBHelper.getRequestsForUser(userId);
    } catch (_) {
      return [];
    }
  }

  Future<void> _cacheRequest(RequestModel request) async {
    try {
      await DBHelper.upsertRequest(request);
    } catch (_) {
      // SQLite là cache bổ trợ; Firestore vẫn phải hoạt động nếu cache lỗi.
    }
  }

  bool _isRetryable(FirebaseException error) {
    return const {
      'aborted',
      'deadline-exceeded',
      'network-request-failed',
      'unavailable',
    }.contains(error.code);
  }
}
