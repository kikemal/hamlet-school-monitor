import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../../../core/services/base_service.dart';
import '../../../shared/domain/entities/student.dart';
import '../../domain/models/student_models.dart';

class StudentDashboardService extends BaseService {
  Future<Student> fetchStudentProfile(String studentId) async {
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
            profiles!inner (
              first_name,
              last_name,
              photo_url
            ),
            school_classes!inner (
              name,
              section
            )
          ''')
          .eq('id', studentId)
          .single();

      return Student.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch student profile: $e');
    }
  }

  Future<List<StudentTimetableItem>> fetchTimetable(String studentId) async {
    try {
      // First get student's class ID
      final studentResponse = await SupabaseConfig.client
          .from('students')
          .select('class_id')
          .eq('id', studentId)
          .single();

      final classId = studentResponse['class_id'] as String?;
      if (classId == null) return [];

      // Then get timetable for that class
      final response = await SupabaseConfig.client
          .from('timetable')
          .select('''
            id,
            day_of_week,
            start_time,
            end_time,
            subject_id,
            subjects!inner (
              name,
              teachers!inner (
                profiles!inner (
                  first_name,
                  last_name
                )
              )
            ),
            school_classes!inner (
              name
            )
          ''')
          .eq('school_class_id', classId)
          .order('day_of_week')
          .order('start_time');

      final timetableItems = <StudentTimetableItem>[];
      for (final row in response) {
        final subject = row['subjects'] as Map<String, dynamic>?;
        final teacher = subject?['teachers'] as Map<String, dynamic>?;
        final teacherProfile = teacher?['profiles'] as Map<String, dynamic>?;
        final schoolClass = row['school_classes'] as Map<String, dynamic>?;

        timetableItems.add(StudentTimetableItem(
          timetable: Timetable.fromJson(row),
          className: schoolClass?['name'] ?? 'Unknown Class',
          subjectName: subject?['name'] ?? 'Unknown Subject',
          teacherName:
              '${teacherProfile?['first_name'] ?? ''} ${teacherProfile?['last_name'] ?? ''}'.trim(),
        ));
      }

      return timetableItems;
    } catch (e) {
      throw Exception('Failed to fetch timetable: $e');
    }
  }

  Future<List<StudentResultWithDetails>> fetchExamResults(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('results')
          .select('''
            id,
            student_id,
            subject_name,
            exam_name,
            marks_obtained,
            max_marks,
            created_at,
            updated_at,
            subjects!inner (
              name,
              teachers!inner (
                profiles!inner (
                  first_name,
                  last_name
                )
              )
            )
          ''')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      final resultsWithDetails = <StudentResultWithDetails>[];
      for (final row in response) {
        final subject = row['subjects'] as Map<String, dynamic>?;
        final teacher = subject?['teachers'] as Map<String, dynamic>?;
        final teacherProfile = teacher?['profiles'] as Map<String, dynamic>?;

        resultsWithDetails.add(StudentResultWithDetails(
          result: Result.fromJson(row),
          subjectName: subject?['name'] ?? 'Unknown Subject',
          teacherName:
              '${teacherProfile?['first_name'] ?? ''} ${teacherProfile?['last_name'] ?? ''}'.trim(),
        ));
      }

      return resultsWithDetails;
    } catch (e) {
      throw Exception('Failed to fetch exam results: $e');
    }
  }

  Future<StudentAttendanceSummary> fetchAttendanceHistory(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('attendance')
          .select('status')
          .eq('student_id', studentId);

      int totalDays = response.length;
      int presentDays = response
          .where((r) => r['status'] == 'present')
          .length;
      int absentDays = response
          .where((r) => r['status'] == 'absent')
          .length;
      int lateDays = response
          .where((r) => r['status'] == 'late')
          .length;

      return StudentAttendanceSummary(
        totalDays: totalDays,
        presentDays: presentDays,
        absentDays: absentDays,
        lateDays: lateDays,
      );
    } catch (e) {
      throw Exception('Failed to fetch attendance history: $e');
    }
  }

  Future<StudentFeeSummary> fetchFeeSummary(String studentId) async {
    try {
      // Get fees
      final feesResponse = await SupabaseConfig.client
          .from('fees')
          .select('amount, due_date')
          .eq('student_id', studentId);

      // Get payments
      final paymentsResponse = await SupabaseConfig.client
          .from('fee_payments')
          .select('amount, status')
          .in_('fee_id',
              feesResponse.map((f) => f['id'] as String).whereType<String>().toList());

      // Calculate totals
      double totalFees = 0;
      double paidFees = 0;

      for (final fee in feesResponse) {
        totalFees += (fee['amount'] as num).toDouble();
      }

      for (final payment in paymentsResponse) {
        if (payment['status'] == 'paid') {
          paidFees += (payment['amount'] as num).toDouble();
        }
      }

      final pendingFees = totalFees - paidFees;

      // Calculate overdue fees (simplified)
      double overdueFees = 0;
      for (final fee in feesResponse) {
        final dueDate = DateTime.parse(fee['due_date']);
        if (DateTime.now().isAfter(dueDate)) {
          final feeAmount = (fee['amount'] as num).toDouble();
          // Find payments for this fee
          final feePayments = paymentsResponse
              .where((p) => p['fee_id'] == fee['id'])
              .toList();
          final paidForThisFee = feePayments
              .where((p) => p['status'] == 'paid')
              .fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble());
          final unpaidForThisFee = feeAmount - paidForThisFee;
          if (unpaidForThisFee > 0) {
            overdueFees += unpaidForThisFee;
          }
        }
      }

      return StudentFeeSummary(
        totalFees: totalFees,
        paidFees: paidFees,
        pendingFees: pendingFees,
        overdueFees: overdueFees,
      );
    } catch (e) {
      throw Exception('Failed to fetch fee summary: $e');
    }
  }

  Future<StudentDashboardStats> fetchDashboardStats(String studentId) async {
    try {
      // Get student's class ID for events
      final studentResponse = await SupabaseConfig.client
          .from('students')
          .select('school_id')
          .eq('id', studentId)
          .single();

      final schoolId = studentResponse['school_id'] as String?;
      if (schoolId == null) return const StudentDashboardStats();

      // Fetch upcoming events (next 30 days)
      final eventsResponse = await SupabaseConfig.client
          .from('school_events')
          .select('id')
          .eq('school_id', schoolId)
          .gte('event_date', DateTime.now().toIso8601String())
          .lte('event_date',
              DateTime.now().add(const Duration(days: 30)).toIso8601String());

      // Fetch unread announcements for student's classes
      final classIdResponse = await SupabaseConfig.client
          .from('students')
          .select('class_id')
          .eq('id', studentId)
          .single();

      final classId = classIdResponse['class_id'] as String?;
      final announcementsResponse = await SupabaseConfig.client
          .from('announcements')
          .select('id')
          .eq('school_id', schoolId)
          .is_('read_at', 'null') // Assuming unread means read_at is null
          .eq('class_id', classId ?? '') // If no class, get school-wide announcements
          .order('created_at', ascending: false);

      // Fetch pending homework
      final homeworkResponse = await SupabaseConfig.client
          .from('homework')
          .select('id')
          .eq('class_id', 
              (await SupabaseConfig.client
                  .from('students')
                  .select('class_id')
                  .eq('id', studentId)
                  .single())['class_id'])
          .gte('due_date', DateTime.now().toIso8601String());

      // Get submissions for this student to determine what's actually pending
      final submissionResponse = await SupabaseConfig.client
          .from('homework_submissions')
          .select('homework_id')
          .eq('student_id', studentId);

      final submittedHomeworkIds = submissionResponse
          .map((s) => s['homework_id'] as String)
          .whereType<String>()
          .toSet();

      final pendingHomeworkCount = homeworkResponse
          .where((hw) => !submittedHomeworkIds.contains(hw['id'] as String))
          .length;

      return StudentDashboardStats(
        upcomingEvents: eventsResponse.length,
        unreadAnnouncements: announcementsResponse.length,
        pendingHomework: pendingHomeworkCount,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }
}