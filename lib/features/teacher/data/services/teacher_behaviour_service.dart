import '../../../shared/domain/entities/behaviour_log.dart';
import '../../domain/models/teacher_models.dart';
import 'teacher_service_base.dart';

class TeacherBehaviourService extends TeacherServiceBase {
  Future<List<TeacherBehaviourItem>> fetchForClass(String classId) async {
    final rows = await supabaseClient
        .from('behaviour_logs')
        .select(
          '*, students!inner(class_id, profiles(first_name, last_name))',
        )
        .eq('students.class_id', classId)
        .order('date', ascending: false)
        .limit(100);

    return rows.map((row) {
      final map = mapRow(row);
      final student = map['students'] as Map;
      final profile = student['profiles'] as Map;
      final name = '${profile['first_name']} ${profile['last_name']}';
      return TeacherBehaviourItem.fromRow(
        log: BehaviourLog.fromJson(map),
        studentName: name,
      );
    }).toList();
  }

  Future<BehaviourLog> createLog({
    required String studentId,
    required String teacherId,
    required String incidentType,
    required String severity,
    required String notes,
    required DateTime date,
  }) async {
    final row = await supabaseClient
        .from('behaviour_logs')
        .insert({
          'student_id': studentId,
          'teacher_id': teacherId,
          'incident_type': incidentType,
          'description': TeacherBehaviourItem.encodeDescription(
            severity: severity,
            notes: notes,
          ),
          'date': date.toIso8601String().split('T').first,
        })
        .select()
        .single();
    return BehaviourLog.fromJson(mapRow(row));
  }

  Future<void> deleteLog(String id) async {
    await supabaseClient.from('behaviour_logs').delete().eq('id', id);
  }
}
