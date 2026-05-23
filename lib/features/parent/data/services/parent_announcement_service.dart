import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/supabase_config.dart';
import '../../../shared/domain/entities/announcement.dart';
import 'parent_service_base.dart';

class ParentAnnouncementService extends ParentServiceBase {
  Future<List<Announcement>> fetchAnnouncements(String schoolId, {String? classId}) async {
    try {
      final query = SupabaseConfig.client
          .from('announcements')
          .select()
          .eq('school_id', schoolId)
          .order('created_at', ascending: false)
          .limit(50);

      if (classId != null) {
        query.or('class_id.eq.$classId,class_id.is.null');
      }

      final response = await query;
      return response.map((row) => Announcement.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }
}
