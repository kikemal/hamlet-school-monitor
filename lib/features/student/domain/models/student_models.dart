import '../../../shared/domain/entities/announcement.dart';
import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import '../../../shared/domain/entities/fee.dart';
import '../../../shared/domain/entities/fee_payment.dart';
import '../../../shared/domain/entities/homework.dart';
import '../../../shared/domain/entities/homework_submission.dart';
import '../../../shared/domain/entities/result.dart';
import '../../../shared/domain/entities/school_class.dart';
import '../../../shared/domain/entities/school_event.dart';
import '../../../shared/domain/entities/student.dart';
import '../../../shared/domain/entities/timetable.dart';

/// Student timetable for dashboard view
class StudentTimetableItem {
  const StudentTimetableItem({
    required this.timetable,
    required this.className,
    required this.subjectName,
    required this.teacherName,
  });

  final Timetable timetable;
  final String className;
  final String subjectName;
  final String teacherName;

  String get day {
    switch (timetable.dayOfWeek.toLowerCase()) {
      case 'monday':
        return 'Mon';
      case 'tuesday':
        return 'Tue';
      case 'wednesday':
        return 'Wed';
      case 'thursday':
        return 'Thu';
      case 'friday':
        return 'Fri';
      case 'saturday':
        return 'Sat';
      case 'sunday':
        return 'Sun';
      default:
        return timetable.dayOfWeek.substring(0, 3).toUpperCase();
    }
  }

  String get timeRange => '${timetable.startTime} – ${timetable.endTime}';
}

/// Student homework with submission status
class StudentHomeworkWithSubmission {
  const StudentHomeworkWithSubmission({
    required this.homework,
    this.submission,
  });

  final Homework homework;
  final HomeworkSubmission? submission;

  bool get isSubmitted => submission != null;
  bool get isOverdue =>
      DateTime.now().isAfter(homework.dueDate) && !isSubmitted;
  String get status {
    if (isSubmitted) return 'submitted';
    if (isOverdue) return 'overdue';
    return 'pending';
  }
}

/// Student result with subject and teacher info
class StudentResultWithDetails {
  const StudentResultWithDetails({
    required this.result,
    required this.subjectName,
    required this.teacherName,
  });

  final Result result;
  final String subjectName;
  final String teacherName;

  double get percentage =>
      (result.marksObtained / result.maxMarks) * 100;
  String get grade {
    final p = percentage;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }
}

/// Student attendance summary
class StudentAttendanceSummary {
  const StudentAttendanceSummary({
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
  });

  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;

  double get attendancePercentage =>
      totalDays > 0 ? (presentDays / totalDays) * 100 : 0.0;
}

/// Student fee summary
class StudentFeeSummary {
  const StudentFeeSummary({
    this.totalFees = 0,
    this.paidFees = 0,
    this.pendingFees = 0,
    this.overdueFees = 0,
  });

  final double totalFees;
  final double paidFees;
  final double pendingFees;
  final double overdueFees;

  bool get hasOverdue => overdueFees > 0;
}

/// Student dashboard statistics
class StudentDashboardStats {
  const StudentDashboardStats({
    this.upcomingEvents = 0,
    this.unreadAnnouncements = 0,
    this.pendingHomework = 0,
  });

  final int upcomingEvents;
  final int unreadAnnouncements;
  final int pendingHomework;
}