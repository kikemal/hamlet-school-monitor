import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../../shared/domain/entities/school_event.dart';
import '../../domain/models/parent_models.dart';
import 'parent_service_base.dart';

class ParentCalendarService extends ParentServiceBase {
  Future<List<EventListItem>> fetchEvents(String schoolId) async {
    try {
      final response = await SupabaseConfig.client
          .from('school_events')
          .select()
          .eq('school_id', schoolId)
          .gte('event_date', DateTime.now().toIso8601String())
          .order('event_date', ascending: true);

      return response
          .map((row) => EventListItem(event: SchoolEvent.fromJson(row)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch events: $e');
    }
  }

  Future<List<SchoolEvent>> fetchEventsForMonth(
      String schoolId, DateTime month) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0);

      final response = await SupabaseConfig.client
          .from('school_events')
          .select()
          .eq('school_id', schoolId)
          .gte('event_date', start.toIso8601String())
          .lte('event_date', end.toIso8601String())
          .order('event_date', ascending: true);

      return response.map((row) => SchoolEvent.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch events for month: $e');
    }
  }
}
