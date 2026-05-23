import '../../../behaviour/data/services/behaviour_service.dart';
import '../../../behaviour/domain/models/behaviour_models.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import 'teacher_service_base.dart';

class TeacherBehaviourService extends TeacherServiceBase {
  TeacherBehaviourService({BehaviourService? behaviour})
      : _behaviour = behaviour ?? BehaviourService();

  final BehaviourService _behaviour;

  Future<List<BehaviourLogDisplayItem>> fetchForClass(String classId) async {
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
      return BehaviourLogDisplayItem.fromLog(
        BehaviourLog.fromJson(map),
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
    final description = BehaviourLogDisplayItem.encodeDescription(
      severity: severity,
      notes: notes,
    );

    final row = await supabaseClient
        .from('behaviour_logs')
        .insert({
          'student_id': studentId,
          'teacher_id': teacherId,
          'incident_type': incidentType,
          'description': description,
          'severity': severity,
          'date': date.toIso8601String().split('T').first,
        })
        .select()
        .single();

    final log = BehaviourLog.fromJson(mapRow(row));

    if (incidentType == 'negative') {
      await _behaviour.notifyParentOfIncident(
        studentId: studentId,
        severity: severity,
        notes: notes,
        date: date,
      );
    }

    return log;
  }

  Future<void> deleteLog(String id) async {
    await supabaseClient.from('behaviour_logs').delete().eq('id', id);
  }
}
