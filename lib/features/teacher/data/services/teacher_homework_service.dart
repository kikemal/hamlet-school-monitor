import '../../../shared/domain/entities/homework.dart';
import '../../domain/models/teacher_models.dart';
import 'teacher_service_base.dart';

class TeacherHomeworkService extends TeacherServiceBase {
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
    return Homework.fromJson(mapRow(row));
  }

  Future<Homework> updateHomework({
    required String id,
    required String title,
    required DateTime dueDate,
    String? description,
  }) async {
    final row = await supabaseClient
        .from('homework')
        .update({
          'title': title,
          'due_date': dueDate.toUtc().toIso8601String(),
          'description': description,
        })
        .eq('id', id)
        .select()
        .single();
    return Homework.fromJson(mapRow(row));
  }

  Future<void> deleteHomework(String id) async {
    await supabaseClient.from('homework').delete().eq('id', id);
  }
}
