import '../../../shared/domain/entities/timetable.dart';
import '../../domain/models/teacher_models.dart';
import 'teacher_service_base.dart';

class TeacherTimetableService extends TeacherServiceBase {
  Future<List<TeacherTimetableSlot>> fetchTimetable(String teacherId) async {
    final rows = await supabaseClient
        .from('timetables')
        .select('*, classes(name), subjects(name)')
        .eq('teacher_id', teacherId)
        .order('day_of_week')
        .order('start_time');

    return rows.map((row) {
      final map = mapRow(row);
      final classData = map['classes'] as Map;
      final subjectData = map['subjects'] as Map;
      return TeacherTimetableSlot(
        timetable: Timetable.fromJson(map),
        className: classData['name'] as String,
        subjectName: subjectData['name'] as String,
      );
    }).toList();
  }

  List<TeacherTimetableSlot> slotsForDay(
    List<TeacherTimetableSlot> all,
    int dayOfWeek,
  ) =>
      all.where((s) => s.timetable.dayOfWeek == dayOfWeek).toList();
}
