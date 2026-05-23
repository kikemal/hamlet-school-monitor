import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/base_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../shared/domain/entities/behaviour_log.dart';
import '../../domain/models/behaviour_models.dart';

/// Notifies parents when a behaviour log is added for their child.
class BehaviourRealtimeService extends BaseService {
  RealtimeChannel? _channel;
  final Set<String> _seenLogIds = {};

  void subscribeToChildLogs({
    required String parentId,
    required List<String> childStudentIds,
    required void Function() onNewLog,
  }) {
    unsubscribe();
    if (childStudentIds.isEmpty) return;

    _channel = supabaseClient.channel('behaviour-parent:$parentId');

    for (final studentId in childStudentIds) {
      _channel!.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'behaviour_logs',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'student_id',
          value: studentId,
        ),
        callback: (payload) {
          final id = payload.newRecord['id'] as String?;
          if (id == null || _seenLogIds.contains(id)) return;
          _seenLogIds.add(id);

          final item = BehaviourLogDisplayItem.fromLog(
            BehaviourLog(
              id: id,
              studentId: payload.newRecord['student_id'] as String? ?? '',
              teacherId: payload.newRecord['teacher_id'] as String? ?? '',
              incidentType:
                  payload.newRecord['incident_type'] as String? ?? 'negative',
              description: payload.newRecord['description'] as String? ?? '',
              severity: payload.newRecord['severity'] as String?,
              date: DateTime.tryParse(
                    payload.newRecord['date'] as String? ?? '',
                  ) ??
                  DateTime.now(),
            ),
          );

          PushNotificationService.instance.showLocal(
            title: 'New behaviour incident',
            body:
                '${item.severity[0].toUpperCase()}${item.severity.substring(1)}: ${item.notes}',
          );
          onNewLog();
        },
      );
    }

    _channel!.subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void resetSeen() => _seenLogIds.clear();
}
