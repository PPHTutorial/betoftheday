import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/app_config.dart';
import '../models/prediction_model.dart';
import 'storage_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Local notifications
      const settingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const settingsIOS = DarwinInitializationSettings();
      const initSettings =
          InitializationSettings(android: settingsAndroid, iOS: settingsIOS);

      await _localNotifications.initialize(initSettings);

      // Attempt Firebase init (will fail if google-services.json isn't present, safely catch)
      try {
        if (Firebase.apps.isNotEmpty) {
          final messaging = FirebaseMessaging.instance;
          await messaging.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );

          // Subscribe to broadcast topic btd_all as specified in blueprint
          await messaging.subscribeToTopic(AppConfig.fcmTopic);
          if (AppConfig.fcmTopic != 'all') {
            await messaging.subscribeToTopic('all');
          }
          debugPrint('FCM subscribed to topics: ${AppConfig.fcmTopic}, all');

          // Listen for foreground push messages
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            final title = message.notification?.title ?? message.data['title'];
            final body = message.notification?.body ?? message.data['body'];
            if (title != null || body != null) {
              _localNotifications.show(
                DateTime.now().millisecondsSinceEpoch ~/ 1000,
                title ?? AppConfig.appName,
                body ?? 'New prediction update available',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'btd_updates',
                    'Match Updates & Tips',
                    channelDescription: 'Real-time tips and match predictions',
                    importance: Importance.high,
                    priority: Priority.high,
                  ),
                  iOS: DarwinNotificationDetails(),
                ),
              );
            }
          });
        }
      } catch (e) {
        debugPrint('Firebase config missing or failed: $e');
      }
    } catch (e) {
      debugPrint('Notification init failed: $e');
    }
  }

  Future<void> showBookmarkNotification(MatchPrediction match) async {
    try {
      final enabled = await StorageService().getNotificationsEnabled();
      if (!enabled) return;

      await _localNotifications.show(
        match.id.hashCode,
        'Match Bookmarked!',
        'You will be reminded before ${match.homeTeam} vs ${match.awayTeam}.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'match_reminders',
            'Match Reminders',
            channelDescription: 'Reminders for bookmarked matches',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Failed to show bookmark notification: $e');
    }
  }
}
