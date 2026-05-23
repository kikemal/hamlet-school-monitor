import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/school.dart';
import '../../data/repositories/admin_repository.dart';
import '../../domain/models/admin_models.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

final adminSchoolProvider = FutureProvider<School?>((ref) async {
  return ref.read(adminRepositoryProvider).getPrimarySchool();
});

final adminSchoolIdProvider = Provider<String?>((ref) {
  return ref.watch(adminSchoolProvider).value?.id;
});

final adminDashboardStatsProvider =
    FutureProvider<AdminDashboardStats>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return const AdminDashboardStats();
  return ref.read(adminRepositoryProvider).getDashboardStats(schoolId);
});

final adminStudentsProvider =
    FutureProvider.autoDispose<List<StudentListItem>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchStudents(schoolId);
});

final adminTeachersProvider =
    FutureProvider.autoDispose<List<TeacherListItem>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchTeachers(schoolId);
});

final adminParentsProvider =
    FutureProvider.autoDispose<List<ParentListItem>>((ref) async {
  return ref.read(adminRepositoryProvider).fetchParents();
});

final adminClassesProvider =
    FutureProvider.autoDispose<List<ClassListItem>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchClasses(schoolId);
});

final adminTeacherOptionsProvider =
    FutureProvider.autoDispose<List<Map<String, String>>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchTeacherOptions(schoolId);
});

final adminFeesProvider =
    FutureProvider.autoDispose<List<FeeWithStatus>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchFees(schoolId);
});

final adminFeePaymentsProvider =
    FutureProvider.autoDispose<List<FeePaymentListItem>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchPayments(schoolId);
});

final adminEventsProvider =
    FutureProvider.autoDispose<List<EventListItem>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchEvents(schoolId);
});

final adminDocumentsProvider =
    FutureProvider.autoDispose<List<DocumentListItem>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchDocuments(schoolId);
});

final adminClassPerformanceProvider =
    FutureProvider.autoDispose<List<ClassPerformance>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchClassPerformance(schoolId);
});

final adminSubjectTrendsProvider =
    FutureProvider.autoDispose<List<SubjectTrend>>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) return [];
  return ref.read(adminRepositoryProvider).fetchSubjectTrends(schoolId);
});

final adminExportDataProvider =
    FutureProvider.autoDispose<AdminExportData>((ref) async {
  final schoolId = ref.watch(adminSchoolIdProvider);
  if (schoolId == null) {
    return const AdminExportData(attendance: [], results: []);
  }
  return ref.read(adminRepositoryProvider).fetchExportData(schoolId);
});

void adminInvalidateAll(WidgetRef ref) {
  ref.invalidate(adminDashboardStatsProvider);
  ref.invalidate(adminStudentsProvider);
  ref.invalidate(adminTeachersProvider);
  ref.invalidate(adminParentsProvider);
  ref.invalidate(adminClassesProvider);
  ref.invalidate(adminFeesProvider);
  ref.invalidate(adminFeePaymentsProvider);
  ref.invalidate(adminEventsProvider);
  ref.invalidate(adminDocumentsProvider);
  ref.invalidate(adminClassPerformanceProvider);
  ref.invalidate(adminSubjectTrendsProvider);
  ref.invalidate(adminExportDataProvider);
}
