import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/base_service.dart';
import '../../../shared/domain/entities/homework.dart';

/// Subscribes to homework changes and emits overdue alerts for students/parents.
class HomeworkRealtimeService extends BaseService {
  RealtimeChannel? _homeworkChannel;
  final Set<String> _notifiedHomeworkIds = {};

  /// Listens for homework assigned to [classId] and checks overdue items.
  void subscribeToClassHomework({
    required String classId,
    required String notifyUserId,
    required Future<List<String>> Function() fetchSubmittedHomeworkIds,
    required void Function(String title, String body) onOverdueAlert,
  }) {
    unsubscribe();

    _homeworkChannel = supabaseClient
        .channel('homework-overdue:$classId:$notifyUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'homework',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'class_id',
            value: classId,
          ),
          callback: (_) => _checkOverdue(
            classId: classId,
            notifyUserId: notifyUserId,
            fetchSubmittedHomeworkIds: fetchSubmittedHomeworkIds,
            onOverdueAlert: onOverdueAlert,
          ),
        )
      ..subscribe();

    _checkOverdue(
      classId: classId,
      notifyUserId: notifyUserId,
      fetchSubmittedHomeworkIds: fetchSubmittedHomeworkIds,
      onOverdueAlert: onOverdueAlert,
    );
  }

  Future<void> _checkOverdue({
    required String classId,
    required String notifyUserId,
    required Future<List<String>> Function() fetchSubmittedHomeworkIds,
    required void Function(String title, String body) onOverdueAlert,
  }) async {
    try {
      final rows = await supabaseClient
          .from('homework')
          .select()
          .eq('class_id', classId)
          .lt('due_date', DateTime.now().toUtc().toIso8601String());

      final submittedIds = await fetchSubmittedHomeworkIds();
      final submittedSet = submittedIds.toSet();

      for (final row in rows) {
        final hw = Homework.fromJson(Map<String, dynamic>.from(row));
        if (submittedSet.contains(hw.id)) continue;
        if (_notifiedHomeworkIds.contains(hw.id)) continue;

        _notifiedHomeworkIds.add(hw.id);
        const title = 'Homework overdue';
        final body = '"${hw.title}" was due ${hw.dueDate.toLocal().toString().split(' ').first}';
        onOverdueAlert(title, body);

        await supabaseClient.from('notifications').insert({
          'user_id': notifyUserId,
          'title': title,
          'body': body,
        });
      }
    } catch (_) {}
  }

  void unsubscribe() {
    _homeworkChannel?.unsubscribe();
    _homeworkChannel = null;
  }

  void resetNotifiedCache() => _notifiedHomeworkIds.clear();
}
