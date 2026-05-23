import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import '../../../shared/domain/entities/fee.dart';
import '../../../shared/domain/entities/fee_payment.dart';
import '../../../shared/domain/entities/homework.dart';
import '../../../shared/domain/entities/homework_submission.dart';
import '../../../shared/domain/entities/result.dart';
import '../../domain/models/parent_models.dart';
import 'parent_service_base.dart';

class ParentChildService extends ParentServiceBase {
  Future<ChildProfile> fetchChildProfile(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('students')
          .select('''
            id,
            school_id,
            class_id,
            parent_id,
            date_of_birth,
            enrollment_date,
            profiles!inner(
              first_name,
              last_name,
              photo_url,
              phone,
              address,
              emergency_contact,
              blood_group,
              allergies
            ),
            school_classes!inner(
              name,
              section
            )
          ''')
          .eq('id', studentId)
          .single();

      final profile = response['profiles'] as Map<String, dynamic>;
      final schoolClass = response['school_classes'] as Map<String, dynamic>;

      // Calculate GPA and attendance
      final gpa = await _calculateGPA(studentId);
      final attendance = await _calculateAttendance(studentId);

      final childSummary = ChildSummary(
        student: Student.fromJson(response),
        firstName: profile['first_name'],
        lastName: profile['last_name'],
        className: schoolClass['name'],
        photoUrl: profile['photo_url'],
        gpa: gpa,
        attendancePercentage: attendance,
        section: schoolClass['section'],
      );

      return ChildProfile(
        summary: childSummary,
        dateOfBirth: response['date_of_birth'] != null 
            ? DateTime.parse(response['date_of_birth']) 
            : null,
        enrollmentDate: response['enrollment_date'] != null 
            ? DateTime.parse(response['enrollment_date']) 
            : null,
        rollNumber: profile['roll_number'],
        bloodGroup: profile['blood_group'],
        allergies: profile['allergies'],
        emergencyContact: profile['emergency_contact'],
        address: profile['address'],
      );
    } catch (e) {
      throw Exception('Failed to fetch child profile: $e');
    }
  }

  Future<List<Attendance>> fetchAttendanceHistory(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('attendance')
          .select()
          .eq('student_id', studentId)
          .order('date', ascending: false)
          .limit(30);

      return response.map((row) => Attendance.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance history: $e');
    }
  }

  Future<List<ResultWithDetails>> fetchExamResults(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('results')
          .select('''
            id,
            student_id,
            subject_id,
            exam_name,
            marks_obtained,
            max_marks,
            date,
            subjects!inner(
              name
            ),
            profiles!inner(
              first_name,
              last_name
            )
          ''')
          .eq('student_id', studentId)
          .order('date', ascending: false);

      final results = <ResultWithDetails>[];
      for (final row in response) {
        final subject = row['subjects'] as Map<String, dynamic>;
        final profile = row['profiles'] as Map<String, dynamic>?;

        results.add(ResultWithDetails(
          result: Result.fromJson(row),
          subjectName: subject['name'],
          teacherName: profile != null 
              ? '${profile['first_name']} ${profile['last_name']}' 
              : 'Unknown',
        ));
      }

      return results;
    } catch (e) {
      throw Exception('Failed to fetch exam results: $e');
    }
  }

  Future<List<HomeworkWithSubmission>> fetchHomework(String studentId) async {
    try {
      final student = await SupabaseConfig.client
          .from('students')
          .select('class_id')
          .eq('id', studentId)
          .single();

      final classId = student['class_id'];

      final homeworkResponse = await SupabaseConfig.client
          .from('homework')
          .select('*, subjects(name)')
          .eq('class_id', classId)
          .order('due_date', ascending: false)
          .limit(50);

      final homeworkList = <HomeworkWithSubmission>[];
      for (final hw in homeworkResponse) {
        final submissionResponse = await SupabaseConfig.client
            .from('homework_submissions')
            .select()
            .eq('homework_id', hw['id'])
            .eq('student_id', studentId)
            .maybeSingle();

        homeworkList.add(HomeworkWithSubmission(
          homework: Homework.fromJson(hw),
          submission: submissionResponse != null 
              ? HomeworkSubmission.fromJson(submissionResponse) 
              : null,
        ));
      }

      return homeworkList;
    } catch (e) {
      throw Exception('Failed to fetch homework: $e');
    }
  }

  Future<List<BehaviourLogWithTeacher>> fetchBehaviourLogs(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('behaviour_logs')
          .select('''
            id,
            student_id,
            teacher_id,
            incident_type,
            description,
            date,
            profiles!inner(
              first_name,
              last_name
            )
          ''')
          .eq('student_id', studentId)
          .order('date', ascending: false)
          .limit(20);

      final logs = <BehaviourLogWithTeacher>[];
      for (final row in response) {
        final profile = row['profiles'] as Map<String, dynamic>;

        logs.add(BehaviourLogWithTeacher(
          log: BehaviourLog.fromJson(row),
          teacherName: '${profile['first_name']} ${profile['last_name']}',
        ));
      }

      return logs;
    } catch (e) {
      throw Exception('Failed to fetch behaviour logs: $e');
    }
  }

  Future<List<FeeWithPayments>> fetchFees(String studentId) async {
    try {
      final feesResponse = await SupabaseConfig.client
          .from('fees')
          .select()
          .eq('student_id', studentId)
          .order('due_date', ascending: false);

      final fees = <FeeWithPayments>[];
      for (final fee in feesResponse) {
        final paymentsResponse = await SupabaseConfig.client
            .from('fee_payments')
            .select()
            .eq('fee_id', fee['id']);

        final payments = paymentsResponse
            .map((p) => FeePayment.fromJson(p))
            .toList();

        fees.add(FeeWithPayments(
          fee: Fee.fromJson(fee),
          payments: payments,
        ));
      }

      return fees;
    } catch (e) {
      throw Exception('Failed to fetch fees: $e');
    }
  }

  Future<double> _calculateGPA(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('results')
          .select('marks_obtained, max_marks')
          .eq('student_id', studentId);

      if (response.isEmpty) return 0.0;

      double totalPercentage = 0;
      for (final result in response) {
        final obtained = (result['marks_obtained'] as num).toDouble();
        final max = (result['max_marks'] as num).toDouble();
        totalPercentage += (obtained / max) * 100;
      }

      return totalPercentage / response.length / 25;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> _calculateAttendance(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('attendance')
          .select('status')
          .eq('student_id', studentId);

      if (response.isEmpty) return 0.0;

      final present = response.where((r) => r['status'] == 'present').length;
      return (present / response.length) * 100;
    } catch (e) {
      return 0.0;
    }
  }
}
