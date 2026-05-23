import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/base_service.dart';

/// Uploads homework assignment and submission files to Supabase Storage.
class HomeworkStorageService extends BaseService {
  static const String assignmentsBucket = 'homework-assignments';
  static const String submissionsBucket = 'homework-submissions';

  Future<String> uploadAssignmentFile({
    required String homeworkId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path = 'assignments/$homeworkId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await supabaseClient.storage.from(assignmentsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return supabaseClient.storage.from(assignmentsBucket).getPublicUrl(path);
  }

  Future<String> uploadSubmissionFile({
    required String homeworkId,
    required String studentId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path =
        'submissions/$homeworkId/$studentId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await supabaseClient.storage.from(submissionsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return supabaseClient.storage.from(submissionsBucket).getPublicUrl(path);
  }
}
