import '../../../../core/services/base_service.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import '../../domain/models/behaviour_models.dart';

/// Shared behaviour queries and summaries.
class BehaviourService extends BaseService {
  Future<BehaviourSummary> fetchSummaryForStudent(String studentId) async {
    final rows = await supabaseClient
        .from('behaviour_logs')
        .select('incident_type, severity, date')
        .eq('student_id', studentId);

    var minor = 0;
    var moderate = 0;
    var serious = 0;
    var positive = 0;
    var recent = 0;
    final cutoff = DateTime.now().subtract(const Duration(days: 30));

    for (final row in rows) {
      final type = row['incident_type'] as String;
      if (type == 'positive') {
        positive++;
        continue;
      }

      final rawSeverity = row['severity'] as String? ?? 'moderate';
      final sev = BehaviourLogDisplayItem.fromLog(
        BehaviourLog(
          id: '',
          studentId: studentId,
          teacherId: '',
          incidentType: type,
          description: '',
          severity: rawSeverity,
          date: DateTime.parse(row['date'] as String),
        ),
      ).severity;

      switch (sev) {
        case 'minor':
          minor++;
          break;
        case 'serious':
          serious++;
          break;
        default:
          moderate++;
      }

      final date = DateTime.parse(row['date'] as String);
      if (date.isAfter(cutoff)) recent++;
    }

    return BehaviourSummary(
      total: rows.length,
      minor: minor,
      moderate: moderate,
      serious: serious,
      positive: positive,
      recentIncidents: recent,
    );
  }

  Future<void> notifyParentOfIncident({
    required String studentId,
    required String severity,
    required String notes,
    required DateTime date,
  }) async {
    final student = await supabaseClient
        .from('students')
        .select('parent_id, profiles(first_name, last_name)')
        .eq('id', studentId)
        .maybeSingle();

    if (student == null) return;
    final parentId = student['parent_id'] as String?;
    if (parentId == null) return;

    final profile = student['profiles'] as Map?;
    final name = profile != null
        ? '${profile['first_name']} ${profile['last_name']}'.trim()
        : 'your child';

    final title = 'Behaviour incident logged';
    final body =
        '$name — ${severity[0].toUpperCase()}${severity.substring(1)} incident on ${date.toIso8601String().split('T').first}: $notes';

    await supabaseClient.from('notifications').insert({
      'user_id': parentId,
      'title': title,
      'body': body,
    });
  }
}
