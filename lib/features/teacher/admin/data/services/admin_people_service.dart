import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../shared/domain/entities/student.dart';
import '../../../shared/domain/entities/teacher.dart';
import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminPeopleService extends AdminServiceBase {
  Future<List<StudentListItem>> fetchStudents(String schoolId) async {
    final rows = await supabaseClient
        .from('students')
        .select(
          '*, profiles!inner(id, first_name, last_name, phone), '
          'classes(name), parents:parent_id(profiles(first_name, last_name))',
        )
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);

    return rows.map((row) {
      final map = mapRow(row);
      final profile = map['profiles'] as Map;
      final classData = map['classes'] as Map?;
      final parentData = map['parents'] as Map?;
      String? parentName;
      if (parentData != null) {
        final p = parentData['profiles'] as Map?;
        if (p != null) {
          parentName = '${p['first_name']} ${p['last_name']}';
        }
      }
      return StudentListItem(
        student: Student.fromJson(map),
        firstName: profile['first_name'] as String,
        lastName: profile['last_name'] as String,
        className: classData?['name'] as String?,
        parentName: parentName,
      );
    }).toList();
  }

  Future<List<TeacherListItem>> fetchTeachers(String schoolId) async {
    final rows = await supabaseClient
        .from('teachers')
        .select(
          '*, profiles!inner(first_name, last_name, phone), '
          'classes(name)',
        )
        .eq('school_id', schoolId);

    return rows.map((row) {
      final map = mapRow(row);
      final profile = map['profiles'] as Map;
      final classes = map['classes'] as List?;
      return TeacherListItem(
        teacher: Teacher.fromJson(map),
        firstName: profile['first_name'] as String,
        lastName: profile['last_name'] as String,
        className: classes != null && classes.isNotEmpty
            ? (classes.first as Map)['name'] as String?
            : null,
      );
    }).toList();
  }

  Future<List<ParentListItem>> fetchParents() async {
    final rows = await supabaseClient
        .from('parents')
        .select('*, profiles!inner(first_name, last_name, phone), students(id)');

    return rows.map((row) {
      final map = mapRow(row);
      final profile = map['profiles'] as Map;
      final children = map['students'] as List? ?? [];
      return ParentListItem(
        id: map['id'] as String,
        firstName: profile['first_name'] as String,
        lastName: profile['last_name'] as String,
        phone: profile['phone'] as String?,
        address: map['address'] as String?,
        emergencyContact: map['emergency_contact'] as String?,
        childrenCount: children.length,
      );
    }).toList();
  }

  Future<void> createStudent({
    required String schoolId,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? classId,
    String? parentId,
    String? phone,
    DateTime? dateOfBirth,
    DateTime? enrollmentDate,
  }) async {
    final userId = await _createAuthUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: 'student',
    );

    await supabaseClient.from('profiles').insert({
      'id': userId,
      'role': 'student',
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
    });

    await supabaseClient.from('students').insert({
      'id': userId,
      'school_id': schoolId,
      if (classId != null) 'class_id': classId,
      if (parentId != null) 'parent_id': parentId,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      if (enrollmentDate != null)
        'enrollment_date': enrollmentDate.toIso8601String().split('T').first,
    });
  }

  Future<void> updateStudent({
    required Student student,
    required String firstName,
    required String lastName,
    String? classId,
    String? parentId,
    String? phone,
  }) async {
    await supabaseClient.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
    }).eq('id', student.id);

    await supabaseClient.from('students').update({
      if (classId != null) 'class_id': classId,
      if (parentId != null) 'parent_id': parentId,
    }).eq('id', student.id);
  }

  Future<void> deleteStudent(String id) async {
    await supabaseClient.from('students').delete().eq('id', id);
    await supabaseClient.from('profiles').delete().eq('id', id);
  }

  Future<void> createTeacher({
    required String schoolId,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? specialization,
    String? phone,
  }) async {
    final userId = await _createAuthUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: 'teacher',
    );

    await supabaseClient.from('profiles').insert({
      'id': userId,
      'role': 'teacher',
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
    });

    await supabaseClient.from('teachers').insert({
      'id': userId,
      'school_id': schoolId,
      if (specialization != null) 'specialization': specialization,
    });
  }

  Future<void> updateTeacher({
    required Teacher teacher,
    required String firstName,
    required String lastName,
    String? specialization,
    String? phone,
  }) async {
    await supabaseClient.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
    }).eq('id', teacher.id);

    await supabaseClient.from('teachers').update({
      if (specialization != null) 'specialization': specialization,
    }).eq('id', teacher.id);
  }

  Future<void> deleteTeacher(String id) async {
    await supabaseClient.from('teachers').delete().eq('id', id);
    await supabaseClient.from('profiles').delete().eq('id', id);
  }

  Future<void> createParent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? address,
    String? emergencyContact,
    String? phone,
  }) async {
    final userId = await _createAuthUser(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: 'parent',
    );

    await supabaseClient.from('profiles').insert({
      'id': userId,
      'role': 'parent',
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
    });

    await supabaseClient.from('parents').insert({
      'id': userId,
      if (address != null) 'address': address,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
    });
  }

  Future<void> updateParent({
    required String id,
    required String firstName,
    required String lastName,
    String? address,
    String? emergencyContact,
    String? phone,
  }) async {
    await supabaseClient.from('profiles').update({
      'first_name': firstName,
      'last_name': lastName,
      if (phone != null) 'phone': phone,
    }).eq('id', id);

    await supabaseClient.from('parents').update({
      if (address != null) 'address': address,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
    }).eq('id', id);
  }

  Future<void> deleteParent(String id) async {
    await supabaseClient.from('parents').delete().eq('id', id);
    await supabaseClient.from('profiles').delete().eq('id', id);
  }

  Future<int> importStudentsFromCsv({
    required String schoolId,
    required List<StudentCsvRow> rows,
  }) async {
    var success = 0;
    for (final row in rows) {
      await createStudent(
        schoolId: schoolId,
        email: row.email,
        password: row.password,
        firstName: row.firstName,
        lastName: row.lastName,
        classId: row.classId,
        parentId: row.parentId,
        phone: row.phone,
        dateOfBirth: row.dateOfBirth,
        enrollmentDate: row.enrollmentDate,
      );
      success++;
    }
    return success;
  }

  Future<String> _createAuthUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    final response = await supabaseClient.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'role': role,
      },
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Failed to create user account.');
    }
    return user.id;
  }
}
