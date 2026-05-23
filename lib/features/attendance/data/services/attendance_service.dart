import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../../../core/services/base_service.dart';
import '../../../shared/domain/entities/attendance.dart';
import '../../domain/models/attendance_models.dart';

class AttendanceService extends BaseService {
  /// Fetch attendance sheet for a specific class and date (teacher view)
  Future<List<AttendanceRecord>> fetchAttendanceSheet({
    required String classId,
    required DateTime date,
  }) async {
    final dateStr = _dateOnly(date);
    final studentsResponse = await supabaseClient
        .from('students')
        .select('''
          id,
          profiles!inner (
            first_name,
            last_name
          )
        ''')
        .eq('class_id', classId);

    final existingResponse = await supabaseClient
        .from('attendance')
        .select()
        .eq('class_id', classId)
        .eq('date', dateStr);

    final byStudentId = <String, Attendance>{};
    for (final row in existingResponse) {
      final attendance = Attendance.fromJson(row);
      byStudentId[attendance.studentId] = attendance;
    }

    final records = <AttendanceRecord>[];
    for (final student in studentsResponse) {
      final profile = student['profiles'] as Map<String, dynamic>;
      final attendance = byStudentId[student['id']] ?? 
          Attendance(
            id: '',
            studentId: student['id'],
            classId: classId,
            date: date,
            status: 'present',
          );
          
      records.add(AttendanceRecord(
        attendance: attendance,
        studentName: '${profile['first_name']} ${profile['last_name']}',
        studentId: student['id'],
      ));
    }

    records.sort((a, b) => a.studentName.compareTo(b.studentName));
    return records;
  }

  /// Save attendance records for a class and date
  Future<void> saveAttendance({
    required String classId,
    required DateTime date,
    required List<AttendanceRecord> records,
  }) async {
    final dateStr = _dateOnly(date);
    final absentStudentIds = <String>[];

    for (final record in records) {
      final payload = {
        'student_id': record.studentId,
        'class_id': classId,
        'date': dateStr,
        'status': record.attendance.status,
        if (record.attendance.remarks != null && 
            record.attendance.remarks!.isNotEmpty)
          'remarks': record.attendance.remarks,
      };

      if (record.attendance.id.isNotEmpty) {
        await supabaseClient
            .from('attendance')
            .update(payload)
            .eq('id', record.attendance.id);
      } else {
        final response = await supabaseClient
            .from('attendance')
            .insert(payload)
            .select()
            .single();
          
        // Update the record with the generated ID
        // In a real implementation, we'd need to update the record reference
      }

      // Track absent students for notifications
      if (record.attendance.status == 'absent') {
        absentStudentIds.add(record.studentId);
      }
    }

    // Send absence notifications to parents
    if (absentStudentIds.isNotEmpty) {
      await _sendAbsenceNotifications(absentStudentIds, date);
    }
  }

  /// Fetch attendance history for a specific student
  Future<List<Attendance>> fetchStudentAttendanceHistory(
      String studentId) async {
    final response = await supabaseClient
        .from('attendance')
        .select()
        .eq('student_id', studentId)
        .order('date', ascending: false);

    return response.map((row) => Attendance.fromJson(row)).toList();
  }

  /// Fetch monthly attendance summary for analytics
  Future<List<MonthlyAttendanceSummary>> fetchMonthlyAttendance(
      String classId, {
      required int months,
  }) async {
    final since = DateTime.now()
        .subtract(Duration(days: months * 30))
        .toIso8601String()
        .split('T')
        .first;

    final response = await supabaseClient
        .from('attendance')
        .select('date, status')
        .eq('class_id', classId)
        .gte('date', since);

    // Group by month
    final byMonth = <String, MonthlyAttendanceSummary>{};
    
    for (final row in response) {
      final date = DateTime.parse(row['date'] as String);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      if (!byMonth.containsKey(monthKey)) {
        byMonth[monthKey] = MonthlyAttendanceSummary(
          month: DateTime(date.year, date.month, 1),
          totalDays: 0,
          presentDays: 0,
          absentDays: 0,
          lateDays: 0,
        );
      }
      
      final summary = byMonth[monthKey]!;
      summary.totalDays++;
      
      switch (row['status'] as String) {
        case 'present':
          summary.presentDays++;
          break;
        case 'absent':
          summary.absentDays++;
          break;
        case 'late':
          summary.lateDays++;
          break;
      }
      
      byMonth[monthKey] = summary;
    }

    return byMonth.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  /// Fetch attendance comparison between classes
  Future<List<ClassAttendanceComparison>> fetchClassAttendanceComparison(
      List<String> classIds) async {
    if (classIds.isEmpty) return [];

    // Get class names
    final classesResponse = await supabaseClient
        .from('school_classes')
        .select('id, name')
        .in_('id', classIds);
    
    final classNames = <String, String>{};
    for (final c in classesResponse) {
      classNames[c['id'] as String] = c['name'] as String;
    }

    // Get student counts per class
    final studentsResponse = await supabaseClient
        .from('students')
        .select('class_id')
        .in_('class_id', classIds);
    
    final studentCounts = <String, int>{};
    for (final s in studentsResponse) {
      final classId = s['class_id'] as String;
      studentCounts[classId] = (studentCounts[classId] ?? 0) + 1;
    }

    // Get attendance records for all classes
    final attendanceResponse = await supabaseClient
        .from('attendance')
        .select('class_id, status')
        .in_('class_id', classIds);

    // Calculate attendance rates per class
    final classStats = <String, {int present: int, int total: int}>{};
    for (final a in attendanceResponse) {
      final classId = a['class_id'] as String;
      if (!classStats.containsKey(classId)) {
        classStats[classId] = {present: 0, total: 0};
      }
      final stats = classStats[classId]!;
      stats.total++;
      if (a['status'] == 'present') {
        stats.present++;
      }
      classStats[classId] = stats;
    }

    // Build comparison list
    final comparisons = <ClassAttendanceComparison>[];
    for (final classId in classIds) {
      final stats = classStats[classId];
      if (stats != null && stats.total > 0) {
        final rate = (stats.present / stats.total) * 100;
        comparisons.add(ClassAttendanceComparison(
          className: classNames[classId] ?? 'Unknown Class',
          attendanceRate: rate,
          studentCount: studentCounts[classId] ?? 0,
        ));
      }
    }

    return comparisons;
  }

  /// Fetch detailed attendance records for export (admin)
  Future<List<AttendanceExportRecord>> fetchAttendanceForExport({
    required String schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    let query = supabaseClient
        .from('attendance')
        .select('''
          id,
          student_id,
          date,
          status,
          remarks,
          students!inner (
            id,
            profiles!inner (
              first_name,
              last_name
            ),
            school_classes!inner (
              name
            )
          )
        ''')
        .eq('students.school_id', schoolId);

    if (startDate != null) {
      query = query.gte('date', startDate.toIso8601String().split('T').first);
    }
    if (endDate != null) {
      query = query.lte('date', endDate.toIso8601String().split('T').first);
    }

    final response = await query.order('date', ascending: false);

    return response.map((row) {
      final student = row['students'] as Map<String, dynamic>;
      final profile = student['profiles'] as Map<String, dynamic>;
      final schoolClass = student['school_classes'] as Map<String, dynamic>;
      
      return AttendanceExportRecord(
        studentName: '${profile['first_name']} ${profile['last_name']}',
        studentId: student['id'],
        className: schoolClass['name'] ?? 'Unknown Class',
        date: row['date'],
        status: row['status'],
        remarks: row['remarks'] ?? '',
      );
    }).toList();
  }

  /// Send absence notifications to parents
  Future<void> _sendAbsenceNotifications(
      List<String> studentIds, DateTime date) async {
    try {
      // Get student and parent info
      final studentsResponse = await supabaseClient
          .from('students')
          .select('''
            id,
            profiles!inner (
              first_name,
              last_name
            ),
            parent_id
          ''')
          .in_('id', studentIds);

      final notifications = <Map<String, dynamic>>[];
      const dateString = 'today'; // Could be formatted properly

      for (final student in studentsResponse) {
        final parentId = student['parent_id'] as String?;
        final firstName = student['profiles']['first_name'] as String?;
        final lastName = student['profiles']['last_name'] as String?;
        final studentName = 
            '$firstName $lastName'?.trim() ?? 'Student';

        if (parentId != null) {
          notifications.add({
            'user_id': parentId,
            'title': 'Attendance Alert',
            'body': 'Your child $studentName was marked absent on $dateString.',
            'is_read': false,
          });
        }
      }

      // Insert notifications into database
      if (notifications.isNotEmpty) {
        await supabaseClient
            .from('notifications')
            .insert(notifications);
      }
    } catch (e) {
      // Don't fail attendance saving if notifications fail
      print('Failed to send absence notifications: $e');
    }
  }

  String _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().split('T').first;
}