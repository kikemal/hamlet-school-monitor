import '../../domain/models/teacher_models.dart';
import 'teacher_service_base.dart';

class TeacherAnalyticsService extends TeacherServiceBase {
  Future<TeacherDashboardStats> fetchDashboardStats({
    required String teacherId,
    required List<String> classIds,
  }) async {
    if (classIds.isEmpty) return const TeacherDashboardStats();

    final today = DateTime.now().weekday;
    final timetable = await supabaseClient
        .from('timetables')
        .select('id')
        .eq('teacher_id', teacherId)
        .eq('day_of_week', today);
    final todaysLessons = timetable.length;

    final students = await supabaseClient
        .from('students')
        .select('id')
        .inFilter('class_id', classIds);

    final homework = await supabaseClient
        .from('homework')
        .select('id')
        .eq('teacher_id', teacherId)
        .gte('due_date', DateTime.now().toUtc().toIso8601String());

    final attendanceRows = await supabaseClient
        .from('attendance')
        .select('status')
        .inFilter('class_id', classIds)
        .limit(500);

    var present = 0;
    for (final row in attendanceRows) {
      if (mapRow(row)['status'] == 'present') present++;
    }
    final attendanceRate = attendanceRows.isEmpty
        ? 0.0
        : (present / attendanceRows.length) * 100;

    final resultRows = await supabaseClient
        .from('results')
        .select('marks_obtained, max_marks, students!inner(class_id)')
        .inFilter('students.class_id', classIds)
        .limit(500);

    var markSum = 0.0;
    var markCount = 0;
    for (final row in resultRows) {
      final map = mapRow(row);
      final max = (map['max_marks'] as num?)?.toDouble() ?? 0;
      if (max > 0) {
        markSum += ((map['marks_obtained'] as num).toDouble() / max) * 100;
        markCount++;
      }
    }

    return TeacherDashboardStats(
      classCount: classIds.length,
      studentCount: students.length,
      todaysLessons: todaysLessons,
      openHomework: homework.length,
      attendanceRate: attendanceRate,
      averageMarks: markCount == 0 ? 0 : markSum / markCount,
    );
  }

  Future<List<TeacherClassAnalytics>> fetchClassAnalytics(
    List<String> classIds,
  ) async {
    if (classIds.isEmpty) return [];

    final classes = await supabaseClient
        .from('classes')
        .select('id, name')
        .inFilter('id', classIds);

    final items = <TeacherClassAnalytics>[];
    for (final c in classes) {
      final map = mapRow(c);
      final classId = map['id'] as String;
      final className = map['name'] as String;

      final attendanceRows = await supabaseClient
          .from('attendance')
          .select('status')
          .eq('class_id', classId);

      var present = 0;
      for (final row in attendanceRows) {
        if (mapRow(row)['status'] == 'present') present++;
      }
      final attendanceRate = attendanceRows.isEmpty
          ? 0.0
          : (present / attendanceRows.length) * 100;

      final resultRows = await supabaseClient
          .from('results')
          .select('marks_obtained, max_marks, students!inner(class_id)')
          .eq('students.class_id', classId);

      var markSum = 0.0;
      var markCount = 0;
      for (final row in resultRows) {
        final r = mapRow(row);
        final max = (r['max_marks'] as num?)?.toDouble() ?? 0;
        if (max > 0) {
          markSum += ((r['marks_obtained'] as num).toDouble() / max) * 100;
          markCount++;
        }
      }

      items.add(
        TeacherClassAnalytics(
          classId: classId,
          className: className,
          attendanceRate: attendanceRate,
          averageMarks: markCount == 0 ? 0 : markSum / markCount,
          presentCount: present,
          totalAttendanceRecords: attendanceRows.length,
          resultCount: resultRows.length,
        ),
      );
    }

    return items;
  }

  Future<List<TeacherAttendanceTrendPoint>> fetchAttendanceTrend(
    String classId, {
    int days = 14,
  }) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final rows = await supabaseClient
        .from('attendance')
        .select('date, status')
        .eq('class_id', classId)
        .gte('date', since.toIso8601String().split('T').first);

    final byDate = <String, List<String>>{};
    for (final row in rows) {
      final map = mapRow(row);
      final date = map['date'] as String;
      byDate.putIfAbsent(date, () => []).add(map['status'] as String);
    }

    final points = <TeacherAttendanceTrendPoint>[];
    for (final entry in byDate.entries) {
      final present =
          entry.value.where((s) => s == 'present' || s == 'late').length;
      final rate = (present / entry.value.length) * 100;
      points.add(
        TeacherAttendanceTrendPoint(
          date: DateTime.parse(entry.key),
          rate: rate,
        ),
      );
    }

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }
}
