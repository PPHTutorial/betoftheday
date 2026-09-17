import 'package:btd/services/predicd_scraper_service.dart';

void main() async {
  print('--- Starting Scraper Verification ---');
  final scraper = PredicdScraperService();
  await scraper.initialize();

  try {
    print('Fetching today matches...');
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
  } catch (e) {
    print('ERROR during fetch: $e');
  }
  print('--- Verification Complete ---');
}
