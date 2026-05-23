import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/document.dart';
import '../../../shared/domain/entities/fee.dart';
import '../../../shared/domain/entities/fee_payment.dart';
import '../../../shared/domain/entities/result.dart';
import '../../../shared/domain/entities/school.dart';
import '../../../shared/domain/entities/school_class.dart';
import '../../../shared/domain/entities/school_event.dart';
import '../../../shared/domain/entities/student.dart';
import '../../../shared/domain/entities/teacher.dart';

/// Dashboard KPI counts for the admin home screen.
class AdminDashboardStats {
  const AdminDashboardStats({
    this.studentCount = 0,
    this.teacherCount = 0,
    this.parentCount = 0,
    this.classCount = 0,
    this.pendingFees = 0,
    this.upcomingEvents = 0,
    this.attendanceRate = 0,
    this.averageMarks = 0,
  });

  final int studentCount;
  final int teacherCount;
  final int parentCount;
  final int classCount;
  final int pendingFees;
  final int upcomingEvents;
  final double attendanceRate;
  final double averageMarks;
}

/// Student row with profile names for admin lists.
class StudentListItem {
  const StudentListItem({
    required this.student,
    required this.firstName,
    required this.lastName,
    this.email,
    this.className,
    this.parentName,
  });

  final Student student;
  final String firstName;
  final String lastName;
  final String? email;
  final String? className;
  final String? parentName;

  String get fullName => '$firstName $lastName';
}

/// Teacher row with profile names.
class TeacherListItem {
  const TeacherListItem({
    required this.teacher,
    required this.firstName,
    required this.lastName,
    this.email,
    this.className,
  });

  final Teacher teacher;
  final String firstName;
  final String lastName;
  final String? email;
  final String? className;

  String get fullName => '$firstName $lastName';
}

/// Parent row with profile names.
class ParentListItem {
  const ParentListItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    this.emergencyContact,
    this.childrenCount = 0,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? emergencyContact;
  final int childrenCount;

  String get fullName => '$firstName $lastName';
}

/// Class row with assigned teacher name.
class ClassListItem {
  const ClassListItem({
    required this.schoolClass,
    this.teacherName,
    this.studentCount = 0,
  });

  final SchoolClass schoolClass;
  final String? teacherName;
  final int studentCount;
}

/// Fee with aggregated payment status.
class FeeWithStatus {
  const FeeWithStatus({
    required this.fee,
    this.totalPaid = 0,
    this.paymentCount = 0,
    this.latestStatus = 'pending',
  });

  final Fee fee;
  final double totalPaid;
  final int paymentCount;
  final String latestStatus;

  double get remaining => (fee.amount - totalPaid).clamp(0, fee.amount);
  bool get isPaid => remaining <= 0.01;
}

/// Class-level average marks for analytics.
class ClassPerformance {
  const ClassPerformance({
    required this.classId,
    required this.className,
    required this.averagePercentage,
    required this.studentCount,
  });

  final String classId;
  final String className;
  final double averagePercentage;
  final int studentCount;
}

/// Subject trend point for charts.
class SubjectTrend {
  const SubjectTrend({
    required this.subjectId,
    required this.subjectName,
    required this.averagePercentage,
  });

  final String subjectId;
  final String subjectName;
  final double averagePercentage;
}

/// Parsed row from student CSV import.
class StudentCsvRow {
  const StudentCsvRow({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.classId,
    this.parentId,
    this.phone,
    this.dateOfBirth,
    this.enrollmentDate,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? classId;
  final String? parentId;
  final String? phone;
  final DateTime? dateOfBirth;
  final DateTime? enrollmentDate;
}

/// Bundle used by export screen.
class AdminExportData {
  const AdminExportData({
    required this.attendance,
    required this.results,
  });

  final List<Attendance> attendance;
  final List<Result> results;
}

/// School context for admin operations.
class AdminSchoolContext {
  const AdminSchoolContext({
    required this.school,
    required this.classes,
  });

  final School school;
  final List<SchoolClass> classes;
}

/// Document with uploader display name.
class DocumentListItem {
  const DocumentListItem({
    required this.document,
    this.uploaderName,
  });

  final Document document;
  final String? uploaderName;
}

/// Calendar event wrapper.
class EventListItem {
  const EventListItem({
    required this.event,
  });

  final SchoolEvent event;
}

/// Fee payment with parent/fee labels.
class FeePaymentListItem {
  const FeePaymentListItem({
    required this.payment,
    required this.feeDescription,
    required this.parentName,
  });

  final FeePayment payment;
  final String feeDescription;
  final String parentName;
}
