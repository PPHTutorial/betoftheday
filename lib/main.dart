import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'services/ad_service.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/predictions_provider.dart';
import 'screens/splash_screen.dart';

// Firebase Messaging
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCxoD09ZD0P_SOFAGGOeGzHHakQ2FwsFPo",
          authDomain: "betoftheday-2022.firebaseapp.com",
          projectId: "betoftheday-2022",
          storageBucket: "betoftheday-2022.appspot.com",
          messagingSenderId: "78357809458",
          appId: "1:78357809458:web:1ea7fccf716dce5f91af2b",
          measurementId: "G-FC9GQ0VLSS",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }
  debugPrint('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCxoD09ZD0P_SOFAGGOeGzHHakQ2FwsFPo",
          authDomain: "betoftheday-2022.firebaseapp.com",
          projectId: "betoftheday-2022",
          storageBucket: "betoftheday-2022.appspot.com",
          messagingSenderId: "78357809458",
          appId: "1:78357809458:web:1ea7fccf716dce5f91af2b",
          measurementId: "G-FC9GQ0VLSS",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }

  // Initialize Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Initialize API Service (async)
  await ApiService().initialize();

  // Initialize Ad Service
  await AdService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Show app open ad when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      AdService.instance.showAppOpenAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PredictionsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Get the effective theme mode (resolve system mode)
          final systemBrightness =
              SchedulerBinding.instance.platformDispatcher.platformBrightness;
          final effectiveThemeMode = themeProvider.themeMode == ThemeMode.system
              ? (systemBrightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light)
              : themeProvider.themeMode;

          // Determine if we're in dark mode
          final bool isDarkMode = effectiveThemeMode == ThemeMode.dark;

          // Status bar: dark icons in light mode, light icons in dark mode
          // This means: light background in light mode, dark background in dark mode
          final Color statusBarColor = Colors.transparent;
          final Brightness statusBarIconBrightness =
              isDarkMode ? Brightness.light : Brightness.dark;
          final Brightness statusBarBrightness =
              isDarkMode ? Brightness.dark : Brightness.light;

          final overlayStyle = SystemUiOverlayStyle(
            statusBarColor: statusBarColor,
            statusBarIconBrightness: statusBarIconBrightness,
            statusBarBrightness: statusBarBrightness,
          );

          SystemChrome.setSystemUIOverlayStyle(overlayStyle);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppConfig.appName,
            theme: AppTheme.lightTheme(context),
            darkTheme: AppTheme.darkTheme(context),
            themeMode: themeProvider.themeMode,
            builder: (context, child) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
