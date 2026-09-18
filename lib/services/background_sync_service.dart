import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'predicd_scraper_service.dart';
import 'storage_service.dart';
import 'prediction_engine.dart';
import '../models/league_model.dart';
import '../models/prediction_model.dart';
import 'notification_service.dart';

/// Service to handle background data synchronization from the scraper site.
class BackgroundSyncService {
  static const String syncTaskName = "com.btd.sync_data";
  static const String periodicSyncTask = "com.btd.periodic_sync";

  /// Initialize Workmanager and register the callback dispatcher.
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
      );
      debugPrint("Workmanager initialized");
    } catch (e) {
      debugPrint("Error initializing Workmanager: $e");
    }
  }

  /// Register a periodic background task to sync data every hour.
  static Future<void> registerPeriodicSync() async {
    try {
      await Workmanager().registerPeriodicTask(
        periodicSyncTask,
        syncTaskName,
        frequency:
            const Duration(hours: 1), // Increased frequency for freshness
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );
      debugPrint("Periodic sync task registered (1h frequency)");
    } catch (e) {
      debugPrint("Error registering periodic sync task: $e");
    }
  }

  /// Manually trigger a one-off sync task.
  static Future<void> triggerOneOffSync() async {
    try {
      await Workmanager().registerOneOffTask(
        "${syncTaskName}_oneoff_${DateTime.now().millisecondsSinceEpoch}",
        syncTaskName,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      debugPrint("One-off sync task triggered");
    } catch (e) {
      debugPrint("Error triggering one-off sync task: $e");
    }
  }
}

/// The entry point for the background isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Background task starting: $task");

    try {
      final scraper = PredicdScraperService();
      final storage = StorageService();
      final engine = PredictionEngine();

      await scraper.initialize();

      // 1. Sync Available Leagues first to get the blueprint
      debugPrint("Syncing available leagues...");
      final leagues = await scraper.fetchAvailableLeagues();
      if (leagues.isNotEmpty) {
        await storage.cacheLeagues(leagues);
      }

      // 2. Fetch today's global overview (for quick updates)
      debugPrint("Syncing today's overview...");
      final rawToday = await scraper.fetchTodayMatches();
      if (rawToday.isNotEmpty) {
        final enriched = rawToday.map((m) {
          if (m.recommendations.isNotEmpty) return m;
          return m.copyWith(
              recommendations: engine.calculateRecommendations(m));
        }).toList();
        await storage.cacheMatches(enriched);
      }

      // 3. Vigorous League-Based Deep Sync
      // We iterate through ALL leagues to fetch current + historical data
      debugPrint("Vigorous Deep Sync: Processing ${leagues.length} leagues...");

      final List<MatchPrediction> allCollectedMatches = [];

      // Shuffle leagues to ensure we eventually cover everything
      final shuffledLeagues = List<League>.from(leagues)..shuffle();

      for (final league in shuffledLeagues) {
        try {
          debugPrint("Deep syncing league: ${league.name} (${league.id})");
          final leagueMatches = await scraper.fetchLeagueData(league.id);

          if (leagueMatches.isNotEmpty) {
            final enriched = leagueMatches.map((m) {
              if (m.recommendations.isNotEmpty) return m;
              return m.copyWith(
                  recommendations: engine.calculateRecommendations(m));
            }).toList();

            allCollectedMatches.addAll(enriched);

            // Fetch dedicated historical results for this league to boost volume
            final historicalResults =
                await scraper.fetchLeagueResults(league.id);
            if (historicalResults.isNotEmpty) {
              final enrichedHistory = historicalResults.map((m) {
                if (m.recommendations.isNotEmpty) return m;
                return m.copyWith(
                    recommendations: engine.calculateRecommendations(m));
              }).toList();
              allCollectedMatches.addAll(enrichedHistory);
            }
          }

          // Small delay to respect scraper limits
          await Future.delayed(const Duration(milliseconds: 1000));
        } catch (e) {
          debugPrint("Error in vigorous sync for league ${league.id}: $e");
        }
      }

      // 4. Batch Storage Merging
      // Once all data is collected, we perform a massive merge into storage
      if (allCollectedMatches.isNotEmpty) {
        debugPrint(
            "Vigorous Batch Merge: Processing ${allCollectedMatches.length} collected matches...");

        // Matches with results go to historical database
        final historical =
            allCollectedMatches.where((m) => m.hasResult).toList();
        if (historical.isNotEmpty) {
          await storage.mergeIntoHistoricalDatabase(historical);
        }

        // All matches go to current cache (for today/upcoming/recent views)
        await storage.cacheMatches(allCollectedMatches);

        // Check and send notifications for bookmarked fixtures & favorite teams
        try {
          final notifService = NotificationService();
          await notifService.init();
          await notifService.checkAndNotifyMatches(allCollectedMatches);
        } catch (e) {
          debugPrint("Error dispatching background match notifications: $e");
        }
      }

      debugPrint("Background sync completed successfully.");
      return true;
    } catch (e) {
      debugPrint("Background sync failed: $e");
      return false;
    }
  });
}
