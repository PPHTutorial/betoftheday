import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart' hide Priority;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'services/ad_service.dart';
import 'services/predicd_scraper_service.dart';
import 'services/notification_service.dart';
import 'services/campaign_service.dart';
import 'services/storage_service.dart';
import 'providers/theme_provider.dart';
import 'providers/predictions_provider.dart';
import 'services/background_sync_service.dart';
import 'services/iap_service.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/notifications/notification_inbox_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (fail-soft like Loudable blueprint)
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
      try {
        await Firebase.initializeApp();
      } catch (e) {
        debugPrint('Firebase not configured yet — continuing without push: $e');
      }
    }
  }

  // Initialize Notification Service (FCM & Local)
  await NotificationService.instance.initialize();

  // Initialize Services
  await Future.wait([
    AdService.instance.initialize(),
    IAPService().initialize(),
  ]);

  // Pre-fetch Codeink Campaign in background
  CampaignService.instance.fetch();

  // Initialize Scraper Service
  await PredicdScraperService().initialize();

  // Initialize Background Sync
  await BackgroundSyncService.initialize();
  await BackgroundSyncService.registerPeriodicSync();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PredictionsProvider()),
        ChangeNotifierProvider(create: (_) => IAPService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool _isOnboardingLoaded = false;
  bool _isOnboardingComplete = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.instance.pendingRoute.addListener(_handlePendingRoute);
    _checkOnboarding();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handlePendingRoute();
    });
  }

  void _handlePendingRoute() {
    final route = NotificationService.instance.pendingRoute.value;
    if (route != null && route.isNotEmpty) {
      NotificationService.instance.pendingRoute.value = null;
      rootNavigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const NotificationInboxScreen()),
      );
    }
  }

  Future<void> _checkOnboarding() async {
    final complete = await StorageService().isOnboardingComplete();
    if (mounted) {
      setState(() {
        _isOnboardingComplete = complete;
        _isOnboardingLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    NotificationService.instance.pendingRoute.removeListener(_handlePendingRoute);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Trigger silent sync on foreground return to ensure fresh data
      Provider.of<PredictionsProvider>(context, listen: false).syncFreshData();
      _handlePendingRoute();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final systemBrightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        final effectiveThemeMode = themeProvider.themeMode == ThemeMode.system
            ? (systemBrightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light)
            : themeProvider.themeMode;

        final bool isDarkMode = effectiveThemeMode == ThemeMode.dark;

        const Color statusBarColor = Colors.transparent;
        final Brightness statusBarIconBrightness =
            isDarkMode ? Brightness.light : Brightness.dark;
        final Brightness statusBarBrightness =
            isDarkMode ? Brightness.dark : Brightness.light;

        final Color navBarColor =
            isDarkMode ? const Color(0xFF0F172A) : Colors.white;

        final overlayStyle = SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: statusBarIconBrightness,
          statusBarBrightness: statusBarBrightness,
          systemNavigationBarColor: navBarColor,
          systemNavigationBarIconBrightness: statusBarIconBrightness,
          systemNavigationBarDividerColor: Colors.transparent,
        );

        SystemChrome.setSystemUIOverlayStyle(overlayStyle);

        return MaterialApp(
          navigatorKey: rootNavigatorKey,
          debugShowCheckedModeBanner: false,
          title: AppConfig.appName,
          theme: AppTheme.lightTheme(context,
              accentColor: themeProvider.accentColor),
          darkTheme: AppTheme.darkTheme(context,
              accentColor: themeProvider.accentColor),
          themeMode: themeProvider.themeMode,
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlayStyle,
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: !_isOnboardingLoaded
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : (!_isOnboardingComplete
                  ? const OnboardingScreen()
                  : const MainNavigationScreen()),
        );
      },
    );
  }
}
