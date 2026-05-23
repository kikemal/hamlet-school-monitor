import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/domain/entities/conversation.dart';
import '../../../shared/domain/entities/message.dart';
import '../../../shared/domain/entities/profile.dart';
import '../../domain/models/parent_models.dart';
import '../services/parent_announcement_service.dart';
import '../services/parent_calendar_service.dart';
import '../services/parent_chat_service.dart';
import '../services/parent_child_service.dart';
import '../services/parent_dashboard_service.dart';

class ParentRepository {
  ParentRepository({
    ParentDashboardService? dashboard,
    ParentChildService? child,
    ParentCalendarService? calendar,
    ParentAnnouncementService? announcements,
    ParentChatService? chat,
  })  : _dashboard = dashboard ?? ParentDashboardService(),
        _child = child ?? ParentChildService(),
        _calendar = calendar ?? ParentCalendarService(),
        _announcements = announcements ?? ParentAnnouncementService(),
        _chat = chat ?? ParentChatService();

  final ParentDashboardService _dashboard;
  final ParentChildService _child;
  final ParentCalendarService _calendar;
  final ParentAnnouncementService _announcements;
  final ParentChatService _chat;

  // Dashboard
  Future<List<ChildSummary>> fetchChildren(String parentId) =>
      _dashboard.fetchChildren(parentId);

  Future<ParentDashboardStats> fetchDashboardStats(String parentId) =>
      _dashboard.fetchDashboardStats(parentId);

  // Child
  Future<ChildProfile> fetchChildProfile(String studentId) =>
      _child.fetchChildProfile(studentId);

  Future<List<Attendance>> fetchAttendanceHistory(String studentId) =>
      _child.fetchAttendanceHistory(studentId);

  Future<List<ResultWithDetails>> fetchExamResults(String studentId) =>
      _child.fetchExamResults(studentId);

  Future<List<HomeworkWithSubmission>> fetchHomework(String studentId) =>
      _child.fetchHomework(studentId);

  Future<List<BehaviourLogWithTeacher>> fetchBehaviourLogs(String studentId) =>
      _child.fetchBehaviourLogs(studentId);

  Future<List<FeeWithPayments>> fetchFees(String studentId) =>
      _child.fetchFees(studentId);

  // Calendar
  Future<List<EventListItem>> fetchEvents(String schoolId) =>
      _calendar.fetchEvents(schoolId);

  Future<List<SchoolEvent>> fetchEventsForMonth(String schoolId, DateTime month) =>
      _calendar.fetchEventsForMonth(schoolId, month);

  // Announcements
  Future<List<Announcement>> fetchAnnouncements(String schoolId, {String? classId}) =>
      _announcements.fetchAnnouncements(schoolId, classId: classId);

  // Chat
  Future<Profile?> fetchTeacherForStudent(String studentId) =>
      _chat.fetchTeacherForStudent(studentId);

  Future<Conversation> getOrCreateConversation(String parentId, String teacherId) =>
      _chat.getOrCreateConversation(parentId, teacherId);

  Future<List<Message>> fetchMessages(String conversationId) =>
      _chat.fetchMessages(conversationId);

  Future<Message> sendMessage(String conversationId, String senderId, String content) =>
      _chat.sendMessage(conversationId, senderId, content);

  RealtimeChannel subscribeToMessages(String conversationId, void Function(Message) onMessageReceived) =>
      _chat.subscribeToMessages(conversationId, onMessageReceived);
}
