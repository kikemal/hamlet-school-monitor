import 'dart:typed_data';

import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/fee.dart';
import '../../../shared/domain/entities/result.dart';
import '../../../shared/domain/entities/fee_payment.dart';
import '../../../shared/domain/entities/school.dart';
import '../../../shared/domain/entities/school_class.dart';
import '../../../shared/domain/entities/school_event.dart';
import '../../../shared/domain/entities/student.dart';
import '../../../shared/domain/entities/teacher.dart';
import '../../domain/models/admin_models.dart';
import '../services/admin_analytics_service.dart';
import '../services/admin_class_service.dart';
import '../services/admin_dashboard_service.dart';
import '../services/admin_document_service.dart';
import '../services/admin_event_service.dart';
import '../services/admin_export_service.dart';
import '../services/admin_fee_service.dart';
import '../services/admin_people_service.dart';

class AdminRepository {
  AdminRepository({
    AdminDashboardService? dashboard,
    AdminPeopleService? people,
    AdminClassService? classes,
    AdminFeeService? fees,
    AdminEventService? events,
    AdminDocumentService? documents,
    AdminAnalyticsService? analytics,
    AdminExportService? export,
  })  : _dashboard = dashboard ?? AdminDashboardService(),
        _people = people ?? AdminPeopleService(),
        _classes = classes ?? AdminClassService(),
        _fees = fees ?? AdminFeeService(),
        _events = events ?? AdminEventService(),
        _documents = documents ?? AdminDocumentService(),
        _analytics = analytics ?? AdminAnalyticsService(),
        _export = export ?? AdminExportService();

  final AdminDashboardService _dashboard;
  final AdminPeopleService _people;
  final AdminClassService _classes;
  final AdminFeeService _fees;
  final AdminEventService _events;
  final AdminDocumentService _documents;
  final AdminAnalyticsService _analytics;
  final AdminExportService _export;

  Future<School?> getPrimarySchool() => _dashboard.getPrimarySchool();

  Future<AdminDashboardStats> getDashboardStats(String schoolId) =>
      _dashboard.getDashboardStats(schoolId);

  Future<List<StudentListItem>> fetchStudents(String schoolId) =>
      _people.fetchStudents(schoolId);

  Future<List<TeacherListItem>> fetchTeachers(String schoolId) =>
      _people.fetchTeachers(schoolId);

  Future<List<ParentListItem>> fetchParents() => _people.fetchParents();

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
  }) =>
      _people.createStudent(
        schoolId: schoolId,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        classId: classId,
        parentId: parentId,
        phone: phone,
        dateOfBirth: dateOfBirth,
        enrollmentDate: enrollmentDate,
      );

  Future<void> updateStudent({
    required Student student,
    required String firstName,
    required String lastName,
    String? classId,
    String? parentId,
    String? phone,
  }) =>
      _people.updateStudent(
        student: student,
        firstName: firstName,
        lastName: lastName,
        classId: classId,
        parentId: parentId,
        phone: phone,
      );

  Future<void> deleteStudent(String id) => _people.deleteStudent(id);

  Future<void> createTeacher({
    required String schoolId,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? specialization,
    String? phone,
  }) =>
      _people.createTeacher(
        schoolId: schoolId,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        specialization: specialization,
        phone: phone,
      );

  Future<void> updateTeacher({
    required Teacher teacher,
    required String firstName,
    required String lastName,
    String? specialization,
    String? phone,
  }) =>
      _people.updateTeacher(
        teacher: teacher,
        firstName: firstName,
        lastName: lastName,
        specialization: specialization,
        phone: phone,
      );

  Future<void> deleteTeacher(String id) => _people.deleteTeacher(id);

  Future<void> createParent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? address,
    String? emergencyContact,
    String? phone,
  }) =>
      _people.createParent(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        address: address,
        emergencyContact: emergencyContact,
        phone: phone,
      );

  Future<void> updateParent({
    required String id,
    required String firstName,
    required String lastName,
    String? address,
    String? emergencyContact,
    String? phone,
  }) =>
      _people.updateParent(
        id: id,
        firstName: firstName,
        lastName: lastName,
        address: address,
        emergencyContact: emergencyContact,
        phone: phone,
      );

  Future<void> deleteParent(String id) => _people.deleteParent(id);

  Future<int> importStudentsFromCsv({
    required String schoolId,
    required List<StudentCsvRow> rows,
  }) =>
      _people.importStudentsFromCsv(schoolId: schoolId, rows: rows);

  Future<List<ClassListItem>> fetchClasses(String schoolId) =>
      _classes.fetchClasses(schoolId);

  Future<List<Map<String, String>>> fetchTeacherOptions(String schoolId) =>
      _classes.fetchTeacherOptions(schoolId);

  Future<SchoolClass> createClass({
    required String schoolId,
    required String name,
    String? teacherId,
  }) =>
      _classes.createClass(
        schoolId: schoolId,
        name: name,
        teacherId: teacherId,
      );

  Future<SchoolClass> updateClass({
    required String id,
    required String name,
    String? teacherId,
  }) =>
      _classes.updateClass(id: id, name: name, teacherId: teacherId);

  Future<void> assignTeacher({
    required String classId,
    required String? teacherId,
  }) =>
      _classes.assignTeacher(classId: classId, teacherId: teacherId);

  Future<void> deleteClass(String id) => _classes.deleteClass(id);

  Future<List<FeeWithStatus>> fetchFees(String schoolId) =>
      _fees.fetchFees(schoolId);

  Future<List<FeePaymentListItem>> fetchPayments(String schoolId) =>
      _fees.fetchPayments(schoolId);

  Future<Fee> createFee({
    required String schoolId,
    required double amount,
    required String description,
    required DateTime dueDate,
    String? classId,
    String? studentId,
  }) =>
      _fees.createFee(
        schoolId: schoolId,
        amount: amount,
        description: description,
        dueDate: dueDate,
        classId: classId,
        studentId: studentId,
      );

  Future<Fee> updateFee({
    required String id,
    required double amount,
    required String description,
    required DateTime dueDate,
    String? classId,
    String? studentId,
  }) =>
      _fees.updateFee(
        id: id,
        amount: amount,
        description: description,
        dueDate: dueDate,
        classId: classId,
        studentId: studentId,
      );

  Future<void> deleteFee(String id) => _fees.deleteFee(id);

  Future<FeePayment> recordPayment({
    required String feeId,
    required String parentId,
    required double amountPaid,
    required String status,
    String? paymentMethod,
  }) =>
      _fees.recordPayment(
        feeId: feeId,
        parentId: parentId,
        amountPaid: amountPaid,
        status: status,
        paymentMethod: paymentMethod,
      );

  Future<List<EventListItem>> fetchEvents(String schoolId) =>
      _events.fetchEvents(schoolId);

  Future<SchoolEvent> createEvent({
    required String schoolId,
    required String title,
    required DateTime eventDate,
    String? description,
  }) =>
      _events.createEvent(
        schoolId: schoolId,
        title: title,
        eventDate: eventDate,
        description: description,
      );

  Future<SchoolEvent> updateEvent({
    required String id,
    required String title,
    required DateTime eventDate,
    String? description,
  }) =>
      _events.updateEvent(
        id: id,
        title: title,
        eventDate: eventDate,
        description: description,
      );

  Future<void> deleteEvent(String id) => _events.deleteEvent(id);

  Future<List<DocumentListItem>> fetchDocuments(String schoolId) =>
      _documents.fetchDocuments(schoolId: schoolId);

  Future<void> uploadDocument({
    required String entityType,
    required String entityId,
    required String documentType,
    required String fileName,
    required Uint8List bytes,
    String? uploadedBy,
  }) =>
      _documents.uploadDocument(
        entityType: entityType,
        entityId: entityId,
        documentType: documentType,
        fileName: fileName,
        bytes: bytes,
        uploadedBy: uploadedBy,
      );

  Future<void> deleteDocument(String id, String fileUrl) =>
      _documents.deleteDocument(id, fileUrl);

  Future<List<ClassPerformance>> fetchClassPerformance(String schoolId) =>
      _analytics.fetchClassPerformance(schoolId);

  Future<List<SubjectTrend>> fetchSubjectTrends(String schoolId) =>
      _analytics.fetchSubjectTrends(schoolId);

  Future<AdminExportData> fetchExportData(String schoolId) =>
      _export.fetchExportData(schoolId);

  String attendanceToCsv(List<Attendance> rows) =>
      _export.attendanceToCsv(rows);

  String resultsToCsv(List<Result> rows) => _export.resultsToCsv(rows);

  List<StudentCsvRow> parseStudentCsv(String content) =>
      _export.parseStudentCsv(content);
}
