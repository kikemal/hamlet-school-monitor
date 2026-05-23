import '../../../shared/domain/entities/school_event.dart';
import '../../domain/models/admin_models.dart';
import 'admin_service_base.dart';

class AdminEventService extends AdminServiceBase {
  Future<List<EventListItem>> fetchEvents(String schoolId) async {
    final rows = await supabaseClient
        .from('school_events')
        .select()
        .eq('school_id', schoolId)
        .order('event_date');

    return rows
        .map((r) => EventListItem(event: SchoolEvent.fromJson(mapRow(r))))
        .toList();
  }

  Future<SchoolEvent> createEvent({
    required String schoolId,
    required String title,
    required DateTime eventDate,
    String? description,
  }) async {
    final row = await supabaseClient
        .from('school_events')
        .insert({
          'school_id': schoolId,
          'title': title,
          'event_date': eventDate.toUtc().toIso8601String(),
          if (description != null) 'description': description,
        })
        .select()
        .single();
    return SchoolEvent.fromJson(mapRow(row));
  }

  Future<SchoolEvent> updateEvent({
    required String id,
    required String title,
    required DateTime eventDate,
    String? description,
  }) async {
    final row = await supabaseClient
        .from('school_events')
        .update({
          'title': title,
          'event_date': eventDate.toUtc().toIso8601String(),
          'description': description,
        })
        .eq('id', id)
        .select()
        .single();
    return SchoolEvent.fromJson(mapRow(row));
  }

  Future<void> deleteEvent(String id) async {
    await supabaseClient.from('school_events').delete().eq('id', id);
  }
}
