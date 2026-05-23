import '../../../shared/domain/entities/announcement.dart';
import 'teacher_service_base.dart';

class TeacherAnnouncementService extends TeacherServiceBase {
  Future<List<Announcement>> fetchClassAnnouncements(String classId) async {
    final rows = await supabaseClient
        .from('announcements')
        .select()
        .eq('class_id', classId)
        .order('created_at', ascending: false)
        .limit(50);

    return rows.map((r) => Announcement.fromJson(mapRow(r))).toList();
  }

  /// Posts announcement and notifies every student + parent in the class.
  Future<Announcement> publishClassAnnouncement({
    required String schoolId,
    required String classId,
    required String teacherId,
    required String title,
    required String content,
  }) async {
    final row = await supabaseClient
        .from('announcements')
        .insert({
          'school_id': schoolId,
          'class_id': classId,
          'title': title,
          'content': content,
          'created_by': teacherId,
        })
        .select()
        .single();

    final announcement = Announcement.fromJson(mapRow(row));

    final students = await supabaseClient
        .from('students')
        .select('id, parent_id')
        .eq('class_id', classId);

    final recipientIds = <String>{};
    for (final s in students) {
      final map = mapRow(s);
      recipientIds.add(map['id'] as String);
      final parentId = map['parent_id'] as String?;
      if (parentId != null) recipientIds.add(parentId);
    }

    if (recipientIds.isNotEmpty) {
      await supabaseClient.from('notifications').insert(
            recipientIds
                .map(
                  (userId) => {
                    'user_id': userId,
                    'title': title,
                    'body': content,
                  },
                )
                .toList(),
          );
    }

    return announcement;
  }
}
