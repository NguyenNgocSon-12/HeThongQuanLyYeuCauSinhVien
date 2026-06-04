import '../models/request_model.dart';

class RequestValidationException implements Exception {
  const RequestValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class RequestValidator {
  const RequestValidator._();

  static RequestModel normalizeForCreate(RequestModel request) {
    final now = DateTime.now();
    final title = request.title.trim();
    final content = request.content.trim();
    final studentName = request.studentName.trim();
    final studentId = request.studentId.trim().toUpperCase();
    final userId = request.userId.trim();

    if (userId.isEmpty) {
      throw const RequestValidationException(
        'Không xác định được tài khoản đang đăng nhập.',
      );
    }
    if (studentId.length < 6 || studentId.length > 20) {
      throw const RequestValidationException('MSSV phải có từ 6 đến 20 ký tự.');
    }
    if (studentName.isEmpty || studentName.length > 100) {
      throw const RequestValidationException('Họ tên sinh viên không hợp lệ.');
    }
    if (title.isEmpty || title.length > 120) {
      throw const RequestValidationException(
        'Tiêu đề yêu cầu phải có từ 1 đến 120 ký tự.',
      );
    }
    if (content.length < 10 || content.length > 2000) {
      throw const RequestValidationException(
        'Nội dung yêu cầu phải có từ 10 đến 2000 ký tự.',
      );
    }

    return request.copyWith(
      userId: userId,
      studentId: studentId,
      studentName: studentName,
      title: title,
      content: content,
      status: RequestStatus.pending,
      type: RequestType.fromValue(request.type.value, title: title),
      updatedAt: now,
    );
  }

  static String normalizeAdminNote(RequestStatus status, String note) {
    final normalized = note.trim();

    if (normalized.length > 1000) {
      throw const RequestValidationException(
        'Ghi chú xử lý không được vượt quá 1000 ký tự.',
      );
    }
    if (status == RequestStatus.rejected && normalized.isEmpty) {
      throw const RequestValidationException(
        'Vui lòng nhập lý do khi từ chối yêu cầu.',
      );
    }

    return normalized;
  }
}
