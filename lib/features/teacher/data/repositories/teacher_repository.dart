import '../../../shared/domain/entities/announcement.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import '../../../shared/domain/entities/homework.dart';
import '../../../shared/domain/entities/result.dart';
import '../../domain/models/teacher_models.dart';
import '../services/teacher_analytics_service.dart';
import '../services/teacher_announcement_service.dart';
import '../services/teacher_attendance_service.dart';
import '../services/teacher_behaviour_service.dart';
import '../services/teacher_class_service.dart';
import '../services/teacher_homework_service.dart';
import '../services/teacher_results_service.dart';
import '../services/teacher_timetable_service.dart';

class TeacherRepository {
  TeacherRepository({
    TeacherClassService? classes,
    TeacherTimetableService? timetable,
    TeacherAttendanceService? attendance,
    TeacherResultsService? results,
    TeacherHomeworkService? homework,
    TeacherBehaviourService? behaviour,
    TeacherAnnouncementService? announcements,
    TeacherAnalyticsService? analytics,
  })  : _classes = classes ?? TeacherClassService(),
        _timetable = timetable ?? TeacherTimetableService(),
        _attendance = attendance ?? TeacherAttendanceService(),
        _results = results ?? TeacherResultsService(),
        _homework = homework ?? TeacherHomeworkService(),
        _behaviour = behaviour ?? TeacherBehaviourService(),
        _announcements = announcements ?? TeacherAnnouncementService(),
        _analytics = analytics ?? TeacherAnalyticsService();

  final TeacherClassService _classes;
  final TeacherTimetableService _timetable;
  final TeacherAttendanceService _attendance;
  final TeacherResultsService _results;
  final TeacherHomeworkService _homework;
  final TeacherBehaviourService _behaviour;
  final TeacherAnnouncementService _announcements;
  final TeacherAnalyticsService _analytics;

  Future<String?> getTeacherSchoolId(String teacherId) =>
      _classes.fetchTeacherSchoolId(teacherId);

  Future<List<TeacherClassItem>> fetchAssignedClasses(String teacherId) =>
      _classes.fetchAssignedClasses(teacherId);

  Future<List<TeacherStudentItem>> fetchClassStudents(String classId) =>
      _classes.fetchClassStudents(classId);

  Future<List<TeacherSubjectOption>> fetchSubjects(String schoolId) =>
      _classes.fetchSubjects(schoolId);

  Future<List<TeacherTimetableSlot>> fetchTimetable(String teacherId) =>
      _timetable.fetchTimetable(teacherId);

  List<TeacherTimetableSlot> slotsForDay(
    List<TeacherTimetableSlot> all,
    int dayOfWeek,
  ) =>
      _timetable.slotsForDay(all, dayOfWeek);

  Future<List<TeacherAttendanceRow>> fetchAttendanceSheet({
    required String classId,
    required DateTime date,
  }) =>
      _attendance.fetchAttendanceSheet(classId: classId, date: date);

  Future<void> saveAttendance({
    required String classId,
    required DateTime date,
    required List<TeacherAttendanceRow> rows,
  }) =>
      _attendance.saveAttendance(classId: classId, date: date, rows: rows);

  Future<Result> uploadResult({
    required String studentId,
    required String subjectId,
    required String examName,
    required double marksObtained,
    required double maxMarks,
    required DateTime date,
  }) =>
      _results.uploadResult(
        studentId: studentId,
        subjectId: subjectId,
        examName: examName,
        marksObtained: marksObtained,
        maxMarks: maxMarks,
        date: date,
      );

  Future<List<Result>> fetchRecentResultsForClass(String classId) =>
      _results.fetchRecentResultsForClass(classId);

  Future<List<TeacherHomeworkItem>> fetchHomework(String teacherId) =>
      _homework.fetchHomework(teacherId);

  Future<Homework> createHomework({
    required String classId,
    required String subjectId,
    required String teacherId,
    required String title,
    required DateTime dueDate,
    String? description,
  }) =>
      _homework.createHomework(
        classId: classId,
        subjectId: subjectId,
        teacherId: teacherId,
        title: title,
        dueDate: dueDate,
        description: description,
      );

  Future<Homework> updateHomework({
    required String id,
    required String title,
    required DateTime dueDate,
    String? description,
  }) =>
      _homework.updateHomework(
        id: id,
        title: title,
        dueDate: dueDate,
        description: description,
      );

  Future<void> deleteHomework(String id) => _homework.deleteHomework(id);

  Future<List<TeacherBehaviourItem>> fetchBehaviourForClass(String classId) =>
      _behaviour.fetchForClass(classId);

  Future<BehaviourLog> createBehaviourLog({
    required String studentId,
    required String teacherId,
    required String incidentType,
    required String severity,
    required String notes,
    required DateTime date,
  }) =>
      _behaviour.createLog(
        studentId: studentId,
        teacherId: teacherId,
        incidentType: incidentType,
        severity: severity,
        notes: notes,
        date: date,
      );

  Future<void> deleteBehaviourLog(String id) => _behaviour.deleteLog(id);

  Future<List<Announcement>> fetchClassAnnouncements(String classId) =>
      _announcements.fetchClassAnnouncements(classId);

  Future<Announcement> publishClassAnnouncement({
    required String schoolId,
    required String classId,
    required String teacherId,
    required String title,
    required String content,
  }) =>
      _announcements.publishClassAnnouncement(
        schoolId: schoolId,
        classId: classId,
        teacherId: teacherId,
        title: title,
        content: content,
      );

  Future<TeacherDashboardStats> fetchDashboardStats({
    required String teacherId,
    required List<String> classIds,
  }) =>
      _analytics.fetchDashboardStats(
        teacherId: teacherId,
        classIds: classIds,
      );

  Future<List<TeacherClassAnalytics>> fetchClassAnalytics(
    List<String> classIds,
  ) =>
      _analytics.fetchClassAnalytics(classIds);

  Future<List<TeacherAttendanceTrendPoint>> fetchAttendanceTrend(
    String classId, {
    int days = 14,
  }) =>
      _analytics.fetchAttendanceTrend(classId, days: days);
}
