import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../shared/domain/entities/conversation.dart';
import '../../../shared/domain/entities/message.dart';
import '../../../shared/domain/entities/profile.dart';
import 'parent_service_base.dart';

class ParentChatService extends ParentServiceBase {
  /// Fetches the class teacher for a student
  Future<Profile?> fetchTeacherForStudent(String studentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('students')
          .select('''
            class_id,
            school_classes!inner(
              teacher_id,
              teachers!inner(
                specialization,
                profiles!inner(
                  id,
                  role,
                  first_name,
                  last_name,
                  avatar_url,
                  phone,
                  created_at,
                  updated_at
                )
              )
            )
          ''')
          .eq('id', studentId)
          .maybeSingle();

      if (response == null) return null;

      final schoolClass = response['school_classes'] as Map<String, dynamic>?;
      if (schoolClass == null) return null;

      final teacher = schoolClass['teachers'] as Map<String, dynamic>?;
      if (teacher == null) return null;

      final profile = teacher['profiles'] as Map<String, dynamic>?;
      if (profile == null) return null;

      return Profile.fromJson(profile);
    } catch (e) {
      throw Exception('Failed to fetch class teacher: $e');
    }
  }

  /// Retrieves an existing conversation or creates one if it doesn't exist
  Future<Conversation> getOrCreateConversation(String parentId, String teacherId) async {
    try {
      final response = await SupabaseConfig.client
          .from('conversations')
          .select()
          .or('and(participant1_id.eq.$parentId,participant2_id.eq.$teacherId),and(participant1_id.eq.$teacherId,participant2_id.eq.$parentId)')
          .maybeSingle();

      if (response != null) {
        return Conversation.fromJson(response);
      }

      final insertResponse = await SupabaseConfig.client
          .from('conversations')
          .insert({
            'participant1_id': parentId,
            'participant2_id': teacherId,
          })
          .select()
          .single();

      return Conversation.fromJson(insertResponse);
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

  /// Fetches all messages for a conversation
  Future<List<Message>> fetchMessages(String conversationId) async {
    try {
      final response = await SupabaseConfig.client
          .from('messages')
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);

      return response.map((row) => Message.fromJson(row)).toList();
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  /// Sends a message in a conversation
  Future<Message> sendMessage(String conversationId, String senderId, String content) async {
    try {
      final response = await SupabaseConfig.client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': content,
            'is_read': false,
          })
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Sets up a Supabase Realtime channel for new messages in a conversation
  RealtimeChannel subscribeToMessages(String conversationId, void Function(Message) onMessageReceived) {
    final channel = SupabaseConfig.client
        .channel('conversation:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversationId,
          ),
          callback: (payload) {
            final newMessage = Message.fromJson(payload.newRecord);
            onMessageReceived(newMessage);
          },
        );
    
    channel.subscribe();
    return channel;
  }
}
