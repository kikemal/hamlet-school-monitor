import 'dart:typed_data';

import '../../../homework/data/services/homework_storage_service.dart';
import '../../../shared/domain/entities/homework.dart';
import '../../../shared/domain/entities/homework_submission.dart';
import '../../domain/models/teacher_models.dart';
import 'teacher_service_base.dart';

class TeacherHomeworkService extends TeacherServiceBase {
  TeacherHomeworkService({HomeworkStorageService? storage})
      : _storage = storage ?? HomeworkStorageService();

  final HomeworkStorageService _storage;
  Future<List<TeacherHomeworkItem>> fetchHomework(String teacherId) async {
    final rows = await supabaseClient
        .from('homework')
        .select('*, classes(name), subjects(name)')
        .eq('teacher_id', teacherId)
        .order('due_date', ascending: false);

    return rows.map((row) {
      final map = mapRow(row);
      return TeacherHomeworkItem(
        homework: Homework.fromJson(map),
        className: (map['classes'] as Map)['name'] as String,
        subjectName: (map['subjects'] as Map)['name'] as String,
      );
    }).toList();
  }

  Future<Homework> createHomework({
    required String classId,
    required String subjectId,
    required String teacherId,
    required String title,
    required DateTime dueDate,
    String? description,
    Uint8List? attachmentBytes,
    String? attachmentFileName,
  }) async {
    final row = await supabaseClient
        .from('homework')
        .insert({
          'class_id': classId,
          'subject_id': subjectId,
          'teacher_id': teacherId,
          'title': title,
          'due_date': dueDate.toUtc().toIso8601String(),
          if (description != null) 'description': description,
        })
        .select()
        .single();

    var homework = Homework.fromJson(mapRow(row));

    if (attachmentBytes != null && attachmentFileName != null) {
      final url = await _storage.uploadAssignmentFile(
        homeworkId: homework.id,
        fileName: attachmentFileName,
        bytes: attachmentBytes,
      );
      final updated = await supabaseClient
          .from('homework')
          .update({'attachment_url': url})
          .eq('id', homework.id)
          .select()
          .single();
      homework = Homework.fromJson(mapRow(updated));
    }

    return homework;
  }

  Future<Homework> updateHomework({
    required String id,
    required String title,
    required DateTime dueDate,
    String? description,
    Uint8List? attachmentBytes,
    String? attachmentFileName,
  }) async {
    var payload = <String, dynamic>{
      'title': title,
      'due_date': dueDate.toUtc().toIso8601String(),
      'description': description,
    };

    if (attachmentBytes != null && attachmentFileName != null) {
      final url = await _storage.uploadAssignmentFile(
        homeworkId: id,
        fileName: attachmentFileName,
        bytes: attachmentBytes,
      );
      payload['attachment_url'] = url;
    }

    final row = await supabaseClient
        .from('homework')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
    return Homework.fromJson(mapRow(row));
  }

  Future<void> deleteHomework(String id) async {
    await supabaseClient.from('homework').delete().eq('id', id);
  }

  Future<List<TeacherHomeworkSubmissionItem>> fetchSubmissions(
    String homeworkId,
  ) async {
    final rows = await supabaseClient
        .from('homework_submissions')
        .select('*, students!inner(profiles(first_name, last_name))')
        .eq('homework_id', homeworkId)
        .order('created_at', ascending: false);

    return rows.map((row) {
      final map = mapRow(row);
      final student = map['students'] as Map;
      final profile = student['profiles'] as Map;
      final name =
          '${profile['first_name']} ${profile['last_name']}'.trim();
      return TeacherHomeworkSubmissionItem(
        submission: HomeworkSubmission.fromJson(map),
        studentName: name,
      );
    }).toList();
  }

  Future<HomeworkSubmission> gradeSubmission({
    required String submissionId,
    required double gradedMarks,
  }) async {
    final row = await supabaseClient
        .from('homework_submissions')
        .update({
          'graded_marks': gradedMarks,
          'status': 'graded',
        })
        .eq('id', submissionId)
        .select()
        .single();
    return HomeworkSubmission.fromJson(mapRow(row));
  }
}
