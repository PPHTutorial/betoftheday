import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../config/app_config.dart';
import '../models/prediction_model.dart';
import '../models/notification_model.dart';
import 'storage_service.dart';

/// Background FCM handler. Must be a top-level (or static) function so the
/// platform can invoke it in a separate isolate when the app is not running.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp();
    } catch (_) {
      return;
    }
  }
  await NotificationService.saveFromRemoteMessage(message);
}

/// Push (FCM) + local notifications service.
///
/// Two independent layers:
///  - **Local** (`flutter_local_notifications`) needs no backend and works
///    the moment the app installs: bookmark alerts, favorite team match updates,
///    live match and kickoff notifications.
///  - **Push** (FCM) handles server broadcasts, match predictions, and updates.
///    Fail-soft: if Firebase is not configured or offline, local notifications
///    continue to work seamlessly.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  static NotificationService get instance => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Route to open for the notification that launched/resumed the app,
  /// e.g. matchId, route.
  final ValueNotifier<String?> pendingRoute = ValueNotifier<String?>(null);

  // Channel IDs
  static const String channelUpdates = 'btd_updates';
  static const String channelBookmarks = 'btd_bookmarks';
  static const String channelFavorites = 'btd_favorites';
  static const String channelHighImportance = 'high_importance_channel';

  static const List<AndroidNotificationChannel> _androidChannels = [
    AndroidNotificationChannel(
      channelUpdates,
      'Match Updates & Tips',
      description: 'Real-time tips, analysis and match predictions',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    ),
    AndroidNotificationChannel(
      channelBookmarks,
      'Bookmarked Matches',
      description: 'Alerts for your saved fixtures (kickoff, live & results)',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    ),
    AndroidNotificationChannel(
      channelFavorites,
      'Favorite Teams Alerts',
      description: 'Matchday, kickoff, and result alerts for your favorite teams',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    ),
    AndroidNotificationChannel(
      channelHighImportance,
      'High Importance Notifications',
      description: 'Critical system and match alerts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    ),
    AndroidNotificationChannel(
      'muvees_broadcasts',
      'Broadcasts & News',
      description: 'Server broadcast notifications and updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    ),
  ];

  FlutterLocalNotificationsPlugin get localNotifications => _localNotifications;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _initLocalNotifications();
    await _initPushNotifications();
  }

  /// Alias for backward compatibility with existing code calling init()
  Future<void> init() => initialize();

  // ── Local notifications ──────────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const settingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false, // Requested explicitly via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings =
        InitializationSettings(android: settingsAndroid, iOS: settingsIOS);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channels explicitly with High Importance
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      for (final channel in _androidChannels) {
        await androidImplementation.createNotificationChannel(channel);
      }
      // Request runtime permission for Android 13+ (API 33+)
      final granted =
          await androidImplementation.requestNotificationsPermission();
      debugPrint('🔔 Android 13+ Notification Permission: $granted');
    }

    final iosImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notification tapped with payload: ${response.payload}');
    final route = response.payload;
    pendingRoute.value = (route != null && route.isNotEmpty) ? route : '/notifications';
  }

  // ── Push notifications (FCM) ─────────────────────────────────────────────

  Future<void> _initPushNotifications() async {
    if (Firebase.apps.isEmpty) {
      debugPrint(
        'NotificationService: Firebase not configured — push disabled, '
        'local notifications active.',
      );
      return;
    }

    try {
      final fcm = FirebaseMessaging.instance;

      // Request APNS / FCM permissions
      final settings = await fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('🔔 FCM AuthorizationStatus: ${settings.authorizationStatus}');

      // iOS requires foreground notification presentation options
      if (!kIsWeb && Platform.isIOS) {
        await fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Subscribe to broadcast topics
      try {
        await fcm.subscribeToTopic(AppConfig.fcmTopic);
        if (AppConfig.fcmTopic != 'all') {
          await fcm.subscribeToTopic('all');
        }
        debugPrint('🔔 Subscribed to topics: ${AppConfig.fcmTopic}, all');
      } catch (e) {
        debugPrint('⚠️ Topic subscription notice: $e');
      }

      // Listen for foreground push messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('🔔 Received foreground message: ${message.messageId}');
        _handleIncomingFcmMessage(message);
      });

      // When user taps on notification from background state
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

      // Cold start: when app launched by tapping notification from terminated state
      final initial = await fcm.getInitialMessage();
      if (initial != null) {
        debugPrint('🔔 FCM Initial Message on cold start: ${initial.messageId}');
        await saveFromRemoteMessage(initial);
        final route = initial.data['route'] as String? ??
            initial.data['matchId'] as String? ??
            initial.data['screen'] as String? ??
            '/notifications';
        pendingRoute.value = route;
      }

      // Optionally cache local token for debugging
      try {
        final token = await fcm.getToken();
        if (token != null) {
          debugPrint('🔥 FCM REGISTRATION TOKEN: $token');
          await StorageService().saveFcmToken(token);
        }
      } catch (e) {
        debugPrint('⚠️ FCM Token notice: $e');
      }
    } catch (e) {
      debugPrint('Firebase messaging config failed: $e');
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) async {
    debugPrint('🔔 FCM Notification opened from background: ${message.data}');
    await saveFromRemoteMessage(message);
    final route = message.data['route'] as String? ??
        message.data['matchId'] as String? ??
        message.data['screen'] as String?;
    if (route != null && route.isNotEmpty) {
      pendingRoute.value = route;
    }
  }

  /// Traps an incoming push notification ([RemoteMessage]) from FCM, whether
  /// received in foreground, background isolate, or app launch.
  static Future<void> saveFromRemoteMessage(RemoteMessage message) async {
    final notif = message.notification;
    final data = message.data;

    final title = notif?.title ?? data['title'] as String? ?? AppConfig.appName;
    final body = notif?.body ?? data['body'] as String? ?? '';

    if (body.isEmpty && notif?.title == null && data.isEmpty) {
      return;
    }

    final homeTeam = data['homeTeam'] as String?;
    final awayTeam = data['awayTeam'] as String?;
    final score = data['score'] as String?;
    final league = data['league'] as String? ?? 'Featured Match';
    final xg = data['xg'] as String?;
    final prediction = data['prediction'] as String?;
    final odds = data['odds'] as String?;
    final matchId = data['matchId'] as String?;

    try {
      final notification = AppNotification(
        id: message.messageId ??
            '${DateTime.now().millisecondsSinceEpoch}_${title.hashCode}',
        title: title,
        body: body.isNotEmpty
            ? body
            : (prediction != null ? 'AI Pick: $prediction' : 'New match update'),
        timestamp: DateTime.now(),
        type: 'server',
        isRead: false,
        matchId: matchId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        score: score,
        xg: xg,
        prediction: prediction,
        odds: odds,
        league: league,
      );
      await StorageService().addNotificationToHistory(notification);
    } catch (e) {
      debugPrint('Error saving FCM notification to history: $e');
    }
  }

  // =========================================================================
  //  INCOMING FCM FOREGROUND PUSH MESSAGE HANDLER (RICH BIGTEXT PARSER)
  // =========================================================================

  Future<void> _handleIncomingFcmMessage(RemoteMessage message) async {
    await saveFromRemoteMessage(message);

    final notifsOn = await StorageService().getNotificationsEnabled();
    if (!notifsOn) return;

    final notif = message.notification;
    final data = message.data;

    final title = notif?.title ?? data['title'] ?? 'Bet Of The Day';
    final homeTeam = data['homeTeam'];
    final awayTeam = data['awayTeam'];
    final score = data['score'];
    final matchTime = data['matchTime'];
    final xg = data['xg'];
    final prediction = data['prediction'];
    final prob = data['prob'];
    final odds = data['odds'];
    final league = data['league'] ?? 'Featured Match';

    // If payload contains rich match fields, render an expandable card
    if (homeTeam != null && awayTeam != null) {
      final lines = <String>[
        if (score != null) 'Score: $score ($matchTime)',
        if (xg != null) 'xG: $xg',
        if (prob != null) 'Win Prob: $prob',
        if (prediction != null) 'AI Pick: $prediction',
        if (odds != null) 'Odds: $odds',
        'Tap to inspect live expected goals & probability model.',
      ];

      final bigText = lines.join('\n');
      final summary = '$league • Live Play';

      final bigTextStyle = BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: summary,
      );

      _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        lines.first,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelUpdates,
            'Match Updates & Tips',
            channelDescription: 'Real-time tips and match predictions',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: bigTextStyle,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
      return;
    }

    // Default push display
    final body = notif?.body ?? data['body'] ?? 'New match update available';
    final bigTextStyle = BigTextStyleInformation(
      body,
      contentTitle: title,
      summaryText: AppConfig.appName,
    );

    _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelUpdates,
          'Match Updates & Tips',
          channelDescription: 'Real-time tips and match predictions',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          styleInformation: bigTextStyle,
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  // =========================================================================
  //  BOOKMARK NOTIFICATIONS
  // =========================================================================

  /// Immediate feedback notification when a user bookmarks a match
  Future<void> showBookmarkNotification(MatchPrediction match) async {
    try {
      final enabled = await StorageService().getBookmarkedNotifsEnabled();
      if (!enabled) return;

      final notifsOn = await StorageService().getNotificationsEnabled();
      if (!notifsOn) return;

      final tip = (match.prediction != null && match.prediction!.isNotEmpty)
          ? match.prediction!
          : (match.recommendations.isNotEmpty
              ? match.recommendations.first.prediction
              : 'Match Tracked');

      await _showRichMatchNotification(
        id: (match.id.hashCode & 0x7FFFFFFF),
        channelId: channelBookmarks,
        channelName: 'Bookmarked Matches',
        title: '📌 Match Bookmarked: ${match.homeTeam} vs ${match.awayTeam}',
        summary: '${match.league} • Tracked Fixture',
        match: match,
        customHeadline: '🔔 Alerts armed for kickoff, live score changes & full-time result.\n🎯 Top Pick: $tip',
      );
    } catch (e) {
      debugPrint('Failed to show bookmark notification: $e');
    }
  }

  // =========================================================================
  //  CHECK & NOTIFY MATCHES (BOOKMARKS & FAVORITE TEAMS)
  // =========================================================================

  /// High-level check called when new matches are loaded or during background sync
  Future<void> checkAndNotifyMatches(List<MatchPrediction> matches) async {
    try {
      final globalEnabled = await StorageService().getNotificationsEnabled();
      if (!globalEnabled) return;

      await Future.wait([
        checkAndNotifyBookmarkedMatches(matches),
        checkAndNotifyFavoriteTeams(matches),
      ]);
    } catch (e) {
      debugPrint('Error checking match notifications: $e');
    }
  }

  /// Checks bookmarked matches and triggers relevant notifications
  Future<void> checkAndNotifyBookmarkedMatches(List<MatchPrediction> matches) async {
    try {
      final enabled = await StorageService().getBookmarkedNotifsEnabled();
      if (!enabled) return;

      final bookmarkedIds = await StorageService().getBookmarkedMatchIds();
      if (bookmarkedIds.isEmpty) return;

      final bookmarkedSet = bookmarkedIds.toSet();
      final bookmarkedMatches =
          matches.where((m) => bookmarkedSet.contains(m.id)).toList();

      final storage = StorageService();

      for (final match in bookmarkedMatches) {
        // 1. LIVE match notification with team play statistics
        if (match.isLive) {
          final eventKey = 'bm_live_${match.id}';
          if (!await storage.hasEventBeenNotified(eventKey)) {
            await storage.markEventNotified(eventKey);
            final scoreText = match.score != null ? 'Score: ${match.score} (${match.matchTime})' : 'Underway (${match.matchTime})';
            await _showRichMatchNotification(
              id: (match.id.hashCode ^ 0x01) & 0x7FFFFFFF,
              channelId: channelBookmarks,
              channelName: 'Bookmarked Matches',
              title: '🔴 LIVE: ${match.homeTeam} vs ${match.awayTeam}',
              summary: '${match.league} • Live Play',
              match: match,
              customHeadline: '⚽ $scoreText\nLive Expected Goals & momentum model updating in real time.',
            );
          }
        }
        // 2. FINISHED match notification with result & play stats
        else if (match.isFinished) {
          final eventKey = 'bm_finished_${match.id}';
          if (!await storage.hasEventBeenNotified(eventKey)) {
            await storage.markEventNotified(eventKey);
            final scoreStr = match.score ?? 'Final';
            final tipResult = (match.prediction != null && match.prediction!.isNotEmpty)
                ? ' • Pick: ${match.prediction}'
                : (match.recommendations.isNotEmpty ? ' • Pick: ${match.recommendations.first.prediction}' : '');

            await _showRichMatchNotification(
              id: (match.id.hashCode ^ 0x02) & 0x7FFFFFFF,
              channelId: channelBookmarks,
              channelName: 'Bookmarked Matches',
              title: '🏁 Result: ${match.homeTeam} $scoreStr ${match.awayTeam}',
              summary: '${match.league} • Full Time',
              match: match,
              customHeadline: 'Full-time concluded$tipResult. Check final xG and performance analysis.',
            );
          }
        }
        // 3. UPCOMING match notification (scheduled today)
        else {
          final eventKey = 'bm_kickoff_${match.id}';
          final now = DateTime.now();
          final isToday = match.matchDate.year == now.year &&
              match.matchDate.month == now.month &&
              match.matchDate.day == now.day;

          if (isToday && !await storage.hasEventBeenNotified(eventKey)) {
            await storage.markEventNotified(eventKey);
            final time = match.matchTime.isNotEmpty ? match.matchTime : 'Today';
            await _showRichMatchNotification(
              id: (match.id.hashCode ^ 0x03) & 0x7FFFFFFF,
              channelId: channelBookmarks,
              channelName: 'Bookmarked Matches',
              title: '⏰ Match Day: ${match.homeTeam} vs ${match.awayTeam}',
              summary: '${match.league} • Kickoff at $time',
              match: match,
              customHeadline: 'Kickoff today at $time. Lineups, statistical odds and predictions ready.',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error notifying bookmarked matches: $e');
    }
  }

  /// Checks favorite teams and triggers relevant notifications
  Future<void> checkAndNotifyFavoriteTeams(List<MatchPrediction> matches) async {
    try {
      final enabled = await StorageService().getFavoriteTeamsNotifsEnabled();
      if (!enabled) return;

      final favTeams = await StorageService().getFavoriteTeams();
      if (favTeams.isEmpty) return;

      final favTeamSet = favTeams.map((t) => t.toLowerCase().trim()).toSet();
      final storage = StorageService();

      for (final match in matches) {
        final homeIsFav = favTeamSet.contains(match.homeTeam.toLowerCase().trim());
        final awayIsFav = favTeamSet.contains(match.awayTeam.toLowerCase().trim());

        if (!homeIsFav && !awayIsFav) continue;

        final favTeamName = homeIsFav ? match.homeTeam : match.awayTeam;

        // 1. LIVE match notification for favorite team
        if (match.isLive) {
          final eventKey = 'fav_live_${match.id}_$favTeamName';
          if (!await storage.hasEventBeenNotified(eventKey)) {
            await storage.markEventNotified(eventKey);
            final scoreStr = match.score != null ? 'Score: ${match.score}' : 'In Play';
            await _showRichMatchNotification(
              id: (match.id.hashCode ^ 0x11) & 0x7FFFFFFF,
              channelId: channelFavorites,
              channelName: 'Favorite Teams Alerts',
              title: '🔴 LIVE: $favTeamName in Action!',
              summary: '${match.league} • ${match.matchTime}',
              match: match,
              customHeadline: '⚽ $scoreStr (${match.matchTime})\n$favTeamName is currently in play. Watch live xG & stats.',
            );
          }
        }
        // 2. FINISHED match notification for favorite team
        else if (match.isFinished) {
          final eventKey = 'fav_finished_${match.id}_$favTeamName';
          if (!await storage.hasEventBeenNotified(eventKey)) {
            await storage.markEventNotified(eventKey);
            final scoreStr = match.score ?? 'Final';
            await _showRichMatchNotification(
              id: (match.id.hashCode ^ 0x12) & 0x7FFFFFFF,
              channelId: channelFavorites,
              channelName: 'Favorite Teams Alerts',
              title: '🏁 Final: $favTeamName Match Finished',
              summary: '${match.league} • Result',
              match: match,
              customHeadline: '⚽ ${match.homeTeam} $scoreStr ${match.awayTeam}\nReview post-match expected goals and tactical summary.',
            );
          }
        }
        // 3. UPCOMING matchday notification for favorite team
        else {
          final eventKey = 'fav_today_${match.id}_$favTeamName';
          final now = DateTime.now();
          final isToday = match.matchDate.year == now.year &&
              match.matchDate.month == now.month &&
              match.matchDate.day == now.day;

          if (isToday && !await storage.hasEventBeenNotified(eventKey)) {
            await storage.markEventNotified(eventKey);
            final time = match.matchTime.isNotEmpty ? match.matchTime : 'Today';
            await _showRichMatchNotification(
              id: (match.id.hashCode ^ 0x13) & 0x7FFFFFFF,
              channelId: channelFavorites,
              channelName: 'Favorite Teams Alerts',
              title: '⭐ Matchday: $favTeamName Plays Today',
              summary: '${match.league} • $time',
              match: match,
              customHeadline: '$favTeamName takes on ${homeIsFav ? match.awayTeam : match.homeTeam} today at $time!',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error notifying favorite teams: $e');
    }
  }

  // =========================================================================
  //  RICH NOTIFICATION TRAY BUILDER (EXPANDABLE BIG-TEXT WITH TEAM PLAY STATS)
  // =========================================================================

  Future<void> _showRichMatchNotification({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String summary,
    required MatchPrediction match,
    String? customHeadline,
  }) async {
    try {
      // 1. Extract Expected Goals (xG)
      final homeXg = match.matchStats?.homeTeamExpectedGoals;
      final awayXg = match.matchStats?.awayTeamExpectedGoals;
      final xgLine = (homeXg != null && awayXg != null)
          ? 'xG: $homeXg - $awayXg'
          : null;

      // 2. Extract Team Form (Last 5)
      final homeForm = match.matchStats?.homeTeamForm;
      final awayForm = match.matchStats?.awayTeamForm;
      final formLine = (homeForm != null && awayForm != null)
          ? 'Form: $homeForm vs $awayForm'
          : null;

      // 3. Extract Win Probabilities
      final hProb = match.matchResult?.homeTeamProb;
      final dProb = match.matchResult?.drawProb;
      final aProb = match.matchResult?.awayTeamProb;
      final probLine = (hProb != null && dProb != null && aProb != null)
          ? 'Win Prob: ${match.homeTeam} $hProb • Draw $dProb • ${match.awayTeam} $aProb'
          : null;

      // 4. Extract Top Pick / Tip
      final pick = (match.prediction != null && match.prediction!.isNotEmpty)
          ? match.prediction!
          : (match.recommendations.isNotEmpty
              ? match.recommendations.first.prediction
              : null);
      final pickLine = pick != null ? 'Model Pick: $pick' : null;

      // 5. Extract Betting Odds
      final oddsLine = (match.homeTeamOdds != null && match.awayTeamOdds != null)
          ? 'Odds: 1: ${match.homeTeamOdds} | X: ${match.drawOdds ?? "-"} | 2: ${match.awayTeamOdds}'
          : null;

      // 6. Venue & Stadium
      final stadium = match.matchStats?.stadium;
      final venueLine = stadium != null && stadium.isNotEmpty ? 'Venue: $stadium' : null;

      // Assemble BigText card for expanded notification tray view
      final lines = <String>[
        if (customHeadline != null) customHeadline,
        if (xgLine != null) xgLine,
        if (formLine != null) formLine,
        if (probLine != null) probLine,
        if (pickLine != null) pickLine,
        if (oddsLine != null) oddsLine,
        if (venueLine != null) venueLine,
        'Tap to inspect full match analytics & AI confidence score.',
      ];

      final bigText = lines.join('\n');
      final singleLineBody = lines.firstWhere((l) => l.isNotEmpty,
          orElse: () => 'Tap to open live match analysis');

      final bigTextStyle = BigTextStyleInformation(
        bigText,
        contentTitle: title,
        summaryText: summary,
        htmlFormatBigText: false,
        htmlFormatContentTitle: false,
        htmlFormatSummaryText: false,
      );

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: bigTextStyle,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications.show(
        id,
        title,
        singleLineBody,
        NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: match.id,
      );

      // Persist to inbox history
      _persistToInbox(
        title: title,
        body: bigText,
        type: channelId == channelFavorites ? 'favorite' : 
              channelId == channelBookmarks ? 'bookmark' : 'general',
        matchId: match.id,
        homeTeam: match.homeTeam,
        awayTeam: match.awayTeam,
        score: match.score,
        xg: (homeXg != null && awayXg != null) ? '$homeXg - $awayXg' : null,
        prediction: pick,
        odds: (match.homeTeamOdds != null) ? '1: ${match.homeTeamOdds} | X: ${match.drawOdds ?? "-"} | 2: ${match.awayTeamOdds}' : null,
        league: match.league,
        venue: stadium,
      );
    } catch (e) {
      debugPrint('Error displaying rich notification [$title]: $e');
    }
  }

  /// Direct rich test notification triggered by user in Settings to test device reception & tray expansion
  Future<void> sendTestNotification() async {
    try {
      await init();
      final randomId = Random().nextInt(100000);

      const bigText =
          '72\' | Arsenal 2 - 1 Chelsea\n'
          'xG: 1.84 - 0.92  |  Form: W-W-D vs L-W-D\n'
          'Win Prob: Arsenal 65% • Draw 20% • Chelsea 15%\n'
          'Model Pick: Both Teams To Score (Yes) & Over 2.5\n'
          'Odds: 1: 1.75 | X: 3.80 | 2: 4.60\n'
          'Venue: Emirates Stadium, London\n'
          'Tap to inspect live expected goals & probability model.';

      const bigTextStyle = BigTextStyleInformation(
        bigText,
        contentTitle: 'LIVE 72\' | Arsenal 2 - 1 Chelsea',
        summaryText: 'Premier League • Live Play',
      );

      await _localNotifications.show(
        randomId,
        'LIVE 72\' | Arsenal 2 - 1 Chelsea',
        'Arsenal leads 2-1! xG: 1.84 - 0.92 • Top Pick: Over 2.5 Goals',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelUpdates,
            'Match Updates & Tips',
            channelDescription: 'Real-time tips and match predictions',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            styleInformation: bigTextStyle,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Failed to send test notification: $e');
    }
  }

  // =========================================================================
  //  INBOX HISTORY PERSISTENCE HELPER
  // =========================================================================

  void _persistToInbox({
    required String title,
    required String body,
    String type = 'general',
    String? matchId,
    String? homeTeam,
    String? awayTeam,
    String? score,
    String? xg,
    String? prediction,
    String? odds,
    String? league,
    String? venue,
  }) {
    try {
      final notification = AppNotification(
        id: '${DateTime.now().millisecondsSinceEpoch}_${title.hashCode}',
        title: title,
        body: body,
        timestamp: DateTime.now(),
        type: type,
        isRead: false,
        matchId: matchId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        score: score,
        xg: xg,
        prediction: prediction,
        odds: odds,
        league: league,
        venue: venue,
      );
      // Fire-and-forget persistence so we never block the notification display
      StorageService().addNotificationToHistory(notification);
    } catch (e) {
      debugPrint('Error persisting notification to inbox: $e');
    }
  }
}
