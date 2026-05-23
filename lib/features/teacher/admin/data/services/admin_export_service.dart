import 'package:csv/csv.dart';

import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/result.dart';
import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminExportService extends AdminServiceBase {
  Future<AdminExportData> fetchExportData(String schoolId) async {
    final attendanceRows = await supabaseClient
        .from('attendance')
        .select('*, students!inner(school_id, profiles(first_name, last_name))')
        .eq('students.school_id', schoolId);

    final resultRows = await supabaseClient
        .from('results')
        .select(
          '*, students!inner(school_id, profiles(first_name, last_name)), subjects(name)',
        )
        .eq('students.school_id', schoolId);

    return AdminExportData(
      attendance: attendanceRows
          .map((r) => Attendance.fromJson(mapRow(r)))
          .toList(),
      results: resultRows.map((r) => Result.fromJson(mapRow(r))).toList(),
    );
  }

  String attendanceToCsv(List<Attendance> rows) {
    final data = [
      ['id', 'student_id', 'class_id', 'date', 'status', 'remarks'],
      ...rows.map(
        (a) => [
          a.id,
          a.studentId,
          a.classId,
          a.date.toIso8601String().split('T').first,
          a.status,
          a.remarks ?? '',
        ],
      ),
    ];
    return const ListToCsvConverter().convert(data);
  }

  String resultsToCsv(List<Result> rows) {
    final data = [
      [
        'id',
        'student_id',
        'subject_id',
        'exam_name',
        'marks_obtained',
        'max_marks',
        'date',
      ],
      ...rows.map(
        (r) => [
          r.id,
          r.studentId,
          r.subjectId,
          r.examName,
          r.marksObtained.toString(),
          r.maxMarks.toString(),
          r.date.toIso8601String().split('T').first,
        ],
      ),
    ];
    return const ListToCsvConverter().convert(data);
  }

  List<StudentCsvRow> parseStudentCsv(String content) {
    final rows = const CsvToListConverter().convert(content);
    if (rows.length < 2) return [];

    final header =
        rows.first.map((c) => c.toString().trim().toLowerCase()).toList();
    int col(String name) => header.indexOf(name);

    final items = <StudentCsvRow>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      String cell(int index) =>
          index >= 0 && index < row.length ? row[index].toString().trim() : '';

      items.add(
        StudentCsvRow(
          email: cell(col('email')),
          password: cell(col('password')),
          firstName: cell(col('first_name')),
          lastName: cell(col('last_name')),
          classId: cell(col('class_id')).isEmpty ? null : cell(col('class_id')),
          parentId:
              cell(col('parent_id')).isEmpty ? null : cell(col('parent_id')),
          phone: cell(col('phone')).isEmpty ? null : cell(col('phone')),
        ),
      );
    }
    return items;
  }
}
