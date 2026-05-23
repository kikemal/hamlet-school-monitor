import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/domain/entities/attendance.dart';
import '../../domain/models/attendance_models.dart';
import '../services/attendance_service.dart';

class AttendanceRepository {
  AttendanceRepository({
    AttendanceService? attendance,
  })  : _attendance = attendance ?? AttendanceService();

  final AttendanceService _attendance;

  // Teacher attendance management
  Future<List<AttendanceRecord>> fetchAttendanceSheet({
    required String classId,
    required DateTime date,
  }) => _attendance.fetchAttendanceSheet(
        classId: classId,
        date: date,
      );

  Future<void> saveAttendance({
    required String classId,
    required DateTime date,
    required List<AttendanceRecord> records,
  }) => _attendance.saveAttendance(
        classId: classId,
        date: date,
        records: records,
      );

  // Student attendance history
  Future<List<Attendance>> fetchStudentAttendanceHistory(
      String studentId) =>
      _attendance.fetchStudentAttendanceHistory(studentId);

  // Analytics
  Future<List<MonthlyAttendanceSummary>> fetchMonthlyAttendance(
      String classId, {
      required int months,
  }) => _attendance.fetchMonthlyAttendance(
        classId: classId,
        months: months,
      );

  Future<List<ClassAttendanceComparison>> fetchClassAttendanceComparison(
      List<String> classIds) =>
      _attendance.fetchClassAttendanceComparison(classIds);

  // Admin exports
  Future<List<AttendanceExportRecord>> fetchAttendanceForExport({
    required String schoolId,
    DateTime? startDate,
    DateTime? endDate,
  }) => _attendance.fetchAttendanceForExport(
        schoolId: schoolId,
        startDate: startDate,
        endDate: endDate,
      );
}