import 'dart:io';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://www.predicd.com',
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    },
    responseType: ResponseType.plain,
  ));

  final response = await dio.get('/en/football/match-schedule/');

  // Save raw HTML
  File('test/raw_schedule.html').writeAsStringSync(response.data as String);
  print('Saved raw HTML to test/raw_schedule.html');

  final document = html_parser.parse(response.data as String);

  // Find first row with data-bs-target
  final allRows = document.querySelectorAll('tr[data-bs-target]');
  print('Rows with data-bs-target: ${allRows.length}');

  if (allRows.isNotEmpty) {
    final row = allRows.first;
    final bsTarget = row.attributes['data-bs-target'] ?? '';
    final matchId = bsTarget.replaceAll('#demo_', '');
    print('\nFirst match ID: $matchId');
    print('Row classes: ${row.classes}');

    // Print all TDs
    final tds = row.querySelectorAll('td');
    print('TDs count: ${tds.length}');
    for (int i = 0; i < tds.length; i++) {
      final td = tds[i];
      final text = td.text.trim().replaceAll(RegExp(r'\s+'), ' ');
      final truncated = text.length > 100 ? text.substring(0, 100) : text;
      print(
          '  TD[$i] class="${td.classes.join(',')}" id="${td.attributes['id'] ?? ''}" text="$truncated"');
    }

    // Search for prediction column
    print('\n--- Prediction elements ---');
    final predById = document.querySelector('#prediction_col_$matchId');
    print(
        '  #prediction_col_$matchId: ${predById != null ? predById.outerHtml.substring(0, predById.outerHtml.length > 300 ? 300 : predById.outerHtml.length) : "NOT FOUND"}');

    // Search broadly for prediction
    final allPredEls = document.querySelectorAll('[id*="prediction"]');
    print('  Elements with id containing "prediction": ${allPredEls.length}');
    for (final e in allPredEls.take(3)) {
      final html = e.outerHtml;
      print(
          '    id="${e.attributes['id']}" html=${html.substring(0, html.length > 300 ? 300 : html.length)}');
    }

    // Look for the stats panel
    print('\n--- Stats panel #demo_$matchId ---');
    final panel = document.querySelector('#demo_$matchId');
    if (panel != null) {
      // xG from .half-width-matchInfoTeam-col2
      final xgCols = panel.querySelectorAll('.half-width-matchInfoTeam-col2');
      print('  .half-width-matchInfoTeam-col2 count: ${xgCols.length}');
      for (int i = 0; i < xgCols.length; i++) {
        final html = xgCols[i].outerHtml;
        print(
            '  xgCol[$i]: ${html.substring(0, html.length > 500 ? 500 : html.length)}');
      }

      // Stadium
      final infoRows = panel.querySelectorAll('.match-info-table tr');
      for (final tr in infoRows) {
        final label = tr.querySelector('td:first-child')?.text.trim() ?? '';
        if (label.contains('Stadium')) {
          final valueTd = tr.querySelector('td:last-child');
          print('\n  Stadium TD children: ${valueTd?.children.length}');
          for (final c in valueTd?.children ?? []) {
            print(
                '    tag=${c.localName} class="${c.classes.join(',')}" text="${c.text.trim().substring(0, c.text.trim().length > 80 ? 80 : c.text.trim().length)}"');
          }
        }
      }

      // Goal prob labels
      final gpLabels = panel.querySelectorAll('.progress-goalProb-label');
      print('\n  Goal prob labels (${gpLabels.length}):');
      for (final l in gpLabels) {
        print('    text="${l.text.trim()}"');
      }

      // Goal prob bars
      final gpBars = panel.querySelectorAll('[class*="goalProb"]');
      print('  GoalProb elements (${gpBars.length}):');
      for (final b in gpBars.take(10)) {
        print(
            '    class="${b.classes.join(',')}" text="${b.text.trim()}" style="${b.attributes['style'] ?? ''}"');
      }
    } else {
      print('  NOT FOUND');
    }

    // Score in main row - look for result/score
    print('\n--- Score/Result in main row ---');
    final scoreEls = row.querySelectorAll(
        '[class*="score"], [id*="score"], [class*="result"], [id*="result"]');
    print('  Score/result elements: ${scoreEls.length}');
    for (final e in scoreEls) {
      print(
          '    class="${e.classes.join(',')}" id="${e.attributes['id'] ?? ''}" text="${e.text.trim()}"');
    }

    // Also check the next row for result
    final nextRows = document.querySelectorAll(
        '#demo_$matchId [class*="result"], #demo_$matchId [id*="result"]');
    print('  In stats panel - result elements: ${nextRows.length}');
    for (final e in nextRows.take(5)) {
      print('    class="${e.classes.join(',')}" text="${e.text.trim()}"');
    }
  }
}
