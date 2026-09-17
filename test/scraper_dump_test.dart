import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

// Standalone test script — mirrors PredicdScraperService logic
// Dumps raw JSON for verification of field mappings and decoding

const baseUrl = 'https://www.predicd.com';
const footballPath = '/en/football/';
const matchSchedulePath = '/en/football/match-schedule/';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept':
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    },
    followRedirects: true,
    responseType: ResponseType.plain,
  ));

  print('=' * 60);
  print('SCRAPER DATA DUMP TEST (With Decoder)');
  print('=' * 60);

  // ====== 1. TODAY MATCHES ======
  print('\n${"=" * 60}');
  print('1️⃣  TODAY MATCHES (from $baseUrl$footballPath)');
  print('=' * 60);
  try {
    final response = await dio.get(footballPath);
    final document = html_parser.parse(response.data as String);
    final todayMatches = parseMatchesFromDocument(document, DateTime.now());
    print('Found ${todayMatches.length} matches');
    final todayJson = JsonEncoder.withIndent('  ').convert(todayMatches);
    File('test/output_today_matches.json').writeAsStringSync(todayJson);
    print('✅ Saved to test/output_today_matches.json');

    if (todayMatches.isNotEmpty) {
      print('\nSample Prediction (Match 1): ${todayMatches[0]['prediction']}');
    }
  } catch (e) {
    print('❌ Error fetching today matches: $e');
  }

  // ====== 2. SCHEDULED MATCHES ======
  print('\n${"=" * 60}');
  print('2️⃣  SCHEDULED MATCHES (from $baseUrl$matchSchedulePath)');
  print('=' * 60);
  try {
    final response = await dio.get(matchSchedulePath);
    final document = html_parser.parse(response.data as String);
    final scheduledMatches = parseMatchesFromDocument(
        document, DateTime.now().add(Duration(days: 1)));
    print('Found ${scheduledMatches.length} scheduled matches');
    final schedJson = JsonEncoder.withIndent('  ').convert(scheduledMatches);
    File('test/output_scheduled_matches.json').writeAsStringSync(schedJson);
    print('✅ Saved to test/output_scheduled_matches.json');

    // Print sample of match with encoded data
    final SampleWithPred = scheduledMatches.firstWhere(
        (m) => m['prediction'] != null,
        orElse: () => scheduledMatches[0]);
    print('\nSample Prediction: ${SampleWithPred['prediction']}');
    print(
        'Sample xG Home: ${SampleWithPred['matchStats']['homeTeamExpectedGoals']}');
    print(
        'Sample xG Away: ${SampleWithPred['matchStats']['awayTeamExpectedGoals']}');
  } catch (e) {
    print('❌ Error fetching scheduled matches: $e');
  }

  // ====== 3. LEAGUE RESULTS (Previous Matches) ======
  print('\n${"=" * 60}');
  print('3️⃣  LEAGUE RESULTS (from $baseUrl${footballPath}league/4328/)');
  print('=' * 60);
  try {
    final response = await dio.get('${footballPath}league/4328/');
    final document = html_parser.parse(response.data as String);
    final results = parseMatchesFromDocument(document, DateTime.now());

    // Filter for matches with a score/result
    final finishedMatches = results.where((m) => m['result'] != null).toList();

    print('Found ${finishedMatches.length} completed matches');
    final resultsJson = JsonEncoder.withIndent('  ').convert(finishedMatches);
    File('test/output_league_results.json').writeAsStringSync(resultsJson);
    print('✅ Saved to test/output_league_results.json');

    if (finishedMatches.isNotEmpty) {
      print(
          '\nSample Result: ${finishedMatches[0]['homeTeam']} ${finishedMatches[0]['result']} ${finishedMatches[0]['awayTeam']}');
    }
  } catch (e) {
    print('❌ Error fetching league results: $e');
  }

  print('\n${"=" * 60}');
  print('DUMP COMPLETE');
  print('=' * 60);
}

// ========== PARSING LOGIC ==========

List<Map<String, dynamic>> parseMatchesFromDocument(
    Document document, DateTime targetDate) {
  final matches = <Map<String, dynamic>>[];

  // Updated tables selector
  final tables = document.querySelectorAll(
      'table.matches-table, .tab-content table, table.table-hover');

  for (final table in tables) {
    final rows = table.querySelectorAll('tr.tr-body, tr');
    final dataRows = rows
        .where((row) =>
            row.classes.contains('tr-body') ||
            row.querySelector('.accordion-toggle') != null ||
            row.querySelector('.hiddenRow') != null)
        .toList();

    for (int i = 0; i + 1 < dataRows.length; i += 2) {
      final mainRow = dataRows[i];
      final statsRow = dataRows[i + 1];

      final match = parseMatchPair(mainRow, statsRow, targetDate);
      if (match != null) {
        matches.add(match);
      }
    }
  }

  return matches;
}

Map<String, dynamic>? parseMatchPair(
    Element mainRow, Element statsRow, DateTime targetDate) {
  try {
    final id = mainRow.attributes['data-bs-target']?.replaceAll('#demo_', '') ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final timeEl = mainRow.querySelector('.matches-time-column span') ??
        mainRow.querySelector('.matches-time-column');
    final matchTime = timeEl?.text.trim() ?? '';

    final teamContainers = mainRow.querySelectorAll('#container');
    if (teamContainers.length < 2) return null;

    final homeName =
        teamContainers[0].querySelector('#teamname')?.text.trim() ?? '';
    final awayName =
        teamContainers[1].querySelector('#teamname')?.text.trim() ?? '';

    // Log logos for debugging if needed, but they are currently unused
    // final homeLogo = teamContainers[0].querySelector('img')?.attributes['src'];
    // final awayLogo = teamContainers[1].querySelector('img')?.attributes['src'];

    final statsDiv = statsRow.querySelector('.accordian-body');

    String competition = '';
    String round = '';
    String stadium = '';
    String? homeProb, drawProb, awayProb;
    String? hForm, aForm, hHomeForm, aAwayForm, hXG, aXG;
    final Map<String, String> goalProbabilities = {};

    if (statsDiv != null) {
      final infoTable = statsDiv.querySelector('.match-info-table');
      if (infoTable != null) {
        for (final row in infoTable.querySelectorAll('tr')) {
          final label = row.querySelector('td:first-child')?.text.trim() ?? '';
          final valueTd = row.querySelector('td:last-child');
          final value = valueTd?.text.trim() ?? '';

          if (label.contains('Competition:')) {
            competition = value.split('|')[0].trim();
          } else if (label.contains('Round:')) {
            round = value;
          } else if (label.contains('Stadium:')) {
            final firstSpan = valueTd?.querySelector('span');
            stadium = firstSpan?.text.trim() ?? value.split('\n').first.trim();
          }
        }
      }

      final winProbProgress =
          statsDiv.querySelector('.winProb-cell-content-container .progress');
      if (winProbProgress != null) {
        homeProb =
            winProbProgress.querySelector('.homeWin_Progressbar')?.text.trim();
        drawProb =
            winProbProgress.querySelector('.draw_Progressbar')?.text.trim();
        awayProb =
            winProbProgress.querySelector('.awayWin_Progressbar')?.text.trim();
      }

      // Goal Probabilities
      final goalProbContainers =
          statsDiv.querySelectorAll('.progress-bar-goalProb-container');
      for (final container in goalProbContainers) {
        final label =
            container.querySelector('.progress-goalProb-label')?.text.trim() ??
                '';
        final pctBar = container.querySelector('.progress-bar');
        final pct = pctBar?.text.trim() ?? '';
        if (label.isNotEmpty) {
          goalProbabilities[label] = pct;
        }
      }

      final teamCards = statsDiv.querySelectorAll('.matchStats .card');
      for (final card in teamCards) {
        final title = card.querySelector('.card-title')?.text.trim() ?? '';
        final isHome = card.querySelector('.underline-home') != null ||
            title.toLowerCase().contains(homeName.toLowerCase());

        String form = '';
        String haForm = '';
        String xg = '';

        for (final row in card.querySelectorAll('.match-info-table tr')) {
          final label = row.querySelector('td:first-child')?.text.trim() ?? '';
          final valueEl = row.querySelector('td:last-child');

          if (label.contains('Form:') &&
              !label.contains('Form - Home:') &&
              !label.contains('Form - Away:')) {
            form = valueEl
                    ?.querySelectorAll('.form-icon')
                    .map((e) => e.text.trim())
                    .join('') ??
                '';
          } else if (label.contains('Form - Home:') ||
              label.contains('Form - Away:')) {
            haForm = valueEl
                    ?.querySelectorAll('.form-icon')
                    .map((e) => e.text.trim())
                    .join('') ??
                '';
          } else if (label.contains('Expected Goals:')) {
            final metaSpans = row.querySelectorAll('.of-meta');
            if (metaSpans.isNotEmpty) {
              xg = metaSpans
                  .map((e) => _decodeMetaInfo(e.attributes['meta-info']))
                  .join(' ');
            } else {
              xg = valueEl?.text.trim() ?? '';
            }
          }
        }

        if (isHome) {
          hForm = form;
          hHomeForm = haForm;
          hXG = xg;
        } else {
          aForm = form;
          aAwayForm = haForm;
          aXG = xg;
        }
      }
    }

    // Prediction with decoding
    String? prediction;
    final predEl = mainRow.querySelector('#predResult_$id');
    if (predEl != null) {
      final metaSpans = predEl.querySelectorAll('.of-meta');
      if (metaSpans.isNotEmpty) {
        prediction = metaSpans
            .map((e) => _decodeMetaInfo(e.attributes['meta-info']))
            .join(' - ');
      } else {
        prediction = predEl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      }
    }

    if (prediction == null || prediction.isEmpty || prediction == '-') {
      final tds = mainRow.querySelectorAll('td');
      if (tds.length >= 3) {
        final predTds = tds[2].querySelectorAll('.of-meta');
        if (predTds.isNotEmpty) {
          prediction = predTds
              .map((e) => _decodeMetaInfo(e.attributes['meta-info']))
              .join(' - ');
        }
      }
    }

    if (prediction == '-') prediction = null;

    // Result with scores
    String? homeScore, awayScore;
    final resultEl = mainRow.querySelector('#matchResult-$id');
    if (resultEl != null) {
      homeScore =
          resultEl.querySelector('#matchResultHomeScore-$id')?.text.trim();
      awayScore =
          resultEl.querySelector('#matchResultAwayScore-$id')?.text.trim();
    }
    final String? liveResult = (homeScore != null && awayScore != null)
        ? '$homeScore - $awayScore'
        : null;

    final bool isLiveMatch =
        matchTime.contains("'") || matchTime.toUpperCase() == 'HT';

    final matchUrl = mainRow.querySelector('.last-td a')?.attributes['href'];

    return {
      'id': id,
      'matchTime': matchTime,
      'homeTeam': homeName,
      'awayTeam': awayName,
      'prediction': prediction,
      'result': liveResult,
      'isLiveMatch': isLiveMatch,
      'league': competition,
      'matchResult': {
        'homeTeamProb': homeProb,
        'drawProb': drawProb,
        'awayTeamProb': awayProb,
        'goalProbabilities': goalProbabilities,
      },
      'matchStats': {
        'competition': competition,
        'round': round,
        'stadium': stadium,
        'homeTeamForm': hForm,
        'awayTeamForm': aForm,
        'homeTeamHomeForm': hHomeForm,
        'awayTeamAwayForm': aAwayForm,
        'homeTeamExpectedGoals': hXG,
        'awayTeamExpectedGoals': aXG,
      },
    };
  } catch (e) {
    return null;
  }
}

String _decodeMetaInfo(String? metaInfo) {
  if (metaInfo == null || metaInfo.isEmpty) return '';
  try {
    final Uint8List bytes = base64.decode(metaInfo);
    if (bytes.length < 2 || bytes[0] != 0xFF || bytes[1] != 0xFE) return '';
    final buffer = StringBuffer();
    for (int i = 2; i + 1 < bytes.length; i += 2) {
      int codeUnit = bytes[i] | (bytes[i + 1] << 8);
      buffer.writeCharCode(codeUnit);
    }
    String decoded = buffer.toString().replaceAll(RegExp(r'\d{8}'), '');
    final result = StringBuffer();
    for (final char in decoded.runes) {
      if (char == 0xE001)
        result.write('.');
      else if (char >= 0xE006 && char <= 0xE00F)
        result.write((char - 0xE006).toString());
      else
        result.writeCharCode(char);
    }
    return result.toString().trim();
  } catch (e) {
    return '';
  }
}
