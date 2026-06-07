import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _evidenceBucket = 'evidence_files';

  // Upload evidence file for a request
  Future<String> uploadEvidenceFile(
    String requestId,
    File file,
  ) async {
    try {
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = '$_evidenceBucket/$requestId/${timestamp}_$fileName';

      final uploadTask = await _storage.ref(storagePath).putFile(file);
      final fileUrl = await uploadTask.ref.getDownloadURL();
      return fileUrl;
    } catch (e) {
      throw Exception('Failed to upload evidence file: $e');
    }
  }

  // Delete evidence file
  Future<void> deleteEvidenceFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete evidence file: $e');
    }
  }

  // Upload multiple evidence files
  Future<List<String>> uploadMultipleEvidenceFiles(
    String requestId,
    List<File> files,
  ) async {
    try {
      final uploadedUrls = <String>[];
      for (final file in files) {
        final url = await uploadEvidenceFile(requestId, file);
        uploadedUrls.add(url);
      }
      return uploadedUrls;
    } catch (e) {
      throw Exception('Failed to upload multiple files: $e');
    }
  }

  // Get file name from URL
  static String getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      return path.split('/').last.split('?').first;
    } catch (e) {
      return 'unknown_file';
    }
  }

  // Check if file exists
  Future<bool> fileExists(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.getMetadata();
      return true;
    } catch (e) {
      return false;
    }
  }
}
