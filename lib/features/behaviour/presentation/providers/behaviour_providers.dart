import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../parent/presentation/providers/parent_providers.dart';
import '../../data/repositories/behaviour_repository.dart';
import '../../data/services/behaviour_realtime_service.dart';
import '../../domain/models/behaviour_models.dart';

final behaviourRepositoryProvider = Provider<BehaviourRepository>((ref) {
  return BehaviourRepository();
});

final behaviourRealtimeServiceProvider = Provider<BehaviourRealtimeService>((ref) {
  final service = BehaviourRealtimeService();
  ref.onDispose(service.unsubscribe);
  return service;
});

final childBehaviourSummaryProvider =
    FutureProvider.autoDispose<BehaviourSummary>((ref) async {
  final child = ref.watch(selectedChildProvider);
  if (child == null) return const BehaviourSummary();
  return ref
      .read(behaviourRepositoryProvider)
      .fetchSummaryForStudent(child.student.id);
});

final studentBehaviourSummaryProvider =
    FutureProvider.autoDispose<BehaviourSummary>((ref) async {
  final auth = ref.watch(authProvider);
  final studentId = auth.profile?.id;
  if (studentId == null) return const BehaviourSummary();
  return ref.read(behaviourRepositoryProvider).fetchSummaryForStudent(studentId);
});

/// Subscribes parent to realtime behaviour log inserts for their children.
final parentBehaviourRealtimeProvider = Provider<void>((ref) {
  final auth = ref.watch(authProvider);
  if (auth.profile?.role != 'parent') return;

  final parentId = auth.profile?.id;
  final children = ref.watch(parentChildrenProvider).value ?? [];
  if (parentId == null || children.isEmpty) return;

  final service = ref.read(behaviourRealtimeServiceProvider);
  final studentIds = children.map((c) => c.student.id).toList();

  service.subscribeToChildLogs(
    parentId: parentId,
    childStudentIds: studentIds,
    onNewLog: () {
      ref.invalidate(childBehaviourProvider);
      ref.invalidate(childBehaviourSummaryProvider);
    },
  );
});
