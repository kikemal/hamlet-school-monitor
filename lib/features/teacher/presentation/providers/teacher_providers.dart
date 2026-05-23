import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../domain/models/teacher_models.dart';
import '../../../features/attendance/domain/models/attendance_models.dart';
import '../../../features/attendance/data/repositories/attendance_repository.dart';

final teacherRepositoryProvider = Provider<TeacherRepository>((ref) {
  return TeacherRepository();
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepository();
});

final teacherIdProvider = Provider<String?>((ref) {
  final profile = ref.watch(authProvider).profile;
  if (profile == null || profile.role != 'teacher') return null;
  return profile.id;
});

final teacherSchoolIdProvider = FutureProvider<String?>((ref) async {
  final teacherId = ref.watch(teacherIdProvider);
  if (teacherId == null) return null;
  return ref.read(teacherRepositoryProvider).getTeacherSchoolId(teacherId);
});

final teacherAssignedClassesProvider =
    FutureProvider<List<TeacherClassItem>>((ref) async {
  final teacherId = ref.watch(teacherIdProvider);
  if (teacherId == null) return [];
  return ref.read(teacherRepositoryProvider).fetchAssignedClasses(teacherId);
});

final teacherClassIdsProvider = Provider<List<String>>((ref) {
  return ref.watch(teacherAssignedClassesProvider).value
          ?.map((c) => c.schoolClass.id)
          .toList() ??
      [];
});

/// Selected class used across attendance, behaviour, announcements, analytics.
final teacherSelectedClassIdProvider =
    NotifierProvider<TeacherSelectedClassNotifier, String?>(
  TeacherSelectedClassNotifier.new,
);

class TeacherSelectedClassNotifier extends Notifier<String?> {
  @override
  String? build() {
    ref.listen(teacherAssignedClassesProvider, (prev, next) {
      final classes = next.value;
      if (classes == null || classes.isEmpty) {
        state = null;
        return;
      }
      if (state == null || !classes.any((c) => c.schoolClass.id == state)) {
        state = classes.first.schoolClass.id;
      }
    });
    final classes = ref.read(teacherAssignedClassesProvider).value;
    return classes?.isNotEmpty == true ? classes!.first.schoolClass.id : null;
  }

  void select(String? classId) => state = classId;
}

final teacherDashboardStatsProvider =
    FutureProvider<TeacherDashboardStats>((ref) async {
  final teacherId = ref.watch(teacherIdProvider);
  final classIds = ref.watch(teacherClassIdsProvider);
  if (teacherId == null) return const TeacherDashboardStats();
  return ref.read(teacherRepositoryProvider).fetchDashboardStats(
        teacherId: teacherId,
        classIds: classIds,
      );
});

final teacherTimetableProvider =
    FutureProvider<List<TeacherTimetableSlot>>((ref) async {
  final teacherId = ref.watch(teacherIdProvider);
  if (teacherId == null) return [];
  return ref.read(teacherRepositoryProvider).fetchTimetable(teacherId);
});

final teacherHomeworkProvider =
    FutureProvider.autoDispose<List<TeacherHomeworkItem>>((ref) async {
  final teacherId = ref.watch(teacherIdProvider);
  if (teacherId == null) return [];
  return ref.read(teacherRepositoryProvider).fetchHomework(teacherId);
});

final teacherHomeworkSubmissionsProvider = FutureProvider.autoDispose
    .family<List<TeacherHomeworkSubmissionItem>, String>((ref, homeworkId) async {
  return ref.read(teacherRepositoryProvider).fetchHomeworkSubmissions(homeworkId);
});

final teacherSubjectsProvider =
    FutureProvider.autoDispose<List<TeacherSubjectOption>>((ref) async {
  final schoolId = ref.watch(teacherSchoolIdProvider).value;
  if (schoolId == null) return [];
  return ref.read(teacherRepositoryProvider).fetchSubjects(schoolId);
});

final teacherClassAnalyticsProvider =
    FutureProvider.autoDispose<List<TeacherClassAnalytics>>((ref) async {
  final classIds = ref.watch(teacherClassIdsProvider);
  return ref.read(teacherRepositoryProvider).fetchClassAnalytics(classIds);
});

final teacherAttendanceTrendProvider = FutureProvider.autoDispose
    .family<List<TeacherAttendanceTrendPoint>, String>((ref, classId) async {
  return ref.read(teacherRepositoryProvider).fetchAttendanceTrend(classId);
});

// Attendance providers
final teacherAttendanceSheetProvider = FutureProvider.family
    .autoDispose<List<AttendanceRecord>, String>((ref, classId) {
  final date = ref.watch(attendanceDateProvider);
  return ref
      .read(attendanceRepositoryProvider)
      .fetchAttendanceSheet(classId: classId, date: date);
});

final attendanceDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now(); // Default to today
});

final teacherMonthlyAttendanceProvider = FutureProvider.family
    .autoDispose<List<MonthlyAttendanceSummary>, int>((ref, months) {
  final classId = ref.watch(teacherSelectedClassIdProvider);
  if (classId == null) return [];
  return ref
      .read(attendanceRepositoryProvider)
      .fetchMonthlyAttendance(classId, months: months);
});

final teacherClassAttendanceComparisonProvider =
    FutureProvider.autoDispose<List<ClassAttendanceComparison>>((ref) {
  final classIds = ref.watch(teacherClassIdsProvider);
  if (classIds.isEmpty) return [];
  return ref
      .read(attendanceRepositoryProvider)
      .fetchClassAttendanceComparison(classIds);
});

void teacherInvalidateAll(WidgetRef ref) {
  ref.invalidate(teacherAssignedClassesProvider);
  ref.invalidate(teacherDashboardStatsProvider);
  ref.invalidate(teacherTimetableProvider);
  ref.invalidate(teacherHomeworkProvider);
  ref.invalidate(teacherClassAnalyticsProvider);
  ref.invalidate(attendanceDateProvider);
}
