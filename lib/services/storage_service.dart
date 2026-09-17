import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/prediction_model.dart';
import '../models/league_model.dart';
import 'database_service.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final DatabaseService _db = DatabaseService();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Storage keys
  static const String _matchesKey = 'cached_matches';
  static const String _leaguesKey = 'cached_leagues';
  static const String _lastFetchKey = 'last_fetch_time';
  static const String _themeModeKey = 'theme_mode';
  static const String _favoriteLeaguesKey = 'favorite_leagues';
  static const String _premiumKey = 'is_premium_user';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _unlockedMatchesKey = 'unlocked_match_ids';
  static const String _bookmarksKey = 'bookmarked_matches';
  static const String _myBetsKey = 'my_bets_json';
  static const String _accentColorKey = 'accent_color';
  static const String _historicalDbKey = 'historical_matches_db';

  // ========== PREMIUM STATUS ==========

  Future<void> setIsPremium(bool isPremium) async {
    try {
      await _storage.write(key: _premiumKey, value: isPremium.toString());
    } catch (e) {
      debugPrint('Error saving premium status: $e');
    }
  }

  Future<bool?> getIsPremium() async {
    try {
      final value = await _storage.read(key: _premiumKey);
      if (value == null) return null;
      return value == 'true';
    } catch (e) {
      debugPrint('Error reading premium status: $e');
      return null;
    }
  }

  Future<bool> getNotificationsEnabled() async {
    try {
      final value = await _storage.read(key: _notificationsKey);
      return value != 'false'; // Default to true
    } catch (e) {
      return true;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _storage.write(key: _notificationsKey, value: enabled.toString());
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
    }
  }

  // ========== BOOKMARKS ==========

  Future<List<String>> getBookmarkedMatchIds() async {
    try {
      final value = await _storage.read(key: _bookmarksKey);
      if (value == null || value.isEmpty) return [];
      return value.split(',');
    } catch (e) {
      debugPrint('Error reading bookmarks: $e');
      return [];
    }
  }

  Future<void> toggleBookmark(String matchId) async {
    try {
      final ids = await getBookmarkedMatchIds();
      if (ids.contains(matchId)) {
        ids.remove(matchId);
      } else {
        ids.add(matchId);
      }
      await _storage.write(key: _bookmarksKey, value: ids.join(','));
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }
  }

  Future<bool> isBookmarked(String matchId) async {
    final ids = await getBookmarkedMatchIds();
    return ids.contains(matchId);
  }

  // ========== MY BETS ==========

  Future<String?> getMyBetsJson() async {
    try {
      return await _storage.read(key: _myBetsKey);
    } catch (e) {
      debugPrint('Error reading bets: $e');
      return null;
    }
  }

  Future<void> saveMyBetsJson(String jsonStr) async {
    try {
      await _storage.write(key: _myBetsKey, value: jsonStr);
    } catch (e) {
      debugPrint('Error saving bets: $e');
    }
  }

  // ========== FREE SLOT MANAGEMENT ==========

  Future<List<String>> getUnlockedMatchIds() async {
    try {
      final value = await _storage.read(key: _unlockedMatchesKey);
      if (value == null || value.isEmpty) return [];
      return value.split(',');
    } catch (e) {
      debugPrint('Error reading unlocked match IDs: $e');
      return [];
    }
  }

  Future<void> saveUnlockedMatchIds(List<String> ids) async {
    try {
      await _storage.write(key: _unlockedMatchesKey, value: ids.join(','));
    } catch (e) {
      debugPrint('Error saving unlocked match IDs: $e');
    }
  }

  Future<void> unlockMatch(String id) async {
    final ids = await getUnlockedMatchIds();
    if (!ids.contains(id)) {
      ids.add(id);
      await saveUnlockedMatchIds(ids);
    }
  }

  Future<bool> isMatchUnlocked(String id) async {
    // If premium, everything is unlocked
    final isPremium = await getIsPremium();
    if (isPremium == true) return true;

    final ids = await getUnlockedMatchIds();
    return ids.contains(id);
  }

  Future<void> cleanupExpiredUnlockedMatches(
      List<MatchPrediction> currentMatches) async {
    final unlockedIds = await getUnlockedMatchIds();
    if (unlockedIds.isEmpty) return;

    // Filter current matches to find those that are in unlockedIds
    // Rolling logic: slot is only consumed if match is NOT finished (Live or Scheduled)
    // Actually the user said: "users have at atleast 5 cards free to show the entire 24 hours but will not show when match is played leaving 4 free cards till all are played"
    // This means if I have 5 cards, and one is played, it's removed from the 5, and I now have 4 occupied, 1 free.

    final newUnlockedIds = <String>[];
    for (final id in unlockedIds) {
      final match = currentMatches.firstWhere((m) => m.id == id,
          orElse: () => MatchPrediction(
              id: '', matchTime: '', homeTeam: '', awayTeam: '', matchUrl: ''));

      if (match.id.isEmpty) {
        // Match not found in current list (maybe old/deleted), remove it
        continue;
      }

      // If match is finished (not live and has actual score or time is 'FT' etc)
      bool isFinished = false;
      if (!match.isLiveMatch) {
        // Check if it's finished. Most scrapers use 'FT' or specific time formats.
        // Based on previous models, we can check if it has a result.
        // However, let's keep it simple: if it's not live and not future, it's likely finished.
        // Actually, let's just use a simple heuristic for now.
        if (match.matchTime.toUpperCase().contains('FT') ||
            match.score != null) {
          isFinished = true;
        }
      }

      if (!isFinished) {
        newUnlockedIds.add(id);
      }
    }

    if (newUnlockedIds.length != unlockedIds.length) {
      await saveUnlockedMatchIds(newUnlockedIds);
    }
  }

  // ========== MATCHES ==========

  Future<void> cacheMatches(List<MatchPrediction> matches) async {
    if (matches.isEmpty) {
      debugPrint('Skipping cache update: 0 matches provided.');
      return;
    }

    try {
      final existingMatches = await getCachedMatches();
      final matchMap = {for (var m in existingMatches) m.id: m};

      // Retention: filter out matches older than 7 days OR stale live matches from previous days
      final now = DateTime.now();
      final cutOff = now.subtract(const Duration(days: 7));
      final startOfToday = DateTime(now.year, now.month, now.day);

      matchMap.removeWhere((id, m) {
        // Remove if older than 7 days
        if (m.matchDate.isBefore(cutOff)) return true;

        // Remove if it's a "Live" match from a previous day (likely a stale cache entry)
        if (m.isLiveMatch && m.matchDate.isBefore(startOfToday)) return true;

        return false;
      });

      // Merge new matches
      for (final match in matches) {
        matchMap[match.id] = match;
      }

      final mergedList = matchMap.values.toList();
      mergedList.sort((a, b) => b.matchDate.compareTo(a.matchDate));

      final jsonStr = MatchPrediction.encodeList(mergedList);
      await _storage.write(key: _matchesKey, value: jsonStr);
      await setLastFetchTime(now);
      debugPrint('Merged and cached ${mergedList.length} matches');
    } catch (e) {
      debugPrint('Error caching matches: $e');
    }
  }

  Future<List<MatchPrediction>> getCachedMatches() async {
    try {
      final jsonStr = await _storage.read(key: _matchesKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      return MatchPrediction.decodeList(jsonStr);
    } catch (e) {
      debugPrint('Error reading cached matches: $e');
      return [];
    }
  }

  // ========== HISTORICAL DATABASE ==========

  Future<void> mergeIntoHistoricalDatabase(
      List<MatchPrediction> newMatches) async {
    try {
      // Filter for matches that actually have a result
      final finishedMatches = newMatches.where((m) => m.hasResult).toList();
      if (finishedMatches.isEmpty) return;

      int addedCount = 0;
      for (final match in finishedMatches) {
        await _db.insertMatch(match);
        addedCount++;
      }

      if (addedCount > 0) {
        debugPrint('Saved $addedCount new matches to SQLite DB.');
        // Cleanup old secure storage key if it exists to free up memory
        await _storage.delete(key: _historicalDbKey);
      }
    } catch (e) {
      debugPrint('Error merging into SQLite DB: $e');
    }
  }

  Future<List<MatchPrediction>> getHistoricalDatabase() async {
    try {
      final sqliteMatches = await _db.getMatches();
      if (sqliteMatches.isNotEmpty) return sqliteMatches;

      // Migration: Try reading from secure storage one last time
      final jsonStr = await _storage.read(key: _historicalDbKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        debugPrint('Migrating historical DB from Secure Storage to SQLite...');
        if (jsonStr.length > 15 * 1024 * 1024) {
          debugPrint(
              'Secure storage DB is too large to migrate safely, clearing it.');
          await _storage.delete(key: _historicalDbKey);
          return [];
        }
        final legacyMatches = MatchPrediction.decodeList(jsonStr);
        await _db.insertMatches(legacyMatches);
        await _storage.delete(key: _historicalDbKey);
        return legacyMatches;
      }
      return [];
    } catch (e) {
      debugPrint('Error reading historical database: $e');
      return [];
    }
  }

  Future<List<MatchPrediction>> getHistoricalDatabasePaginated({
    required int limit,
    required int offset,
    String? leagueId,
  }) async {
    try {
      return await _db.getMatchesPaginated(
        limit: limit,
        offset: offset,
        leagueId: leagueId,
      );
    } catch (e) {
      debugPrint('Error reading paginated historical database: $e');
      return [];
    }
  }

  // ========== LEAGUES ==========

  Future<void> cacheLeagues(List<League> leagues) async {
    try {
      final existing = await getCachedLeagues();
      final leagueMap = {for (var l in existing) l.id: l};

      for (final league in leagues) {
        leagueMap[league.id] = league;
      }

      final mergedList = leagueMap.values.toList();
      final jsonStr = League.encodeList(mergedList);
      await _storage.write(key: _leaguesKey, value: jsonStr);
      debugPrint('Merged and cached ${mergedList.length} leagues');
    } catch (e) {
      debugPrint('Error caching leagues: $e');
    }
  }

  Future<List<League>> getCachedLeagues() async {
    try {
      final jsonStr = await _storage.read(key: _leaguesKey);
      if (jsonStr == null || jsonStr.isEmpty) return [];
      return League.decodeList(jsonStr);
    } catch (e) {
      debugPrint('Error reading cached leagues: $e');
      return [];
    }
  }

  // ========== FAVORITE LEAGUES ==========

  Future<void> saveFavoriteLeagues(List<String> leagueIds) async {
    try {
      await _storage.write(
          key: _favoriteLeaguesKey, value: leagueIds.join(','));
    } catch (e) {
      debugPrint('Error saving favorite leagues: $e');
    }
  }

  Future<List<String>> getFavoriteLeagues() async {
    try {
      final value = await _storage.read(key: _favoriteLeaguesKey);
      if (value == null || value.isEmpty) return [];
      return value.split(',');
    } catch (e) {
      debugPrint('Error reading favorite leagues: $e');
      return [];
    }
  }

  // ========== THEME & ACCENT ==========

  Future<void> saveThemePreference(String themeMode) async {
    try {
      await _storage.write(key: _themeModeKey, value: themeMode);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  Future<String?> getThemePreference() async {
    try {
      return await _storage.read(key: _themeModeKey);
    } catch (e) {
      debugPrint('Error reading theme preference: $e');
      return null;
    }
  }

  Future<void> saveAccentColor(String colorHex) async {
    try {
      await _storage.write(key: _accentColorKey, value: colorHex);
    } catch (e) {
      debugPrint('Error saving accent color: $e');
    }
  }

  Future<String?> getAccentColor() async {
    try {
      return await _storage.read(key: _accentColorKey);
    } catch (e) {
      return null;
    }
  }

  // ========== CACHE FRESHNESS ==========

  Future<void> setLastFetchTime(DateTime time) async {
    try {
      await _storage.write(key: _lastFetchKey, value: time.toIso8601String());
    } catch (e) {
      debugPrint('Error setting last fetch time: $e');
    }
  }

  Future<DateTime?> getLastFetchTime() async {
    try {
      final value = await _storage.read(key: _lastFetchKey);
      if (value == null || value.isEmpty) return null;
      return DateTime.tryParse(value);
    } catch (e) {
      debugPrint('Error reading last fetch time: $e');
      return null;
    }
  }

  Future<bool> isCacheStale(
      {Duration maxAge = const Duration(minutes: 30)}) async {
    final lastFetch = await getLastFetchTime();
    if (lastFetch == null) return true;
    return DateTime.now().difference(lastFetch) > maxAge;
  }

  // ========== ONBOARDING & PROMPTS ==========

  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _firstUnlockPromptKey = 'has_prompted_first_unlock_review';

  Future<bool> isOnboardingComplete() async {
    try {
      final val = await _storage.read(key: _onboardingCompleteKey);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> setOnboardingComplete(bool complete) async {
    try {
      await _storage.write(
          key: _onboardingCompleteKey, value: complete ? 'true' : 'false');
    } catch (e) {
      debugPrint('Error saving onboarding complete: $e');
    }
  }

  Future<bool> hasPromptedFirstUnlockReview() async {
    try {
      final val = await _storage.read(key: _firstUnlockPromptKey);
      return val == 'true';
    } catch (_) {
      return false;
    }
  }

  Future<void> setPromptedFirstUnlockReview(bool prompted) async {
    try {
      await _storage.write(
          key: _firstUnlockPromptKey, value: prompted ? 'true' : 'false');
    } catch (e) {
      debugPrint('Error saving first unlock prompt state: $e');
    }
  }

  // ========== CUSTOM GENERAL STORAGE ==========

  Future<void> saveCustomString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error writing custom key $key: $e');
    }
  }

  Future<String?> getCustomString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      return null;
    }
  }

  Future<void> removeCustomString(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting custom key $key: $e');
    }
  }

  // ========== CLEAR ==========

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      debugPrint('Cleared all storage');
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }
}
