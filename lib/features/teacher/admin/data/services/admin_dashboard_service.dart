import '../../../shared/domain/entities/school.dart';
import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminDashboardService extends AdminServiceBase {
  Future<School?> getPrimarySchool() async {
    final rows = await supabaseClient.from('schools').select().limit(1);
    if (rows.isEmpty) return null;
    return School.fromJson(mapRow(rows.first));
  }

  Future<AdminDashboardStats> getDashboardStats(String schoolId) async {
    final students = await supabaseClient
        .from('students')
        .select('id')
        .eq('school_id', schoolId);
    final teachers = await supabaseClient
        .from('teachers')
        .select('id')
        .eq('school_id', schoolId);
    final parents = await supabaseClient.from('parents').select('id');
    final classes = await supabaseClient
        .from('classes')
        .select('id')
        .eq('school_id', schoolId);

    final fees = await supabaseClient
        .from('fees')
        .select('id, fee_payments(status)')
        .eq('school_id', schoolId);

    var pendingFees = 0;
    for (final fee in fees) {
      final payments = fee['fee_payments'] as List? ?? [];
      final hasCompleted = payments.any(
        (p) => (p as Map)['status'] == 'completed',
      );
      if (!hasCompleted) pendingFees++;
    }

    final events = await supabaseClient
        .from('school_events')
        .select('id')
        .eq('school_id', schoolId)
        .gte('event_date', DateTime.now().toIso8601String());

    final attendanceRows = await supabaseClient
        .from('attendance')
        .select('status, students!inner(school_id)')
        .eq('students.school_id', schoolId)
        .limit(500);

    var present = 0;
    var total = attendanceRows.length;
    for (final row in attendanceRows) {
      if (row['status'] == 'present') present++;
    }
    final attendanceRate = total == 0 ? 0.0 : (present / total) * 100;

    final resultRows = await supabaseClient
        .from('results')
        .select('marks_obtained, max_marks, students!inner(school_id)')
        .eq('students.school_id', schoolId)
        .limit(500);

    var markSum = 0.0;
    var markCount = 0;
    for (final row in resultRows) {
      final max = (row['max_marks'] as num?)?.toDouble() ?? 0;
      if (max > 0) {
        markSum += ((row['marks_obtained'] as num).toDouble() / max) * 100;
        markCount++;
      }
    }

    return AdminDashboardStats(
      studentCount: students.length,
      teacherCount: teachers.length,
      parentCount: parents.length,
      classCount: classes.length,
      pendingFees: pendingFees,
      upcomingEvents: events.length,
      attendanceRate: attendanceRate,
      averageMarks: markCount == 0 ? 0 : markSum / markCount,
    );
  }
}
