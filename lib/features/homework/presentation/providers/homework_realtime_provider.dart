import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/homework_realtime_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../parent/presentation/providers/parent_providers.dart';
import '../../../student/presentation/providers/student_providers.dart';

final homeworkRealtimeServiceProvider = Provider<HomeworkRealtimeService>((ref) {
  final service = HomeworkRealtimeService();
  ref.onDispose(service.unsubscribe);
  return service;
});

/// Subscribes student to overdue homework realtime for their class.
final studentHomeworkRealtimeProvider = Provider<void>((ref) {
  final auth = ref.watch(authProvider);
  if (auth.profile?.role != 'student') return;

  final studentId = auth.profile?.id;
  final student = ref.watch(studentProfileProvider).value;
  if (studentId == null || student?.classId == null) return;

  final service = ref.read(homeworkRealtimeServiceProvider);
  final repo = ref.read(studentRepositoryProvider);

  service.subscribeToClassHomework(
    classId: student!.classId!,
    notifyUserId: studentId,
    fetchSubmittedHomeworkIds: () => repo.fetchSubmittedHomeworkIds(studentId),
    onOverdueAlert: (_, __) {},
  );
});

/// Subscribes parent to child's class homework overdue alerts.
final parentHomeworkRealtimeProvider = Provider<void>((ref) {
  final auth = ref.watch(authProvider);
  if (auth.profile?.role != 'parent') return;

  final parentId = auth.profile?.id;
  final child = ref.watch(selectedChildProvider);
  if (parentId == null || child == null) return;

  final classId = child.student.classId;
  if (classId == null) return;

  final service = ref.read(homeworkRealtimeServiceProvider);
  final repo = ref.read(parentRepositoryProvider);

  service.subscribeToClassHomework(
    classId: classId,
    notifyUserId: parentId,
    fetchSubmittedHomeworkIds: () async {
      final list = await repo.fetchHomework(child.student.id);
      return list.where((h) => h.isSubmitted).map((h) => h.homework.id).toList();
    },
    onOverdueAlert: (_, __) {},
  );
});
