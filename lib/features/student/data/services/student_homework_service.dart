import 'dart:typed_data';

import '../../../homework/data/services/homework_storage_service.dart';
import '../../../shared/domain/entities/homework.dart';
import '../../../shared/domain/entities/homework_submission.dart';
import '../../domain/models/student_models.dart';
import 'student_service_base.dart';

class StudentHomeworkService extends StudentServiceBase {
  StudentHomeworkService({HomeworkStorageService? storage})
      : _storage = storage ?? HomeworkStorageService();

  final HomeworkStorageService _storage;

  Future<List<StudentHomeworkWithSubmission>> fetchHomework(String studentId) async {
    final studentRow = await supabaseClient
        .from('students')
        .select('class_id')
        .eq('id', studentId)
        .single();

    final classId = studentRow['class_id'] as String?;
    if (classId == null) return [];

    final homeworkRows = await supabaseClient
        .from('homework')
        .select('*, subjects(name)')
        .eq('class_id', classId)
        .order('due_date', ascending: false);

    final submissionRows = await supabaseClient
        .from('homework_submissions')
        .select()
        .eq('student_id', studentId);

    final submissionsByHomeworkId = <String, HomeworkSubmission>{};
    for (final row in submissionRows) {
      final submission = HomeworkSubmission.fromJson(mapRow(row));
      submissionsByHomeworkId[submission.homeworkId] = submission;
    }

    return homeworkRows.map((row) {
      final map = mapRow(row);
      final homework = Homework.fromJson(map);
      return StudentHomeworkWithSubmission(
        homework: homework,
        submission: submissionsByHomeworkId[homework.id],
        subjectName: (map['subjects'] as Map?)?['name'] as String?,
      );
    }).toList();
  }

  Future<List<String>> fetchSubmittedHomeworkIds(String studentId) async {
    final rows = await supabaseClient
        .from('homework_submissions')
        .select('homework_id')
        .eq('student_id', studentId);
    return rows.map((r) => r['homework_id'] as String).toList();
  }

  Future<HomeworkSubmission> submitHomework({
    required String homeworkId,
    required String studentId,
    String? submissionText,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    String? fileUrl;
    if (fileBytes != null && fileName != null) {
      fileUrl = await _storage.uploadSubmissionFile(
        homeworkId: homeworkId,
        studentId: studentId,
        fileName: fileName,
        bytes: fileBytes,
      );
    }

    final row = await supabaseClient.from('homework_submissions').upsert({
      'homework_id': homeworkId,
      'student_id': studentId,
      if (submissionText != null && submissionText.isNotEmpty)
        'submission_text': submissionText,
      if (fileUrl != null) 'file_url': fileUrl,
      'status': 'pending',
    }, onConflict: 'homework_id,student_id').select().single();

    return HomeworkSubmission.fromJson(mapRow(row));
  }
}
