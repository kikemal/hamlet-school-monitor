import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/supabase_config.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  RealtimeChannel? _realtimeChannel;

  /// Initializes local notifications
  Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _localNotifications.initialize(initSettings);

      // Create Android channel
      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'school_notifications_channel',
          'School Notifications',
          description: 'Channel used for critical school updates and announcements.',
          importance: Importance.max,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);
      }
    } catch (_) {
      // Gracefully capture initialization failures on unsupported platforms
    }
  }

  /// Subscribes to Supabase Realtime for the user's notifications
  void subscribeToUserNotifications(String userId) {
    // Clean up existing subscription if any
    unsubscribe();

    try {
      _realtimeChannel = SupabaseConfig.client
          .channel('user-notifications:$userId')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              final title = payload.newRecord['title'] as String? ?? 'New Alert';
              final body = payload.newRecord['body'] as String? ?? '';
              _showNotification(title, body);
            },
          );

      _realtimeChannel!.subscribe();
    } catch (_) {}
  }

  /// Cancels subscription
  void unsubscribe() {
    if (_realtimeChannel != null) {
      try {
        _realtimeChannel!.unsubscribe();
      } catch (_) {}
      _realtimeChannel = null;
    }
  }

  /// Shows a local notification immediately (e.g. from Realtime callbacks).
  Future<void> showLocal({required String title, required String body}) =>
      _showNotification(title, body);

  /// Shows the local notification
  Future<void> _showNotification(String title, String body) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'school_notifications_channel',
        'School Notifications',
        channelDescription: 'Channel used for critical school updates and announcements.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
      );
    } catch (_) {}
  }
}
