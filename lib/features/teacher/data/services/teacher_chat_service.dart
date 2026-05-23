import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_config.dart';
import '../../../../core/services/storage_service.dart';
import '../../../shared/domain/entities/conversation.dart';
import '../../../shared/domain/entities/message.dart';
import '../../../shared/domain/entities/profile.dart';
import 'teacher_service_base.dart';

class TeacherChatService extends TeacherServiceBase {
  final StorageService _storageService = StorageService();

  /// Fetches all parents for a teacher's class
  Future<List<Profile>> fetchParentsForClass(String classId) async {
    try {
      final response = await SupabaseConfig.client
          .from('students')
          .select('''
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
          ''')
          .eq('class_id', classId);

      final parents = <Profile>[];
      for (var student in response) {
        final profile = student['profiles'] as Map<String, dynamic>?;
        if (profile != null && profile['role'] == 'parent') {
          parents.add(Profile.fromJson(profile));
        }
      }

      return parents;
    } catch (e) {
      throw Exception('Failed to fetch parents: $e');
    }
  }

  /// Retrieves an existing conversation or creates one if it doesn't exist
  Future<Conversation> getOrCreateConversation(String teacherId, String parentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('conversations')
          .select()
          .or('and(participant1_id.eq.$teacherId,participant2_id.eq.$parentId),and(participant1_id.eq.$parentId,participant2_id.eq.$teacherId)')
          .maybeSingle();

      if (response != null) {
        return Conversation.fromJson(response);
      }

      final insertResponse = await SupabaseConfig.client
          .from('conversations')
          .insert({
            'participant1_id': teacherId,
            'participant2_id': parentId,
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

  /// Sends a message with an image attachment
  Future<Message> sendMessageWithImage(
    String conversationId,
    String senderId,
    String content,
    File imageFile,
  ) async {
    try {
      final fileUrl = await _storageService.uploadImage(
        imageFile: imageFile,
        conversationId: conversationId,
        senderId: senderId,
      );

      final fileType = _storageService.getFileType(imageFile.path);
      final fileName = _storageService.getFileName(imageFile.path);

      final response = await SupabaseConfig.client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': content,
            'file_url': fileUrl,
            'file_type': fileType,
            'file_name': fileName,
            'is_read': false,
          })
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message with image: $e');
    }
  }

  /// Sends a message with a file attachment
  Future<Message> sendMessageWithFile(
    String conversationId,
    String senderId,
    String content,
    File file,
  ) async {
    try {
      final fileUrl = await _storageService.uploadFile(
        file: file,
        conversationId: conversationId,
        senderId: senderId,
      );

      final fileType = _storageService.getFileType(file.path);
      final fileName = _storageService.getFileName(file.path);

      final response = await SupabaseConfig.client
          .from('messages')
          .insert({
            'conversation_id': conversationId,
            'sender_id': senderId,
            'content': content,
            'file_url': fileUrl,
            'file_type': fileType,
            'file_name': fileName,
            'is_read': false,
          })
          .select()
          .single();

      return Message.fromJson(response);
    } catch (e) {
      throw Exception('Failed to send message with file: $e');
    }
  }

  /// Marks messages as read for a conversation
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await SupabaseConfig.client
          .from('messages')
          .update({'is_read': true})
          .eq('conversation_id', conversationId)
          .neq('sender_id', userId);
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  /// Fetches unread message count for a user
  Future<int> fetchUnreadCount(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('conversations')
          .select('messages!inner(*)')
          .or('participant1_id.eq.$userId,participant2_id.eq.$userId');

      int unreadCount = 0;
      for (var conversation in response) {
        final messages = conversation['messages'] as List?;
        if (messages != null) {
          for (var message in messages) {
            if (message['sender_id'] != userId && message['is_read'] == false) {
              unreadCount++;
            }
          }
        }
      }

      return unreadCount;
    } catch (e) {
      throw Exception('Failed to fetch unread count: $e');
    }
  }

  /// Fetches all conversations for a user with participant details
  Future<List<Map<String, dynamic>>> fetchConversationsWithDetails(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from('conversations')
          .select('''
            *,
            participant1:profiles!conversations_participant1_id_fkey(id, first_name, last_name, avatar_url, role),
            participant2:profiles!conversations_participant2_id_fkey(id, first_name, last_name, avatar_url, role),
            messages(id, content, created_at, is_read, sender_id)
          ''')
          .or('participant1_id.eq.$userId,participant2_id.eq.$userId')
          .order('updated_at', ascending: false);

      return response;
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  /// Sets up a Supabase Realtime channel for new messages in a conversation
  RealtimeChannel subscribeToMessages(
    String conversationId,
    void Function(Message) onMessageReceived,
  ) {
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
