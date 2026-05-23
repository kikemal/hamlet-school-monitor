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
import '../../../shared/domain/entities/teacher.dart';

/// Child summary card data for parent dashboard
class ChildSummary {
  const ChildSummary({
    required this.student,
    required this.firstName,
    required this.lastName,
    required this.className,
    required this.photoUrl,
    required this.gpa,
    required this.attendancePercentage,
    this.section,
  });

  final Student student;
  final String firstName;
  final String lastName;
  final String className;
  final String? photoUrl;
  final double gpa;
  final double attendancePercentage;
  final String? section;

  String get fullName => '$firstName $lastName';
}

/// Parent dashboard statistics
class ParentDashboardStats {
  const ParentDashboardStats({
    this.totalFees = 0,
    this.paidFees = 0,
    this.pendingFees = 0,
    this.overdueFees = 0,
    this.upcomingEvents = 0,
    this.unreadAnnouncements = 0,
    this.pendingHomework = 0,
  });

  final double totalFees;
  final double paidFees;
  final double pendingFees;
  final double overdueFees;
  final int upcomingEvents;
  final int unreadAnnouncements;
  final int pendingHomework;
}

/// Child profile with detailed information
class ChildProfile {
  const ChildProfile({
    required this.summary,
    required this.dateOfBirth,
    required this.enrollmentDate,
    required this.rollNumber,
    this.bloodGroup,
    this.allergies,
    this.emergencyContact,
    this.address,
  });

  final ChildSummary summary;
  final DateTime? dateOfBirth;
  final DateTime? enrollmentDate;
  final String? rollNumber;
  final String? bloodGroup;
  final String? allergies;
  final String? emergencyContact;
  final String? address;
}

/// Fee with payment status for parent view
class FeeWithPayments {
  const FeeWithPayments({
    required this.fee,
    this.payments = const [],
  });

  final Fee fee;
  final List<FeePayment> payments;

  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);
  double get remaining => (fee.amount - totalPaid).clamp(0.0, fee.amount);
  bool get isPaid => remaining <= 0.01;
  bool get isOverdue => DateTime.now().isAfter(fee.dueDate) && !isPaid;
  String get status {
    if (isPaid) return 'paid';
    if (isOverdue) return 'overdue';
    return 'pending';
  }
}

/// Homework with submission status
class HomeworkWithSubmission {
  const HomeworkWithSubmission({
    required this.homework,
    this.submission,
  });

  final Homework homework;
  final HomeworkSubmission? submission;

  bool get isSubmitted => submission != null;
  bool get isOverdue => DateTime.now().isAfter(homework.dueDate) && !isSubmitted;
  String get status {
    if (isSubmitted) return 'submitted';
    if (isOverdue) return 'overdue';
    return 'pending';
  }
}

/// Result with subject and teacher info
class ResultWithDetails {
  const ResultWithDetails({
    required this.result,
    required this.subjectName,
    required this.teacherName,
  });

  final Result result;
  final String subjectName;
  final String teacherName;

  double get percentage => (result.marksObtained / result.maxMarks) * 100;
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

/// Behaviour log with teacher info
class BehaviourLogWithTeacher {
  const BehaviourLogWithTeacher({
    required this.log,
    required this.teacherName,
  });

  final BehaviourLog log;
  final String teacherName;

  bool get isPositive => log.incidentType.toLowerCase().contains('positive') ||
      log.incidentType.toLowerCase().contains('achievement');
}
