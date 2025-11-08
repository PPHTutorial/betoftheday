import 'package:flutter/foundation.dart';
import '../models/prediction_model.dart';
import '../services/api_service.dart';

class PredictionsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PredictionModel> _predictions = [];
  Map<GameType, List<PredictionModel>> _groupedPredictions = {};
  bool _isLoading = false;
  String? _error;

  List<PredictionModel> get predictions => _predictions;
  Map<GameType, List<PredictionModel>> get groupedPredictions =>
      _groupedPredictions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get predictions by game type
  List<PredictionModel> getVipGames() {
    return _predictions
        .where((p) => p.gameType == GameType.vipGame && p.isPending)
        .toList();
  }

  List<PredictionModel> getBetOfTheDayGames() {
    return _predictions
        .where((p) => p.gameType == GameType.betOfTheDay && p.isPending)
        .toList();
  }

  List<PredictionModel> getFreeGames() {
    return _predictions
        .where((p) => p.gameType == GameType.freeGame && p.isPending)
        .toList();
  }

  List<PredictionModel> getCorrectScoreGames() {
    return _predictions
        .where((p) => p.gameType == GameType.correctScore && p.isPending)
        .toList();
  }

  List<PredictionModel> getDrawGames() {
    return _predictions
        .where((p) => p.gameType == GameType.drawGame && p.isPending)
        .toList();
  }

  List<PredictionModel> getPreviousWonGames() {
    final now = DateTime.now();
    final fortyEightHoursAgo = now.subtract(const Duration(hours: 48));

    return _predictions
        .where((p) =>
            !p.isPending &&
            (p.gameType == GameType.vipGame ||
                p.gameType == GameType.betOfTheDay ||
                p.gameType == GameType.correctScore ||
                p.gameType == GameType.drawGame) &&
            p.publishedAt.isAfter(fortyEightHoursAgo))
        .toList();
  }

  Future<void> loadPredictions({
    String? userId,
    String? gameType,
    String? result,
  }) async {
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint('🟢 PredictionsProvider.loadPredictions CALLED');
    debugPrint('═══════════════════════════════════════════════════');
    debugPrint(
        'Parameters: userId=$userId, gameType=$gameType, result=$result');

    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      debugPrint('Calling ApiService.getPredictions...');
      _predictions = await _apiService.getPredictions(
        userId: userId,
        gameType: gameType,
        result: result,
      );

      debugPrint('✅ Received ${_predictions.length} predictions from API');
      _groupPredictions();
      debugPrint('✅ Grouped into ${_groupedPredictions.length} categories');
      _error = null;

      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('✅ SUCCESS: Loaded ${_predictions.length} predictions');
      debugPrint('═══════════════════════════════════════════════════');
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('❌ ERROR in PredictionsProvider.loadPredictions');
      debugPrint('═══════════════════════════════════════════════════');
      debugPrint('Error: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('═══════════════════════════════════════════════════');

      _error = e.toString();
      _predictions = [];
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      debugPrint(
          'Updated loading state: isLoading=false, predictions count=${_predictions.length}');
    }
  }

  void _groupPredictions() {
    _groupedPredictions = {};
    for (final prediction in _predictions) {
      if (!_groupedPredictions.containsKey(prediction.gameType)) {
        _groupedPredictions[prediction.gameType] = [];
      }
      _groupedPredictions[prediction.gameType]!.add(prediction);
    }
  }

  Future<void> refreshPredictions() async {
    await loadPredictions();
  }
}
