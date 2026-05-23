import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/parent_repository.dart';
import '../../domain/models/parent_models.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepository();
});

final parentChildrenProvider =
    FutureProvider.autoDispose<List<ChildSummary>>((ref) async {
  final authState = ref.watch(authProvider);
  final parentId = authState.value?.user?.id;
  if (parentId == null) return [];
  return ref.read(parentRepositoryProvider).fetchChildren(parentId);
});

final selectedChildProvider = StateProvider<ChildSummary?>((ref) {
  final children = ref.watch(parentChildrenProvider).value ?? [];
  return children.isNotEmpty ? children.first : null;
});

final parentDashboardStatsProvider =
    FutureProvider.autoDispose<ParentDashboardStats>((ref) async {
  final authState = ref.watch(authProvider);
  final parentId = authState.value?.user?.id;
  if (parentId == null) return const ParentDashboardStats();
  return ref.read(parentRepositoryProvider).fetchDashboardStats(parentId);
});

final childProfileProvider =
    FutureProvider.autoDispose<ChildProfile>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) throw Exception('No child selected');
  return ref
      .read(parentRepositoryProvider)
      .fetchChildProfile(selectedChild.student.id);
});

final childAttendanceProvider =
    FutureProvider.autoDispose<List<Attendance>>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchAttendanceHistory(selectedChild.student.id);
});

final childResultsProvider =
    FutureProvider.autoDispose<List<ResultWithDetails>>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchExamResults(selectedChild.student.id);
});

final childHomeworkProvider =
    FutureProvider.autoDispose<List<HomeworkWithSubmission>>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchHomework(selectedChild.student.id);
});

final childBehaviourProvider =
    FutureProvider.autoDispose<List<BehaviourLogWithTeacher>>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchBehaviourLogs(selectedChild.student.id);
});

final childFeesProvider =
    FutureProvider.autoDispose<List<FeeWithPayments>>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchFees(selectedChild.student.id);
});

final parentEventsProvider =
    FutureProvider.autoDispose<List<EventListItem>>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchEvents(selectedChild.student.schoolId);
});

final parentEventsForMonthProvider =
    FutureProvider.family.autoDispose<List<SchoolEvent>, DateTime>(
        (ref, month) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchEventsForMonth(selectedChild.student.schoolId, month);
});

final parentAnnouncementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref.read(parentRepositoryProvider).fetchAnnouncements(
        selectedChild.student.schoolId,
        classId: selectedChild.student.classId,
      );
});

void parentInvalidateAll(WidgetRef ref) {
  ref.invalidate(parentChildrenProvider);
  ref.invalidate(parentDashboardStatsProvider);
  ref.invalidate(childProfileProvider);
  ref.invalidate(childAttendanceProvider);
  ref.invalidate(childResultsProvider);
  ref.invalidate(childHomeworkProvider);
  ref.invalidate(childBehaviourProvider);
  ref.invalidate(childFeesProvider);
  ref.invalidate(parentEventsProvider);
  ref.invalidate(parentAnnouncementsProvider);
}
