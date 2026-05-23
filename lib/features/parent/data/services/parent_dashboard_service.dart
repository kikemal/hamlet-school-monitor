import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../../../core/services/base_service.dart';
import '../../../shared/domain/entities/student.dart';
import '../../domain/models/parent_models.dart';
import 'parent_service_base.dart';

class ParentDashboardService extends ParentServiceBase {
  Future<List<ChildSummary>> fetchChildren(String parentId) async {
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
              photo_url
            ),
            school_classes!inner(
              name,
              section
            )
          ''')
          .eq('parent_id', parentId);

      final children = <ChildSummary>[];
      for (final row in response) {
        final profile = row['profiles'] as Map<String, dynamic>?;
        final schoolClass = row['school_classes'] as Map<String, dynamic>?;
        
        // Calculate GPA and attendance (simplified for now)
        final gpa = await _calculateGPA(row['id']);
        final attendance = await _calculateAttendance(row['id']);

        children.add(ChildSummary(
          student: Student.fromJson(row),
          firstName: profile?['first_name'] ?? '',
          lastName: profile?['last_name'] ?? '',
          className: schoolClass?['name'] ?? 'Unassigned',
          photoUrl: profile?['photo_url'],
          gpa: gpa,
          attendancePercentage: attendance,
          section: schoolClass?['section'],
        ));
      }

      return children;
    } catch (e) {
      throw Exception('Failed to fetch children: $e');
    }
  }

  Future<ParentDashboardStats> fetchDashboardStats(String parentId) async {
    try {
      // Fetch fees for parent's children
      final children = await fetchChildren(parentId);
      final studentIds = children.map((c) => c.student.id).toList();

      final feesResponse = await SupabaseConfig.client
          .from('fees')
          .select('amount, due_date')
          .in_('student_id', studentIds);

      final paymentsResponse = await SupabaseConfig.client
          .from('fee_payments')
          .select('amount, status')
          .in_('fee_id', feesResponse.map((f) => f['id']).toList());

      // Calculate fee stats
      double totalFees = 0;
      double paidFees = 0;
      double overdueFees = 0;

      for (final fee in feesResponse) {
        totalFees += (fee['amount'] as num).toDouble();
        final dueDate = DateTime.parse(fee['due_date']);
        if (DateTime.now().isAfter(dueDate)) {
          overdueFees += (fee['amount'] as num).toDouble();
        }
      }

      for (final payment in paymentsResponse) {
        if (payment['status'] == 'paid') {
          paidFees += (payment['amount'] as num).toDouble();
        }
      }

      // Fetch upcoming events
      final eventsResponse = await SupabaseConfig.client
          .from('school_events')
          .select('id')
          .gte('event_date', DateTime.now().toIso8601String())
          .lte('event_date', DateTime.now().add(const Duration(days: 30)).toIso8601String());

      // Fetch unread announcements
      final announcementsResponse = await SupabaseConfig.client
          .from('announcements')
          .select('id')
          .order('created_at', ascending: false)
          .limit(10);

      // Fetch pending homework
      final homeworkResponse = await SupabaseConfig.client
          .from('homework')
          .select('id')
          .in_('class_id', children.map((c) => c.student.classId).whereType<String>().toList())
          .gte('due_date', DateTime.now().toIso8601String());

      return ParentDashboardStats(
        totalFees: totalFees,
        paidFees: paidFees,
        pendingFees: totalFees - paidFees,
        overdueFees: overdueFees,
        upcomingEvents: eventsResponse.length,
        unreadAnnouncements: announcementsResponse.length,
        pendingHomework: homeworkResponse.length,
      );
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
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

      return totalPercentage / response.length / 25; // Convert to 4.0 scale
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
