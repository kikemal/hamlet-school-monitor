import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/domain/entities/conversation.dart';
import '../../../shared/domain/entities/message.dart';
import '../../../shared/domain/entities/profile.dart';
import '../../domain/models/student_models.dart';
import 'dart:typed_data';

import '../../../shared/domain/entities/homework_submission.dart';
import '../services/student_dashboard_service.dart';
import '../services/student_homework_service.dart';

class StudentRepository {
  StudentRepository({
    StudentDashboardService? dashboard,
    StudentHomeworkService? homework,
  })  : _dashboard = dashboard ?? StudentDashboardService(),
        _homework = homework ?? StudentHomeworkService();

  final StudentDashboardService _dashboard;
  final StudentHomeworkService _homework;

  // Dashboard
  Future<Student> fetchStudentProfile(String studentId) =>
      _dashboard.fetchStudentProfile(studentId);

  Future<List<StudentTimetableItem>> fetchTimetable(String studentId) =>
      _dashboard.fetchTimetable(studentId);

  Future<List<StudentHomeworkWithSubmission>> fetchHomework(String studentId) =>
      _homework.fetchHomework(studentId);

  Future<List<String>> fetchSubmittedHomeworkIds(String studentId) =>
      _homework.fetchSubmittedHomeworkIds(studentId);

  Future<HomeworkSubmission> submitHomework({
    required String homeworkId,
    required String studentId,
    String? submissionText,
    Uint8List? fileBytes,
    String? fileName,
  }) =>
      _homework.submitHomework(
        homeworkId: homeworkId,
        studentId: studentId,
        submissionText: submissionText,
        fileBytes: fileBytes,
        fileName: fileName,
      );

  Future<List<StudentResultWithDetails>> fetchExamResults(String studentId) =>
      _dashboard.fetchExamResults(studentId);

  Future<StudentAttendanceSummary> fetchAttendanceHistory(String studentId) =>
      _dashboard.fetchAttendanceHistory(studentId);

  Future<StudentFeeSummary> fetchFeeSummary(String studentId) =>
      _dashboard.fetchFeeSummary(studentId);

  Future<StudentDashboardStats> fetchDashboardStats(String studentId) =>
      _dashboard.fetchDashboardStats(studentId);

  // Chat functionality (similar to parent)
  Future<Profile?> fetchTeacherForClass(String classId) async {
    try {
      final response = await SupabaseConfig.client
          .from('school_classes')
          .select('''
            teacher_id,
            teachers!inner (
              profiles!inner (
                id,
                first_name,
                last_name,
                avatar_url,
                phone,
                created_at,
                updated_at
              )
            )
          ''')
          .eq('id', classId)
          .single();

      final teacher = response['teachers'] as Map<String, dynamic>?;
      if (teacher == null) return null;

      final profile = teacher['profiles'] as Map<String, dynamic>?;
      if (profile == null) return null;

      return Profile.fromJson(profile);
    } catch (e) {
      throw Exception('Failed to fetch class teacher: $e');
    }
  }

  Future<Conversation> getOrCreateConversation(String studentId, String teacherId) async {
    try {
      final response = await SupabaseConfig.client
          .from('conversations')
          .select()
          .or('and(participant1_id.eq.$studentId,participant2_id.eq.$teacherId),and(participant1_id.eq.$teacherId,participant2_id.eq.$studentId)')
          .maybeSingle();

      if (response != null) {
        return Conversation.fromJson(response);
      }

      final insertResponse = await SupabaseConfig.client
          .from('conversations')
          .insert({
            'participant1_id': studentId,
            'participant2_id': teacherId,
          })
          .select()
          .single();

      return Conversation.fromJson(insertResponse);
    } catch (e) {
      throw Exception('Failed to get or create conversation: $e');
    }
  }

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

  // Simplified realtime subscription for messages
  // In a full implementation, this would use Supabase Realtime similar to parent chat
}