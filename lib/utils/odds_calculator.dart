class OddsCalculator {
  /// Calculates fair decimal odds from a probability (0.0 to 1.0)
  /// Formula: 1 / Probability
  static double calculateFairOdds(double probability) {
    if (probability <= 0) return 0.0;
    return 1 / probability;
  }

  /// Calculates bookmaker odds with a specific margin (vig/juice)
  /// Typical margins range from 2% to 10% (0.02 to 0.10)
  static double calculateBookmakerOdds(double probability,
      {double margin = 0.05}) {
    if (probability <= 0) return 0.0;
    // For bookmaker odds, we effectively 'inflate' the probabilities
    // so they sum to 1 + margin.
    // Adjusted Prob = Prob * (1 + margin)
    // Bookie Odds = 1 / Adjusted Prob
    return 1 / (probability * (1 + margin));
  }

  /// Formats odds to 2 decimal places
  static String format(double odds) {
    if (odds <= 0) return '-';
    return odds.toStringAsFixed(2);
  }

  /// Converts decimal odds to percentage probability
  static double oddsToProbability(double odds) {
    if (odds <= 1) return 0.0;
    return 1 / odds;
  }
}
