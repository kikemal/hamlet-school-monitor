import '../../../shared/domain/entities/behaviour_log.dart';
import '../../domain/models/behaviour_models.dart';
import 'behaviour_service.dart';

class AdminBehaviourService extends BehaviourService {
  Future<List<BehaviourLogDisplayItem>> fetchSchoolLogs(String schoolId) async {
    final rows = await supabaseClient
        .from('behaviour_logs')
        .select(
          '*, students!inner(school_id, profiles(first_name, last_name)), '
          'teachers!inner(profiles(first_name, last_name))',
        )
        .eq('students.school_id', schoolId)
        .order('date', ascending: false)
        .limit(200);

    return rows.map((row) {
      final map = Map<String, dynamic>.from(row);
      final student = map['students'] as Map;
      final studentProfile = student['profiles'] as Map;
      final teacher = map['teachers'] as Map;
      final teacherProfile = teacher['profiles'] as Map;

      return BehaviourLogDisplayItem.fromLog(
        BehaviourLog.fromJson(map),
        studentName:
            '${studentProfile['first_name']} ${studentProfile['last_name']}'.trim(),
        teacherName:
            '${teacherProfile['first_name']} ${teacherProfile['last_name']}'.trim(),
      );
    }).toList();
  }
}
