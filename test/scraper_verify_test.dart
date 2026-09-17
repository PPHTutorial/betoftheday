import 'package:flutter_test/flutter_test.dart';
import 'package:btd/services/predicd_scraper_service.dart';
import 'package:btd/config/app_config.dart';

void main() {
  test('Scraper can fetch today matches', () async {
    print('--- Starting Scraper Verification ---');
    final scraper = PredicdScraperService();
    await scraper.initialize();

    try {
      print(
          'Fetching today matches from: ${AppConfig.baseUrl}${AppConfig.footballPath}');
      final matches = await scraper.fetchTodayMatches();
      print('Fetched ${matches.length} matches.');

      if (matches.isNotEmpty) {
        for (var i = 0; i < (matches.length > 5 ? 5 : matches.length); i++) {
          final m = matches[i];
          print(
              'Match ${i + 1}: ${m.homeTeam} vs ${m.awayTeam} | Time: ${m.matchTime} | Pred: ${m.prediction}');
        }
      } else {
        print('WARNING: No matches fetched!');
      }

      expect(matches, isNotEmpty, reason: 'Matches list should not be empty');
    } catch (e) {
      print('ERROR during fetch: $e');
      fail('Fetch failed with error: $e');
    }
    print('--- Verification Complete ---');
  });
}
