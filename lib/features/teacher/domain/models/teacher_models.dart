import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import '../../../shared/domain/entities/homework.dart';
import '../../../shared/domain/entities/homework_submission.dart';
import '../../../shared/domain/entities/school_class.dart';
import '../../../shared/domain/entities/timetable.dart';

/// Assigned class with student count for teacher lists.
class TeacherClassItem {
  const TeacherClassItem({
    required this.schoolClass,
    this.studentCount = 0,
    this.isHomeroom = false,
  });

  final SchoolClass schoolClass;
  final int studentCount;
  final bool isHomeroom;
}

/// Student row in a class roster.
class TeacherStudentItem {
  const TeacherStudentItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.parentId,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? parentId;

  String get fullName => '$firstName $lastName';
}

/// Timetable slot with display labels.
class TeacherTimetableSlot {
  const TeacherTimetableSlot({
    required this.timetable,
    required this.className,
    required this.subjectName,
  });

  final Timetable timetable;
  final String className;
  final String subjectName;

  String get timeRange => '${timetable.startTime} – ${timetable.endTime}';
}

/// Attendance row for a student on a given day.
class TeacherAttendanceRow {
  const TeacherAttendanceRow({
    required this.student,
    this.existing,
    this.status = 'present',
    this.remarks,
  });

  final TeacherStudentItem student;
  final Attendance? existing;
  final String status;
  final String? remarks;

  TeacherAttendanceRow copyWith({
    String? status,
    String? remarks,
    Attendance? existing,
  }) {
    return TeacherAttendanceRow(
      student: student,
      existing: existing ?? this.existing,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
    );
  }
}

/// Subject option for dropdowns.
class TeacherSubjectOption {
  const TeacherSubjectOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

/// Submission row for teacher grading view.
class TeacherHomeworkSubmissionItem {
  const TeacherHomeworkSubmissionItem({
    required this.submission,
    required this.studentName,
  });

  final HomeworkSubmission submission;
  final String studentName;
}

/// Homework list item with class/subject labels.
class TeacherHomeworkItem {
  const TeacherHomeworkItem({
    required this.homework,
    required this.className,
    required this.subjectName,
  });

  final Homework homework;
  final String className;
  final String subjectName;
}

/// Behaviour log with parsed severity and notes.
class TeacherBehaviourItem {
  const TeacherBehaviourItem({
    required this.log,
    required this.studentName,
    required this.severity,
    required this.notes,
  });

  final BehaviourLog log;
  final String studentName;
  final String severity;
  final String notes;

  static const severityPattern = r'^\[(low|medium|high)\]\s*(.*)$';

  factory TeacherBehaviourItem.fromRow({
    required BehaviourLog log,
    required String studentName,
  }) {
    final match = RegExp(severityPattern, caseSensitive: false)
        .firstMatch(log.description.trim());
    if (match != null) {
      return TeacherBehaviourItem(
        log: log,
        studentName: studentName,
        severity: match.group(1)!.toLowerCase(),
        notes: match.group(2)!.trim(),
      );
    }
    return TeacherBehaviourItem(
      log: log,
      studentName: studentName,
      severity: 'medium',
      notes: log.description,
    );
  }

  static String encodeDescription({
    required String severity,
    required String notes,
  }) =>
      '[${severity.toLowerCase()}] ${notes.trim()}';
}

/// Dashboard summary for teacher home.
class TeacherDashboardStats {
  const TeacherDashboardStats({
    this.classCount = 0,
    this.studentCount = 0,
    this.todaysLessons = 0,
    this.openHomework = 0,
    this.attendanceRate = 0,
    this.averageMarks = 0,
  });

  final int classCount;
  final int studentCount;
  final int todaysLessons;
  final int openHomework;
  final double attendanceRate;
  final double averageMarks;
}

/// Class-level analytics for charts.
class TeacherClassAnalytics {
  const TeacherClassAnalytics({
    required this.classId,
    required this.className,
    required this.attendanceRate,
    required this.averageMarks,
    required this.presentCount,
    required this.totalAttendanceRecords,
    required this.resultCount,
  });

  final String classId;
  final String className;
  final double attendanceRate;
  final double averageMarks;
  final int presentCount;
  final int totalAttendanceRecords;
  final int resultCount;
}

/// Daily attendance trend point.
class TeacherAttendanceTrendPoint {
  const TeacherAttendanceTrendPoint({
    required this.date,
    required this.rate,
  });

  final DateTime date;
  final double rate;
}
