import '../models/prediction_model.dart';
import '../models/sample_data_model.dart';

/// Service for grouping and categorizing predictions
class DataGroupingService {
  final SampleDataModel sampleData;

  DataGroupingService(this.sampleData);

  /// Group predictions by GameType
  Map<GameType, List<PredictionModel>> groupByGameType() {
    final Map<GameType, List<PredictionModel>> grouped = {};

    for (final prediction in sampleData.predictions) {
      grouped.putIfAbsent(prediction.gameType, () => []).add(prediction);
    }

    return grouped;
  }

  /// Group predictions by Result status
  Map<PredictionResult, List<PredictionModel>> groupByResult() {
    final Map<PredictionResult, List<PredictionModel>> grouped = {};

    for (final prediction in sampleData.predictions) {
      grouped.putIfAbsent(prediction.result, () => []).add(prediction);
    }

    return grouped;
  }

  /// Group predictions by League
  Map<String, List<PredictionModel>> groupByLeague() {
    final Map<String, List<PredictionModel>> grouped = {};

    for (final prediction in sampleData.predictions) {
      grouped.putIfAbsent(prediction.league, () => []).add(prediction);
    }

    return grouped;
  }

  /// Group predictions by Date (publishedAt)
  Map<String, List<PredictionModel>> groupByDate() {
    final Map<String, List<PredictionModel>> grouped = {};

    for (final prediction in sampleData.predictions) {
      final dateKey = _formatDateKey(prediction.publishedAt);
      grouped.putIfAbsent(dateKey, () => []).add(prediction);
    }

    return grouped;
  }

  /// Group predictions by Title categories (based on titles array and gameType)
  /// Note: Previously Won and Midnight Owl are separate categories, not replacements
  Map<String, List<PredictionModel>> groupByTitle() {
    final Map<String, List<PredictionModel>> grouped = {};

    // Create title mapping
    final titleMap = <String, String>{};
    for (final title in sampleData.titles) {
      titleMap[title.id] = title.customTitle;
    }

    // Group by gameType and map to titles
    for (final prediction in sampleData.predictions) {
      // Primary grouping by gameType
      String titleKey;

      switch (prediction.gameType) {
        case GameType.vipGame:
          titleKey = titleMap['1'] ?? 'Vip Predictions';
          break;
        case GameType.betOfTheDay:
          titleKey = titleMap['2'] ?? 'Bet of the day';
          break;
        case GameType.freeGame:
          titleKey = titleMap['3'] ?? 'Free Hot Odds';
          break;
        case GameType.correctScore:
          titleKey = 'Correct Score';
          break;
        case GameType.drawGame:
          titleKey = 'Draw Games';
          break;
      }

      grouped.putIfAbsent(titleKey, () => []).add(prediction);

      // Additional grouping for "Previously Won" (if won)
      if (prediction.result == PredictionResult.won && !prediction.isPending) {
        final prevWonKey = titleMap['4'] ?? 'Previously Won Matches';
        grouped.putIfAbsent(prevWonKey, () => []).add(prediction);
      }

      // Additional grouping for "Midnight Owl" (if late night)
      if (prediction.isPending &&
          (prediction.publishedAt.hour >= 23 ||
              prediction.publishedAt.hour < 6)) {
        final midnightOwlKey = titleMap['5'] ?? 'Midnight Owl';
        grouped.putIfAbsent(midnightOwlKey, () => []).add(prediction);
      }
    }

    return grouped;
  }

  /// Get VIP Predictions (pending only)
  List<PredictionModel> getVipPredictions() {
    return sampleData.predictions
        .where((p) => p.gameType == GameType.vipGame && p.isPending)
        .toList();
  }

  /// Get Bet of the Day (pending only)
  List<PredictionModel> getBetOfTheDay() {
    return sampleData.predictions
        .where((p) => p.gameType == GameType.betOfTheDay && p.isPending)
        .toList();
  }

  /// Get Free Games (pending only)
  List<PredictionModel> getFreeGames() {
    return sampleData.predictions
        .where((p) => p.gameType == GameType.freeGame && p.isPending)
        .toList();
  }

  /// Get Previously Won Matches (won predictions within last 48 hours)
  List<PredictionModel> getPreviouslyWonMatches() {
    final now = DateTime.now();
    final fortyEightHoursAgo = now.subtract(const Duration(hours: 48));

    return sampleData.predictions
        .where((p) =>
            p.result == PredictionResult.won &&
            (p.gameType == GameType.vipGame ||
                p.gameType == GameType.betOfTheDay ||
                p.gameType == GameType.correctScore ||
                p.gameType == GameType.drawGame) &&
            p.publishedAt.isAfter(fortyEightHoursAgo))
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  /// Get Midnight Owl predictions (games scheduled late night, typically 11 PM - 6 AM)
  List<PredictionModel> getMidnightOwlPredictions() {
    return sampleData.predictions
        .where((p) =>
            p.isPending && (p.publishedAt.hour >= 23 || p.publishedAt.hour < 6))
        .toList()
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
  }

  /// Get Today's Games (published today)
  List<PredictionModel> getTodayGames() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    return sampleData.predictions
        .where((p) =>
            p.isPending &&
            p.publishedAt.isAfter(todayStart) &&
            p.publishedAt.isBefore(todayEnd))
        .toList()
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
  }

  /// Get predictions by League
  List<PredictionModel> getPredictionsByLeague(String league) {
    return sampleData.predictions
        .where((p) => p.league == league && p.isPending)
        .toList()
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
  }

  /// Get predictions by Sport Type
  List<PredictionModel> getPredictionsBySportType(String sportType) {
    return sampleData.predictions
        .where((p) => p.sportType == sportType && p.isPending)
        .toList()
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
  }

  /// Get all unique leagues
  List<String> getAllLeagues() {
    final leagues =
        sampleData.predictions.map((p) => p.league).toSet().toList();
    leagues.sort();
    return leagues;
  }

  /// Get all unique sport types
  List<String> getAllSportTypes() {
    final sportTypes =
        sampleData.predictions.map((p) => p.sportType).toSet().toList();
    sportTypes.sort();
    return sportTypes;
  }

  /// Get latest betting code
  BettingCodeModel? getLatestBettingCode() {
    if (sampleData.betslip.isEmpty) return null;
    sampleData.betslip.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sampleData.betslip.first;
  }

  /// Format date key for grouping
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get predictions grouped by multiple criteria
  Map<String, dynamic> getAllGroupings() {
    return {
      'byGameType': groupByGameType(),
      'byResult': groupByResult(),
      'byLeague': groupByLeague(),
      'byDate': groupByDate(),
      'byTitle': groupByTitle(),
      'vipPredictions': getVipPredictions(),
      'betOfTheDay': getBetOfTheDay(),
      'freeGames': getFreeGames(),
      'previouslyWon': getPreviouslyWonMatches(),
      'midnightOwl': getMidnightOwlPredictions(),
      'todayGames': getTodayGames(),
      'leagues': getAllLeagues(),
      'sportTypes': getAllSportTypes(),
      'latestBettingCode': getLatestBettingCode(),
    };
  }
}
