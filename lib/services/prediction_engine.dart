import '../models/prediction_model.dart';

class PredictionEngine {
  static final PredictionEngine _instance = PredictionEngine._internal();
  factory PredictionEngine() => _instance;
  PredictionEngine._internal();

  /// Calculate all recommendations for a given match
  List<BetRecommendation> calculateRecommendations(MatchPrediction match) {
    if (match.matchResult == null) return [];

    final recs = <BetRecommendation>[];

    // 1. Match Result (1x2)
    final hProb = match.homeProbability;
    final dProb = match.drawProbability;
    final aProb = match.awayProbability;

    _addIfSignificant(recs, "Match Result", "Home Win", hProb);
    _addIfSignificant(recs, "Match Result", "Draw", dProb);
    _addIfSignificant(recs, "Match Result", "Away Win", aProb);

    // 2. Double Chance
    _addIfSignificant(
        recs, "Double Chance", "1X (Home or Draw)", hProb + dProb);
    _addIfSignificant(
        recs, "Double Chance", "X2 (Away or Draw)", aProb + dProb);
    _addIfSignificant(
        recs, "Double Chance", "12 (Home or Away)", hProb + aProb);

    // 3. Both Teams to Score (BTTS)
    // Derived from goal probabilities (simplified estimate)
    // If prob(0-1 goals) is high, BTTS is likely No.
    final goalProbs = match.matchResult?.goalProbabilities ?? {};
    final zeroOneProb = _parsePct(goalProbs['0-1']);
    final twoThreeProb = _parsePct(goalProbs['2-3']);
    final threePlusProb = _parsePct(goalProbs['>3']);

    // Heuristic for BTTS
    double bttsYes = 0.0;
    if (threePlusProb > 0.4)
      bttsYes = 0.75;
    else if (twoThreeProb > 0.5)
      bttsYes = 0.60;
    else if (zeroOneProb > 0.6)
      bttsYes = 0.20;
    else
      bttsYes = 0.50;

    _addIfSignificant(recs, "BTTS", "Yes", bttsYes);
    _addIfSignificant(recs, "BTTS", "No", 1.0 - bttsYes);

    // 4. Over / Under
    // Predicd gives 0-1, 2-3, >3

    // Safety Net: Over 0.5 Goals (Hits >92% of the time)
    // Estimate 0 goals (0-0 draw) as roughly 40% of the 0-1 bracket
    double probZeroGoals = zeroOneProb * 0.4;
    _addIfSignificant(
        recs, "Over/Under", "Over 0.5 Goals", 1.0 - probZeroGoals);

    // Safety Net: Under 4.5 & 5.5 Goals (Hits >90% of the time)
    // Estimate 5+ goals as 20% of the >3 bracket, 6+ goals as 5%
    _addIfSignificant(
        recs, "Over/Under", "Under 4.5 Goals", 1.0 - (threePlusProb * 0.2));
    _addIfSignificant(
        recs, "Over/Under", "Under 5.5 Goals", 1.0 - (threePlusProb * 0.05));

    // Standard Over/Under
    _addIfSignificant(
        recs, "Over/Under", "Over 1.5 Goals", twoThreeProb + threePlusProb);
    _addIfSignificant(
        recs, "Over/Under", "Under 3.5 Goals", zeroOneProb + twoThreeProb);
    _addIfSignificant(recs, "Over/Under", "Over 2.5 Goals",
        (twoThreeProb * 0.5) + threePlusProb);

    // 5. Draw No Bet (DNB)
    if (hProb + aProb > 0) {
      _addIfSignificant(
          recs, "Draw No Bet", "Home (DNB)", hProb / (hProb + aProb));
      _addIfSignificant(
          recs, "Draw No Bet", "Away (DNB)", aProb / (hProb + aProb));
    }

    // 6. Clean Sheet
    // If win prob is high and opponent prob is low
    _addIfSignificant(recs, "Clean Sheet", "$match.homeTeam Clean Sheet",
        hProb * (1 - bttsYes));
    _addIfSignificant(recs, "Clean Sheet", "$match.awayTeam Clean Sheet",
        aProb * (1 - bttsYes));

    // Sort by probability descending
    recs.sort((a, b) => b.probability.compareTo(a.probability));

    return recs;
  }

  void _addIfSignificant(
      List<BetRecommendation> list, String type, String pred, double prob) {
    if (prob <= 0) return;

    String confidence = "Low";
    if (prob >= 0.92)
      confidence = "Safe"; // Ultra high accuracy target
    else if (prob >= 0.82)
      confidence = "High";
    else if (prob >= 0.65) confidence = "Medium";

    list.add(BetRecommendation(
      type: type,
      prediction: pred,
      probability: prob,
      confidence: confidence,
    ));
  }

  double _parsePct(String? pct) {
    if (pct == null) return 0.0;
    return (double.tryParse(pct.replaceAll('%', '')) ?? 0) / 100;
  }

  /// Select the absolute "Best Bet" for a match
  BetRecommendation? getBestBet(List<BetRecommendation> recommendations) {
    if (recommendations.isEmpty) return null;

    // Favor "Safe" bets first, then highest probability
    final safeBets =
        recommendations.where((r) => r.confidence == "Safe").toList();
    if (safeBets.isNotEmpty) {
      return safeBets.first; // Already sorted by prob
    }

    return recommendations.first;
  }

  /// Static helper for compute() compatibility
  static List<MatchPrediction> calculateAll(List<MatchPrediction> matches) {
    final engine = PredictionEngine._internal();
    return matches.map((m) {
      // Very important optimization: don't recalculate if we already have them
      // This prevents UI lag when loading 1000s of historical matches
      if (m.recommendations.isNotEmpty) return m;
      return m.copyWith(recommendations: engine.calculateRecommendations(m));
    }).toList();
  }
}
