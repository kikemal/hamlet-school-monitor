import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/domain/entities/attendance.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import '../../../shared/domain/entities/conversation.dart';
import '../../../shared/domain/entities/fee.dart';
import '../../../shared/domain/entities/fee_payment.dart';
import '../../../shared/domain/entities/homework.dart';
import '../../../shared/domain/entities/homework_submission.dart';
import '../../../shared/domain/entities/message.dart';
import '../../../shared/domain/entities/profile.dart';
import '../../../shared/domain/entities/result.dart';
import '../../../shared/domain/entities/school_class.dart';
import '../../../shared/domain/entities/school_event.dart';
import '../../../shared/domain/entities/student.dart';
import '../../../shared/domain/entities/teacher.dart';
import '../../data/repositories/parent_repository.dart';
import '../../domain/models/parent_models.dart';

final parentRepositoryProvider = Provider<ParentRepository>((ref) {
  return ParentRepository();
});

final parentChildrenProvider = FutureProvider.autoDispose<List<ChildSummary>>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final parentId = authState.profile?.id;
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
      final parentId = authState.profile?.id;
      if (parentId == null) return const ParentDashboardStats();
      return ref.read(parentRepositoryProvider).fetchDashboardStats(parentId);
    });

final childProfileProvider = FutureProvider.autoDispose<ChildProfile>((
  ref,
) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) throw Exception('No child selected');
  return ref
      .read(parentRepositoryProvider)
      .fetchChildProfile(selectedChild.student.id);
});

final childAttendanceProvider = FutureProvider.autoDispose<List<Attendance>>((
  ref,
) async {
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

final childFeesProvider = FutureProvider.autoDispose<List<FeeWithPayments>>((
  ref,
) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref.read(parentRepositoryProvider).fetchFees(selectedChild.student.id);
});

final parentEventsProvider = FutureProvider.autoDispose<List<EventListItem>>((
  ref,
) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return [];
  return ref
      .read(parentRepositoryProvider)
      .fetchEvents(selectedChild.student.schoolId);
});

final parentEventsForMonthProvider = FutureProvider.family
    .autoDispose<List<SchoolEvent>, DateTime>((ref, month) async {
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
      return ref
          .read(parentRepositoryProvider)
          .fetchAnnouncements(
            selectedChild.student.schoolId,
            classId: selectedChild.student.classId,
          );
    });

// Chat Providers
final childClassTeacherProvider = FutureProvider.autoDispose<Profile?>((
  ref,
) async {
  final selectedChild = ref.watch(selectedChildProvider);
  if (selectedChild == null) return null;
  return ref
      .read(parentRepositoryProvider)
      .fetchTeacherForStudent(selectedChild.student.id);
});

final activeConversationProvider = FutureProvider.autoDispose<Conversation?>((
  ref,
) async {
  final authState = ref.watch(authProvider);
  final parentId = authState.profile?.id;
  if (parentId == null) return null;

  final teacher = ref.watch(childClassTeacherProvider).value;
  if (teacher == null) return null;

  return ref
      .read(parentRepositoryProvider)
      .getOrCreateConversation(parentId, teacher.id);
});

final conversationMessagesProvider =
    StateNotifierProvider.autoDispose<
      ConversationMessagesNotifier,
      List<Message>
    >((ref) {
      final conversation = ref.watch(activeConversationProvider).value;
      final repository = ref.read(parentRepositoryProvider);
      return ConversationMessagesNotifier(repository, conversation);
    });

class ConversationMessagesNotifier extends StateNotifier<List<Message>> {
  ConversationMessagesNotifier(this._repository, this._conversation)
    : super([]) {
    if (_conversation != null) {
      _fetchAndSubscribe();
    }
  }

  final ParentRepository _repository;
  final Conversation? _conversation;
  RealtimeChannel? _subscription;

  Future<void> _fetchAndSubscribe() async {
    if (_conversation == null) return;
    try {
      final messages = await _repository.fetchMessages(_conversation!.id);
      state = messages;

      _subscription = _repository.subscribeToMessages(_conversation!.id, (
        newMessage,
      ) {
        if (!state.any((m) => m.id == newMessage.id)) {
          state = [...state, newMessage];
        }
      });
    } catch (_) {}
  }

  Future<void> sendMessage(String senderId, String content) async {
    if (_conversation == null) return;
    try {
      final message = await _repository.sendMessage(
        _conversation!.id,
        senderId,
        content,
      );
      if (!state.any((m) => m.id == message.id)) {
        state = [...state, message];
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendMessageWithImage(
    String senderId,
    String content,
    File imageFile,
  ) async {
    if (_conversation == null) return;
    try {
      final message = await _repository.sendMessageWithImage(
        _conversation!.id,
        senderId,
        content,
        imageFile,
      );
      if (!state.any((m) => m.id == message.id)) {
        state = [...state, message];
      }
    } catch (_) {
      rethrow;
    }
  }

  Future<void> sendMessageWithFile(
    String senderId,
    String content,
    File file,
  ) async {
    if (_conversation == null) return;
    try {
      final message = await _repository.sendMessageWithFile(
        _conversation!.id,
        senderId,
        content,
        file,
      );
      if (!state.any((m) => m.id == message.id)) {
        state = [...state, message];
      }
    } catch (_) {
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}

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
  ref.invalidate(childClassTeacherProvider);
  ref.invalidate(activeConversationProvider);
  ref.invalidate(conversationMessagesProvider);
}
