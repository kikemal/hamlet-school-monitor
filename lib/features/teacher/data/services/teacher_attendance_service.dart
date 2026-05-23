import '../../../shared/domain/entities/attendance.dart';
import '../../domain/models/teacher_models.dart';
import 'teacher_service_base.dart';

class TeacherAttendanceService extends TeacherServiceBase {
  Future<List<TeacherAttendanceRow>> fetchAttendanceSheet({
    required String classId,
    required DateTime date,
  }) async {
    final dateStr = _dateOnly(date);
    final students = await supabaseClient
        .from('students')
        .select('id, profiles!inner(first_name, last_name)')
        .eq('class_id', classId);

    final existingRows = await supabaseClient
        .from('attendance')
        .select()
        .eq('class_id', classId)
        .eq('date', dateStr);

    final byStudent = <String, Attendance>{};
    for (final row in existingRows) {
      final att = Attendance.fromJson(mapRow(row));
      byStudent[att.studentId] = att;
    }

    final roster = <TeacherAttendanceRow>[];
    for (final row in students) {
      final map = mapRow(row);
      final profile = map['profiles'] as Map;
      final studentId = map['id'] as String;
      final existing = byStudent[studentId];
      roster.add(
        TeacherAttendanceRow(
          student: TeacherStudentItem(
            id: studentId,
            firstName: profile['first_name'] as String,
            lastName: profile['last_name'] as String,
          ),
          existing: existing,
          status: existing?.status ?? 'present',
          remarks: existing?.remarks,
        ),
      );
    }

    roster.sort(
      (a, b) => a.student.lastName.compareTo(b.student.lastName),
    );
    return roster;
  }

  Future<void> saveAttendance({
    required String classId,
    required DateTime date,
    required List<TeacherAttendanceRow> rows,
  }) async {
    final dateStr = _dateOnly(date);
    for (final row in rows) {
      final payload = {
        'student_id': row.student.id,
        'class_id': classId,
        'date': dateStr,
        'status': row.status,
        if (row.remarks != null && row.remarks!.isNotEmpty)
          'remarks': row.remarks,
      };

      if (row.existing != null) {
        await supabaseClient
            .from('attendance')
            .update(payload)
            .eq('id', row.existing!.id);
      } else {
        await supabaseClient.from('attendance').insert(payload);
      }
    }
  }

  String _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().split('T').first;
}
