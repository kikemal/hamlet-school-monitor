import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/student.dart';

/// Attendance record with student info for teacher view
class AttendanceRecord {
  const AttendanceRecord({
    required this.attendance,
    required this.studentName,
    required this.studentId,
  });

  final Attendance attendance;
  final String studentName;
  final String studentId;

  bool get isPresent => attendance.status == 'present';
  bool get isAbsent => attendance.status == 'absent';
  bool get isLate => attendance.status == 'late';
}

/// Monthly attendance summary for analytics
class MonthlyAttendanceSummary {
  const MonthlyAttendanceSummary({
    required this.month,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
  });

  final DateTime month; // First day of the month
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;

  double get attendanceRate =>
      totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;
}

/// Class attendance comparison for analytics
class ClassAttendanceComparison {
  const ClassAttendanceComparison({
    required this.className,
    required this.attendanceRate,
    required this.studentCount,
  });

  final String className;
  final double attendanceRate;
  final int studentCount;
}

/// Detailed attendance statistics for exports
class AttendanceExportRecord {
  const AttendanceExportRecord({
    required this.studentName,
    required this.studentId,
    required this.className,
    required this.date,
    required this.status,
    required this.remarks,
  });

  final String studentName;
  final String studentId;
  final String className;
  final String date;
  final String status;
  final String remarks;
}