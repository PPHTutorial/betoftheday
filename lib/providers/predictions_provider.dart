import 'package:flutter/foundation.dart';
import '../models/prediction_model.dart';
import '../models/league_model.dart';
import '../services/predicd_scraper_service.dart';
import '../services/storage_service.dart';
import '../services/prediction_engine.dart';
import '../services/notification_service.dart';

class PredictionsProvider with ChangeNotifier {
  PredictionsProvider() {
    _eagerLoadInitialData();
  }

  final PredicdScraperService _scraper = PredicdScraperService();
  final StorageService _storage = StorageService();

  List<MatchPrediction> _matches = [];
  List<MatchPrediction> _previousMatches = [];
  List<League> _leagues = [];
  bool _isLoading = false;
  String? _error;
  int _selectedDayOffset = 0;
  String? _selectedLeagueId;
  bool get hasMoreHistory => _hasMoreHistory;
  bool get isFetchingMore => _isFetchingMore;
  DateTime? _lastSyncTime;

  // Pagination State
  bool _hasMoreHistory = true;
  int _historyOffset = 0;
  bool _isFetchingMore = false;
  static const int _historyLimit = 30;

  // Getters
  List<MatchPrediction> get matches => _matches;
  List<MatchPrediction> get previousMatches => _previousMatches;
  List<League> get leagues => _leagues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedDayOffset => _selectedDayOffset;
  String? get selectedLeagueId => _selectedLeagueId;

  /// Live matches (currently in play)
  List<MatchPrediction> get liveMatches =>
      _matches.where((m) => m.isLive).toList();

  /// Upcoming matches (not live)
  List<MatchPrediction> get upcomingMatches =>
      _matches.where((m) => !m.isLive && !m.isFinished).toList();

  /// Results (finished matches)
  List<MatchPrediction> get resultsMatches =>
      _matches.where((m) => m.isFinished).toList();

  /// Entire accumulated history from local DB
  Future<List<MatchPrediction>> get entireHistory =>
      _storage.getHistoricalDatabase();

  /// Matches grouped by league name
  Map<String, List<MatchPrediction>> get matchesByLeague {
    final grouped = <String, List<MatchPrediction>>{};
    for (final match in _matches) {
      if (!grouped.containsKey(match.league)) {
        grouped[match.league] = [];
      }
      grouped[match.league]!.add(match);
    }
    return grouped;
  }

  /// Filtered matches (by selected league)
  List<MatchPrediction> get filteredMatches {
    if (_selectedLeagueId == null || _selectedLeagueId!.isEmpty) {
      return _matches;
    }
    return _matches.where((m) => m.leagueId == _selectedLeagueId).toList();
  }

  /// Filtered matches grouped by league
  Map<String, List<MatchPrediction>> get filteredMatchesByLeague {
    final source = filteredMatches;
    final grouped = <String, List<MatchPrediction>>{};
    for (final match in source) {
      if (!grouped.containsKey(match.league)) {
        grouped[match.league] = [];
      }
      grouped[match.league]!.add(match);
    }
    return grouped;
  }

  /// Get distinct league names from currently loaded matches
  List<String> get availableLeagueNames {
    return _matches.map((m) => m.league).toSet().toList()..sort();
  }

  // ========== INITIALIZATION ==========

  Future<void> _eagerLoadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load cache in parallel — but NOT the heavy historical DB on cold start
      await Future.wait([
        _loadLeaguesFromCache(),
        _loadMatchesFromCache(),
      ]);

      _isLoading = false;
      notifyListeners();

      // Defer silent background fetch by 3 s so the UI fully paints first.
      // This is the primary fix for startup ANR / jank.
      Future.delayed(const Duration(seconds: 3), _aggressiveSilentFetch);
    } catch (e) {
      debugPrint('Error during eager load: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadLeaguesFromCache() async {
    final cached = await _storage.getCachedLeagues();
    if (cached.isNotEmpty) {
      _leagues = cached;
      debugPrint('📦 Loaded ${cached.length} leagues from cache');
    }
  }

  Future<void> _loadMatchesFromCache() async {
    final cached = await _storage.getCachedMatches();
    if (cached.isNotEmpty) {
      _matches = cached;
      debugPrint('📦 Loaded ${cached.length} matches from cache');
      NotificationService().checkAndNotifyMatches(_matches);
    }
  }

  Future<void> loadHistoryFromCache() async {
    final cached = await _storage.getHistoricalDatabase();
    if (cached.isNotEmpty) {
      _previousMatches = cached;
      debugPrint('📦 Loaded ${cached.length} historical matches from cache');
    }
  }

  /// Triggered by UI or App Lifecycle (Foreground)
  Future<void> syncFreshData({bool force = false}) async {
    // Throttle foreground sync to 15 mins unless explicitly forced
    if (!force &&
        _lastSyncTime != null &&
        DateTime.now().difference(_lastSyncTime!).inMinutes < 15) {
      return;
    }
    await _aggressiveSilentFetch();
  }

  bool _isSyncing = false;

  Future<void> _aggressiveSilentFetch() async {
    if (_isSyncing) return; // Prevent concurrent fetches
    _isSyncing = true;
    debugPrint('🚀 Starting Aggressive Silent Fetch...');
    _lastSyncTime = DateTime.now();
    bool dataChanged = false;

    try {
      // 1. Fetch Today, Tomorrow, and Schedule in parallel
      final results = await Future.wait([
        _scraper.fetchTodayMatches(),
        _scraper.fetchMatchSchedule(dayOffset: 1),
        _scraper.fetchAvailableLeagues(),
      ]);

      final List<MatchPrediction> today =
          (results[0] as List).cast<MatchPrediction>();
      final List<MatchPrediction> tomorrow =
          (results[1] as List).cast<MatchPrediction>();
      final List<League> freshLeagues = (results[2] as List).cast<League>();

      final allRecent = [...today, ...tomorrow];
      if (allRecent.isNotEmpty) {
        final enriched =
            await compute(PredictionEngine.calculateAll, allRecent);
        await _storage.cacheMatches(enriched);
        // Merge history off the hot path — fire-and-forget
        _storage.mergeIntoHistoricalDatabase(enriched);
        _matches = enriched;
        dataChanged = true;
        NotificationService().checkAndNotifyMatches(_matches);
      }

      if (freshLeagues.isNotEmpty) {
        _leagues = freshLeagues;
        await _storage.cacheLeagues(freshLeagues);
        dataChanged = true;
      }

      debugPrint('✅ Aggressive Silent Fetch completed.');
    } catch (e) {
      debugPrint('❌ Aggressive Silent Fetch error: $e');
    } finally {
      _isSyncing = false;
      // Only rebuild UI if something actually changed
      if (dataChanged) notifyListeners();
    }
  }

  // ========== ACTIONS ==========

  /// Set day filter (0 = today, 1 = tomorrow, etc.)
  void setDayOffset(int offset) {
    if (_selectedDayOffset == offset) return;
    _selectedDayOffset = offset;
    notifyListeners();
    // No need to loadMatches() here because aggressive fetch covers future days
    // But we sort/filter based on current state
  }

  /// Set league filter
  void setLeagueFilter(String? leagueId) {
    _selectedLeagueId = leagueId;
    notifyListeners();
  }

  /// Clear league filter
  void clearLeagueFilter() {
    _selectedLeagueId = null;
    notifyListeners();
  }

  /// Refresh matches (with optional force flag to bypass 15m throttle)
  Future<void> loadMatches({bool force = false}) async {
    await syncFreshData(force: force);
  }

  /// Lightweight live-only refresh: only scrapes today's matches and updates
  /// live state without running heavy compute isolates or querying all leagues.
  Future<void> refreshLiveMatches() async {
    if (_isSyncing) return;
    try {
      final today = await _scraper.fetchTodayMatches();
      if (today.isEmpty) return;

      final todayMap = {for (var m in today) m.id: m};
      bool changed = false;

      final updated = _matches.map((m) {
        if (todayMap.containsKey(m.id)) {
          final fresh = todayMap[m.id]!;
          if (m.isLive != fresh.isLive ||
              m.isFinished != fresh.isFinished ||
              m.matchTime != fresh.matchTime) {
            changed = true;
          }
          return fresh;
        }
        return m;
      }).toList();

      if (changed) {
        _matches = updated;
        notifyListeners();
        // Persist to cache in background
        _storage.cacheMatches(updated);
        NotificationService().checkAndNotifyMatches(_matches);
      }
    } catch (e) {
      debugPrint('Error refreshing live matches: $e');
    }
  }

  /// Load matches for a specific league
  Future<void> loadLeagueMatches(String leagueId) async {
    _error = null;
    _selectedLeagueId = leagueId;

    // Check if we already have matches for this league in state
    final alreadyLoaded = _matches.any((m) => m.leagueId == leagueId);
    if (!alreadyLoaded) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final freshMatches = await _scraper.fetchLeagueMatches(leagueId);
      final enriched =
          await compute(PredictionEngine.calculateAll, freshMatches);

      // Merge into state silently
      final existingIds = _matches.map((m) => m.id).toSet();
      for (final m in enriched) {
        if (!existingIds.contains(m.id)) {
          _matches.add(m);
        }
      }

      debugPrint(
          '✅ Loaded ${freshMatches.length} matches for league $leagueId');
    } catch (e) {
      debugPrint('❌ Error loading league matches: $e');
      if (!alreadyLoaded) _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load previous (completed) matches for a specific league
  Future<void> loadPreviousMatches(String leagueId) async {
    // Reset pagination
    _historyOffset = 0;
    _hasMoreHistory = true;
    _isFetchingMore = false;
    _selectedLeagueId = leagueId;

    if (leagueId == 'ALL') {
      _isLoading = true;
      notifyListeners();

      final results = await _storage.getHistoricalDatabasePaginated(
        limit: _historyLimit,
        offset: _historyOffset,
      );

      _previousMatches = results;
      _historyOffset += results.length;
      _hasMoreHistory = results.length >= _historyLimit;

      debugPrint(
          '✅ Paginated load: ${results.length} matches from historical DB');
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _scraper.fetchLeagueResults(leagueId);
      _previousMatches = await compute(PredictionEngine.calculateAll, results);
      // Merge into historical DB for advanced analytics
      await _storage.mergeIntoHistoricalDatabase(_previousMatches);

      // Since we just fetched from web, local pagination is irrelevant for this specific league view
      // Unless we want to support local pagination for specific leagues too.
      // For now, only 'ALL' uses the SQLite pagination for sheer volume.
      _hasMoreHistory = false;

      debugPrint(
          '✅ Loaded ${results.length} previous matches for league $leagueId');
    } catch (e) {
      debugPrint('❌ Error loading previous matches: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more history for 'ALL' matches
  Future<void> loadMoreHistory() async {
    if (_isFetchingMore || !_hasMoreHistory || _selectedLeagueId != 'ALL') {
      return;
    }

    _isFetchingMore = true;
    notifyListeners();

    try {
      final results = await _storage.getHistoricalDatabasePaginated(
        limit: _historyLimit,
        offset: _historyOffset,
      );

      if (results.isEmpty) {
        _hasMoreHistory = false;
      } else {
        // Prevent duplicates if sync happened in between
        final existingIds = _previousMatches.map((m) => m.id).toSet();
        final uniqueNew =
            results.where((m) => !existingIds.contains(m.id)).toList();

        _previousMatches.addAll(uniqueNew);
        _historyOffset += results.length;
        _hasMoreHistory = results.length >= _historyLimit;
      }

      debugPrint(
          '✅ Loaded more: ${results.length} matches (Total: ${_previousMatches.length})');
    } catch (e) {
      debugPrint('❌ Error loading more history: $e');
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh
  Future<void> refreshMatches() async {
    await loadMatches();
  }

  /// Reset all data (for Clear Data action)
  void resetData() {
    _matches = [];
    _previousMatches = [];
    _leagues = [];
    _error = null;
    _selectedLeagueId = null;
    notifyListeners();
    debugPrint('🗑️ PredictionsProvider data reset');
  }
}
