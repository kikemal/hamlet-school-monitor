import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../shared/domain/entities/announcement.dart';
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
import '../../../shared/domain/entities/timetable.dart';
import '../../data/repositories/student_repository.dart';
import '../../domain/models/student_models.dart';

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepository();
});

final studentProfileProvider =
    FutureProvider.autoDispose<Student>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) throw Exception('No student logged in');
  return ref.read(studentRepositoryProvider).fetchStudentProfile(studentId);
});

final selectedStudentProvider = StateProvider<Student?>((ref) {
  final student = ref.watch(studentProfileProvider).value;
  return student;
});

final studentDashboardStatsProvider =
    FutureProvider.autoDispose<StudentDashboardStats>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) return const StudentDashboardStats();
  return ref
      .read(studentRepositoryProvider)
      .fetchDashboardStats(studentId);
});

final studentTimetableProvider =
    FutureProvider.autoDispose<List<StudentTimetableItem>>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) return [];
  return ref
      .read(studentRepositoryProvider)
      .fetchTimetable(studentId);
});

final studentHomeworkProvider =
    FutureProvider.autoDispose<List<StudentHomeworkWithSubmission>>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) return [];
  return ref
      .read(studentRepositoryProvider)
      .fetchHomework(studentId);
});

final studentResultsProvider =
    FutureProvider.autoDispose<List<StudentResultWithDetails>>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) return [];
  return ref
      .read(studentRepositoryProvider)
      .fetchExamResults(studentId);
});

final studentAttendanceProvider =
    FutureProvider.autoDispose<StudentAttendanceSummary>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) return const StudentAttendanceSummary(
    totalDays: 0,
    presentDays: 0,
    absentDays: 0,
    lateDays: 0,
  );
  return ref
      .read(studentRepositoryProvider)
      .fetchAttendanceHistory(studentId);
});

final studentFeesProvider =
    FutureProvider.autoDispose<StudentFeeSummary>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) return const StudentFeeSummary();
  return ref
      .read(studentRepositoryProvider)
      .fetchFeeSummary(studentId);
});

final studentEventsProvider =
    FutureProvider.autoDispose<List<SchoolEvent>>((ref) async {
  final authState = ref.watch(authProvider);
  final student = ref.watch(studentProfileProvider).value;
  if (student == null) return [];
  return ref
      .read(studentRepositoryProvider)
      .fetchEvents(student.schoolId);
});

final studentEventsForMonthProvider =
    FutureProvider.family.autoDispose<List<SchoolEvent>, DateTime>(
        (ref, month) async {
  final authState = ref.watch(authProvider);
  final student = ref.watch(studentProfileProvider).value;
  if (student == null) return [];
  return ref
      .read(studentRepositoryProvider)
      .fetchEventsForMonth(student.schoolId, month);
});

final studentAnnouncementsProvider =
    FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final authState = ref.watch(authProvider);
  final student = ref.watch(studentProfileProvider).value;
  if (student == null) return [];
  return ref
      .read(studentRepositoryProvider)
      .fetchAnnouncements(
        student.schoolId,
        classId: student.classId,
      );
});

// Chat Providers
final studentClassTeacherProvider = FutureProvider.autoDispose<Profile?>((ref) async {
  final student = ref.watch(studentProfileProvider).value;
  if (student == null) return null;
  return ref.read(studentRepositoryProvider).fetchTeacherForClass(student.classId ?? '');
});

final activeConversationProvider = FutureProvider.autoDispose<Conversation?>((ref) async {
  final authState = ref.watch(authProvider);
  final studentId = authState.profile?.id;
  if (studentId == null) return null;
   
  final teacher = ref.watch(studentClassTeacherProvider).value;
  if (teacher == null) return null;

  return ref.read(studentRepositoryProvider).getOrCreateConversation(studentId, teacher.id);
});

final conversationMessagesProvider = StateNotifierProvider.autoDispose<ConversationMessagesNotifier, List<Message>>((ref) {
  final conversation = ref.watch(activeConversationProvider).value;
  final repository = ref.read(studentRepositoryProvider);
  return ConversationMessagesNotifier(repository, conversation);
});

class ConversationMessagesNotifier extends StateNotifier<List<Message>> {
  ConversationMessagesNotifier(this._repository, this._conversation) : super([]) {
    if (_conversation != null) {
      _fetchAndSubscribe();
    }
  }

  final StudentRepository _repository;
  final Conversation? _conversation;
  // RealtimeChannel? _subscription; // Simplified for now - can be enhanced later

  Future<void> _fetchAndSubscribe() async {
    if (_conversation == null) return;
    try {
      final messages = await _repository.fetchMessages(_conversation!.id);
      state = messages;

      // Simplified realtime - in production would use Supabase Realtime
      // _subscription = _repository.subscribeToMessages(_conversation!.id, (newMessage) {
      //   if (!state.any((m) => m.id == newMessage.id)) {
      //     state = [...state, newMessage];
      //   }
      // });
    } catch (_) {}
  }

  Future<void> sendMessage(String senderId, String content) async {
    if (_conversation == null) return;
    try {
      final message = await _repository.sendMessage(_conversation!.id, senderId, content);
      if (!state.any((m) => m.id == message.id)) {
        state = [...state, message];
      }
    } catch (_) {
      rethrow;
    }
  }

  @override
  void dispose() {
    // _subscription?.unsubscribe();
    super.dispose();
  }
}

void studentInvalidateAll(WidgetRef ref) {
  ref.invalidate(studentProfileProvider);
  ref.invalidate(studentDashboardStatsProvider);
  ref.invalidate(studentTimetableProvider);
  ref.invalidate(studentHomeworkProvider);
  ref.invalidate(studentResultsProvider);
  ref.invalidate(studentAttendanceProvider);
  ref.invalidate(studentFeesProvider);
  ref.invalidate(studentEventsProvider);
  ref.invalidate(studentAnnouncementsProvider);
  ref.invalidate(studentClassTeacherProvider);
  ref.invalidate(activeConversationProvider);
  ref.invalidate(conversationMessagesProvider);
}