import '../../../shared/domain/entities/school_class.dart';
import '../../domain/models/teacher_models.dart';
import 'teacher_service_base.dart';

class TeacherClassService extends TeacherServiceBase {
  Future<String?> fetchTeacherSchoolId(String teacherId) async {
    final row = await supabaseClient
        .from('teachers')
        .select('school_id')
        .eq('id', teacherId)
        .maybeSingle();
    if (row == null) return null;
    return mapRow(row)['school_id'] as String?;
  }

  Future<List<TeacherClassItem>> fetchAssignedClasses(String teacherId) async {
    final homeroom = await supabaseClient
        .from('classes')
        .select('*, students(id)')
        .eq('teacher_id', teacherId);

    final timetableClasses = await supabaseClient
        .from('timetables')
        .select('class_id, classes(id, name, school_id, teacher_id, created_at, updated_at, students(id))')
        .eq('teacher_id', teacherId);

    final byId = <String, TeacherClassItem>{};

    for (final row in homeroom) {
      final map = mapRow(row);
      final students = map['students'] as List? ?? [];
      final schoolClass = SchoolClass.fromJson(map);
      byId[schoolClass.id] = TeacherClassItem(
        schoolClass: schoolClass,
        studentCount: students.length,
        isHomeroom: true,
      );
    }

    for (final row in timetableClasses) {
      final map = mapRow(row);
      final classMap = map['classes'] as Map?;
      if (classMap == null) continue;
      final id = classMap['id'] as String;
      if (byId.containsKey(id)) continue;
      final students = classMap['students'] as List? ?? [];
      final schoolClass = SchoolClass.fromJson(Map<String, dynamic>.from(classMap));
      byId[id] = TeacherClassItem(
        schoolClass: schoolClass,
        studentCount: students.length,
        isHomeroom: schoolClass.teacherId == teacherId,
      );
    }

    return byId.values.toList()
      ..sort((a, b) => a.schoolClass.name.compareTo(b.schoolClass.name));
  }

  Future<List<TeacherStudentItem>> fetchClassStudents(String classId) async {
    final rows = await supabaseClient
        .from('students')
        .select('id, parent_id, profiles!inner(first_name, last_name)')
        .eq('class_id', classId)
        .order('profiles(last_name)');

    return rows.map((row) {
      final map = mapRow(row);
      final profile = map['profiles'] as Map;
      return TeacherStudentItem(
        id: map['id'] as String,
        firstName: profile['first_name'] as String,
        lastName: profile['last_name'] as String,
        parentId: map['parent_id'] as String?,
      );
    }).toList();
  }

  Future<List<TeacherSubjectOption>> fetchSubjects(String schoolId) async {
    final rows = await supabaseClient
        .from('subjects')
        .select('id, name')
        .eq('school_id', schoolId)
        .order('name');

    return rows
        .map(
          (r) => TeacherSubjectOption(
            id: mapRow(r)['id'] as String,
            name: mapRow(r)['name'] as String,
          ),
        )
        .toList();
  }
}
