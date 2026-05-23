import '../../../shared/domain/entities/result.dart';
import 'teacher_service_base.dart';

class TeacherResultsService extends TeacherServiceBase {
  Future<Result> uploadResult({
    required String studentId,
    required String subjectId,
    required String examName,
    required double marksObtained,
    required double maxMarks,
    required DateTime date,
  }) async {
    final row = await supabaseClient
        .from('results')
        .insert({
          'student_id': studentId,
          'subject_id': subjectId,
          'exam_name': examName,
          'marks_obtained': marksObtained,
          'max_marks': maxMarks,
          'date': date.toIso8601String().split('T').first,
        })
        .select()
        .single();
    return Result.fromJson(mapRow(row));
  }

  Future<List<Result>> fetchRecentResultsForClass(String classId) async {
    final rows = await supabaseClient
        .from('results')
        .select('*, students!inner(class_id)')
        .eq('students.class_id', classId)
        .order('date', ascending: false)
        .limit(50);

    return rows.map((r) => Result.fromJson(mapRow(r))).toList();
  }
}
