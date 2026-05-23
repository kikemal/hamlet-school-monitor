import '../../../shared/domain/entities/school_class.dart';
import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminClassService extends AdminServiceBase {
  Future<List<ClassListItem>> fetchClasses(String schoolId) async {
    final rows = await supabaseClient
        .from('classes')
        .select(
          '*, teachers(id, profiles(first_name, last_name)), students(id)',
        )
        .eq('school_id', schoolId)
        .order('name');

    return rows.map((row) {
      final map = mapRow(row);
      String? teacherName;
      final teacher = map['teachers'] as Map?;
      if (teacher != null) {
        final profile = teacher['profiles'] as Map?;
        if (profile != null) {
          teacherName = '${profile['first_name']} ${profile['last_name']}';
        }
      }
      final students = map['students'] as List? ?? [];
      return ClassListItem(
        schoolClass: SchoolClass.fromJson(map),
        teacherName: teacherName,
        studentCount: students.length,
      );
    }).toList();
  }

  Future<List<Map<String, String>>> fetchTeacherOptions(String schoolId) async {
    final rows = await supabaseClient
        .from('teachers')
        .select('id, profiles(first_name, last_name)')
        .eq('school_id', schoolId);

    return rows.map((row) {
      final map = mapRow(row);
      final profile = map['profiles'] as Map;
      return {
        'id': map['id'] as String,
        'name': '${profile['first_name']} ${profile['last_name']}',
      };
    }).toList();
  }

  Future<SchoolClass> createClass({
    required String schoolId,
    required String name,
    String? teacherId,
  }) async {
    final row = await supabaseClient
        .from('classes')
        .insert({
          'school_id': schoolId,
          'name': name,
          if (teacherId != null) 'teacher_id': teacherId,
        })
        .select()
        .single();
    return SchoolClass.fromJson(mapRow(row));
  }

  Future<SchoolClass> updateClass({
    required String id,
    required String name,
    String? teacherId,
  }) async {
    final row = await supabaseClient
        .from('classes')
        .update({
          'name': name,
          'teacher_id': teacherId,
        })
        .eq('id', id)
        .select()
        .single();
    return SchoolClass.fromJson(mapRow(row));
  }

  Future<void> assignTeacher({
    required String classId,
    required String? teacherId,
  }) async {
    await supabaseClient
        .from('classes')
        .update({'teacher_id': teacherId})
        .eq('id', classId);
  }

  Future<void> deleteClass(String id) async {
    await supabaseClient.from('classes').delete().eq('id', id);
  }
}
