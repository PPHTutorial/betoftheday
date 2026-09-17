import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import '../models/prediction_model.dart';
import '../models/league_model.dart';
import '../config/app_config.dart';

class PredicdScraperService {
  static final PredicdScraperService _instance =
      PredicdScraperService._internal();
  factory PredicdScraperService() => _instance;
  PredicdScraperService._internal();

  late Dio _dio;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
        },
        followRedirects: true,
        responseType: ResponseType.plain,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('Scraper: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('Scraper Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );

    _initialized = true;
  }

  // ========== PUBLIC API ==========

  /// Fetch today's matches from the homepage (live + upcoming)
  Future<List<MatchPrediction>> fetchTodayMatches() async {
    try {
      await _ensureInitialized();
      final response = await _dio.get(AppConfig.footballPath);
      final document = html_parser.parse(response.data as String);
      return _parseMatchesFromDocument(document, DateTime.now());
    } catch (e) {
      debugPrint('Error fetching today matches: $e');
      rethrow;
    }
  }

  /// Fetch match schedule for a specific date offset
  Future<List<MatchPrediction>> fetchMatchSchedule({int dayOffset = 0}) async {
    try {
      await _ensureInitialized();
      final response = await _dio.get(AppConfig.matchSchedulePath);
      final document = html_parser.parse(response.data as String);

      final targetDate = DateTime.now().add(Duration(days: dayOffset));
      return _parseMatchesFromDocument(document, targetDate);
    } catch (e) {
      debugPrint('Error fetching match schedule: $e');
      rethrow;
    }
  }

  /// Fetch all relevant data for a specific league (current matches + carousel history)
  /// This optimizes performance by hitting the league page once.
  Future<List<MatchPrediction>> fetchLeagueData(String leagueId) async {
    try {
      await _ensureInitialized();
      final response = await _dio.get('${AppConfig.leaguePath}$leagueId/');
      final document = html_parser.parse(response.data as String);

      // 1. Current matches (today/upcoming)
      final currentMatches =
          _parseMatchesFromDocument(document, DateTime.now());

      // 2. Historical matches from carousel
      final historicalMatches = _parseCarouselFromDocument(document, leagueId);

      // Merge results, avoiding duplicates by ID
      final Map<String, MatchPrediction> allMatches = {
        for (var m in historicalMatches) m.id: m,
      };

      for (final m in currentMatches) {
        // Current data usually has more fresh info for today's matches
        allMatches[m.id] = m;
      }

      return allMatches.values.toList();
    } catch (e) {
      debugPrint('Error fetching league $leagueId data: $e');
      rethrow;
    }
  }

  /// Fetch matches for a specific league
  Future<List<MatchPrediction>> fetchLeagueMatches(String leagueId) async {
    try {
      await _ensureInitialized();
      final response = await _dio.get('${AppConfig.leaguePath}$leagueId/');
      final document = html_parser.parse(response.data as String);
      return _parseMatchesFromDocument(document, DateTime.now());
    } catch (e) {
      debugPrint('Error fetching league $leagueId matches: $e');
      rethrow;
    }
  }

  /// Extract available leagues from the sidebar "LEAGUES" section
  Future<List<League>> fetchAvailableLeagues() async {
    try {
      await _ensureInitialized();
      // Leagues are present on almost every page in the sidebar
      final response = await _dio.get(AppConfig.footballPath);
      final document = html_parser.parse(response.data as String);
      return _parseLeaguesFromSidebar(document);
    } catch (e) {
      debugPrint('Error fetching leagues: $e');
      rethrow;
    }
  }

  /// Fetch deep historical results for a specific league using the carousel
  Future<List<MatchPrediction>> fetchLeagueResults(String leagueId) async {
    try {
      await _ensureInitialized();
      final response = await _dio.get('${AppConfig.leaguePath}$leagueId/');
      final document = html_parser.parse(response.data as String);

      // The carousel contains past, present, and future matchdays
      final matches = _parseCarouselFromDocument(document, leagueId);

      final now = DateTime.now();
      final todayStr = now.toIso8601String().substring(0, 10);

      return matches.where((m) {
        final dateStr = m.matchStats?.matchDate ?? '';
        // If it has a result, it's a historical match.
        // We only exclude it if it's explicitly today's match to avoid duplicates in some views.
        return m.hasResult && (dateStr.isEmpty || dateStr != todayStr);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching league $leagueId historical results: $e');
      rethrow;
    }
  }

  // ========== HTML PARSING ==========

  List<MatchPrediction> _parseMatchesFromDocument(
      Document document, DateTime targetDate) {
    final matches = <MatchPrediction>[];

    // The user provided selector: .tab-content > div > div > div > div > table
    // Predicd usually has matches in tables where every two rows is a match.
    // Select all potential tables containing matches
    final tables = document.querySelectorAll(
        'table.matches-table, .tab-content table, table.table-hover');

    for (final table in tables) {
      final rows = table.querySelectorAll('tr.tr-body, tr');
      // Filter out rows that are just headers or separators
      final dataRows = rows
          .where((row) =>
              row.classes.contains('tr-body') ||
              row.querySelector('.accordion-toggle') != null ||
              row.querySelector('.hiddenRow') != null)
          .toList();

      for (int i = 0; i + 1 < dataRows.length; i += 2) {
        final mainRow = dataRows[i];
        final statsRow = dataRows[i + 1];

        final isStatsHidden = statsRow.querySelector('.hiddenRow') != null ||
            statsRow.classes.contains('hiddenRow');

        if (mainRow.classes.contains('hiddenRow') || !isStatsHidden) {
          // Skip if mainRow is actually a stats row or statsRow doesn't have the expected wrapper
          continue;
        }

        final match = _parseMatchPair(mainRow, statsRow, targetDate);
        if (match != null) {
          matches.add(match);
        }
      }
    }

    if (matches.isEmpty) {
      // Fallback to simpler parsing if table structure isn't found
      matches.addAll(_parseMatchesFromGenericStructure(document, targetDate));
    }

    debugPrint('Parsed ${matches.length} matches from HTML');
    return matches;
  }

  MatchPrediction? _parseMatchPair(
      Element mainRow, Element statsRow, DateTime targetDate) {
    try {
      // 1. Extract Info from mainRow
      final id =
          mainRow.attributes['data-bs-target']?.replaceAll('#demo_', '') ??
              DateTime.now().millisecondsSinceEpoch.toString();

      final timeEl = mainRow.querySelector('.matches-time-column span');
      final matchTime = timeEl?.text.trim() ?? '';

      final teamContainers = mainRow.querySelectorAll('#container');
      if (teamContainers.length < 2) return null;

      final homeName =
          teamContainers[0].querySelector('#teamname')?.text.trim() ?? '';
      final awayName =
          teamContainers[1].querySelector('#teamname')?.text.trim() ?? '';

      final homeLogo =
          teamContainers[0].querySelector('img')?.attributes['src'];
      final awayLogo =
          teamContainers[1].querySelector('img')?.attributes['src'];

      // 2. Extract Stats from statsRow
      final statsDiv = statsRow.querySelector('.accordian-body');
      if (statsDiv == null) return null;

      // Match Info Table (first .match-info-table is the general match info)
      final infoTable = statsDiv.querySelector('.match-info-table');
      String competition = '';
      String round = '';
      String stadium = '';

      if (infoTable != null) {
        final infoRows = infoTable.querySelectorAll('tr');
        for (final row in infoRows) {
          final label = row.querySelector('td:first-child')?.text.trim() ?? '';
          final valueTd = row.querySelector('td:last-child');
          final value = valueTd?.text.trim() ?? '';

          if (label.contains('Competition:')) {
            competition = _normalizeLeagueName(value.split('|')[0].trim());
          } else if (label.contains('Round:')) {
            round = value;
          } else if (label.contains('Stadium:')) {
            // Stadium TD has two <span> children (truncated + full).
            // Use the first span's text to avoid duplication.
            final firstSpan = valueTd?.querySelector('span');
            stadium = firstSpan?.text.trim() ?? value.split('\n').first.trim();
          }
        }
      }

      // Win Probabilities
      String? homeProb, drawProb, awayProb;
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

      // Goal Probabilities — structured as {label: percentage}
      // e.g. {"0-1": "30%", "2-3": "48%", ">3": "22%"}
      final goalProbContainers =
          statsDiv.querySelectorAll('.progress-bar-goalProb-container');
      final Map<String, String> goalProbabilities = {};
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

      // Prediction: actual predicted score from #predResult_{id}
      String? prediction;
      final predEl = mainRow.querySelector('#predResult_$id');
      if (predEl != null) {
        final metaSpans = predEl.querySelectorAll('.of-meta');
        if (metaSpans.isNotEmpty) {
          // Join multiple spans (e.g., home score - away score)
          prediction = metaSpans
              .map((e) => _decodeMetaInfo(e.attributes['meta-info']))
              .join(' - ');
        } else {
          prediction = predEl.text.trim().replaceAll(RegExp(r'\s+'), ' ');
        }
        if (prediction.trim() == '-') prediction = null;
        if (prediction == null || prediction.isEmpty) {
          // Fallback: Check for any .of-meta spans in the main row
          final allMetaInRow = mainRow.querySelectorAll('.of-meta');
          if (allMetaInRow.isNotEmpty) {
            // This might be risky if there are other of-meta spans,
            // but usually in the main row it's just the prediction.
            // On homepage, they are in the 3rd TD.
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
        }
        if (prediction != null && prediction.trim() == '-') prediction = null;
        if (prediction == null || prediction.isEmpty) prediction = null;
      }

      // Result: actual match outcome from #matchResult-{id}
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

      // Team Details (Form, Expected Goals)
      String? hForm, aForm, hHomeForm, aAwayForm, hXG, aXG;
      final teamCards = statsDiv.querySelectorAll('.matchStats .card');

      for (final card in teamCards) {
        final title = card.querySelector('.card-title')?.text.trim() ?? '';
        final isHome = card.querySelector('.underline-home') != null ||
            title.contains(homeName);

        final infoRows = card.querySelectorAll('.match-info-table tr');
        String form = '';
        String haForm = '';
        String xg = '';

        for (final row in infoRows) {
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
            // xG is in .half-width-matchInfoTeam-col2, uses obfuscated 'of-meta' spans
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

      final matchUrl = mainRow.querySelector('.last-td a')?.attributes['href'];

      final mResult = MatchResult(
        homeTeamProb: homeProb,
        drawProb: drawProb,
        awayTeamProb: awayProb,
        goalProbabilities:
            goalProbabilities.isNotEmpty ? goalProbabilities : null,
      );

      final mStats = MatchStats(
        competition: competition,
        round: round,
        matchDate: _extractDateStringFromTime(matchTime, targetDate),
        matchTime: matchTime,
        stadium: stadium,
        homeTeamForm: hForm,
        awayTeamForm: aForm,
        homeTeamHomeForm: hHomeForm,
        awayTeamAwayForm: aAwayForm,
        homeTeamExpectedGoals: hXG,
        awayTeamExpectedGoals: aXG,
      );

      final bool isLiveMatch =
          matchTime.contains("'") || matchTime.toUpperCase() == 'HT';

      return MatchPrediction(
        id: id,
        matchTime: matchTime,
        homeTeam: homeName,
        awayTeam: awayName,
        homeTeamLogo: homeLogo != null && homeLogo.startsWith('http')
            ? homeLogo
            : '${AppConfig.baseUrl}$homeLogo',
        awayTeamLogo: awayLogo != null && awayLogo.startsWith('http')
            ? awayLogo
            : '${AppConfig.baseUrl}$awayLogo',
        matchUrl: matchUrl != null ? '${AppConfig.baseUrl}$matchUrl' : '',
        prediction: prediction,
        liveResult: liveResult,
        isLiveMatch: isLiveMatch,
        matchResult: mResult,
        matchStats: mStats,
        league: competition,
        season: DateTime.now().year.toString(),
      );
    } catch (e) {
      debugPrint('Error parsing match pair: $e');
      return null;
    }
  }

  /// New method to parse leagues from the sidebar structure
  List<League> _parseLeaguesFromSidebar(Document document) {
    final leagues = <League>[];
    final seenIds = <String>{};

    // Find the sidebar section for LEAGUES
    // Structure: div.sidebar contains sections; one has h5 with "LEAGUES"
    final sidebar = document.querySelector('.sidebar');
    if (sidebar == null) return _parseLeaguesFromNav(document); // Fallback

    final leagueLinks =
        sidebar.querySelectorAll('a[href*="/en/football/league/"]');

    for (final link in leagueLinks) {
      final href = link.attributes['href'] ?? '';
      final idMatch = RegExp(r'/league/(\d+)/').firstMatch(href);
      if (idMatch == null) continue;

      final leagueId = idMatch.group(1)!;
      if (seenIds.contains(leagueId)) continue;
      seenIds.add(leagueId);

      final name = _normalizeLeagueName(link.text.trim());
      if (name.isEmpty) continue;

      leagues.add(League(
        id: leagueId,
        name: name,
        country: 'Global',
        url: href.startsWith('http') ? href : '${AppConfig.baseUrl}$href',
        leagueLogo: '',
        leagueCountry: 'Global',
        leagueCountryFlag: '',
      ));
    }

    if (leagues.isEmpty) return _parseLeaguesFromNav(document);
    return leagues;
  }

  /// Original navigation parser (kept as fallback)
  List<League> _parseLeaguesFromNav(Document document) {
    final leagues = <League>[];
    final seenIds = <String>{};

    final leagueLinks =
        document.querySelectorAll('a[href*="/football/league/"]');

    for (final link in leagueLinks) {
      final href = link.attributes['href'] ?? '';
      final idMatch = RegExp(r'/league/(\d+)/').firstMatch(href);
      if (idMatch == null) continue;

      final leagueId = idMatch.group(1)!;
      if (seenIds.contains(leagueId)) continue;
      seenIds.add(leagueId);

      final name = _normalizeLeagueName(link.text.trim());
      leagues.add(League(
        id: leagueId,
        name: name,
        country: 'Global',
        url: href,
        leagueLogo: '',
        leagueCountry: 'Global',
        leagueCountryFlag: '',
      ));
    }
    return leagues;
  }

  /// Parse matches from the carousel structure on league pages
  List<MatchPrediction> _parseCarouselFromDocument(
      Document document, String leagueId) {
    final matches = <MatchPrediction>[];

    // Use #matchDayCarouselItem as the main bucket; it's unique per round per Predicd structure
    final carouselItems = document.querySelectorAll('#matchDayCarouselItem');

    for (final item in carouselItems) {
      // Each item usually has a section.box.features with matchday attribute
      final section = item.querySelector('section.box.features');
      final matchday = section?.attributes['matchday'] ?? '';

      final tables = item.querySelectorAll('table.matches-table');
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

          final isStatsHidden = statsRow.querySelector('.hiddenRow') != null ||
              statsRow.classes.contains('hiddenRow');

          if (mainRow.classes.contains('hiddenRow') || !isStatsHidden) continue;

          // For historical carousel, we don't have a specific target date per row in the same way,
          // but we can try to extract it from the matchTime-MATCHID span if it contains a date.
          // Or use the matchday to infer relative date if possible, but predicd usually has date in stats.
          final match = _parseMatchPair(mainRow, statsRow, DateTime.now());
          if (match != null) {
            // Update league info to ensure consistency
            matches.add(MatchPrediction(
              id: match.id,
              matchTime: match.matchTime,
              homeTeam: match.homeTeam,
              awayTeam: match.awayTeam,
              homeTeamLogo: match.homeTeamLogo,
              awayTeamLogo: match.awayTeamLogo,
              matchUrl: match.matchUrl,
              prediction: match.prediction,
              liveResult: match.liveResult,
              isLiveMatch: match.isLiveMatch,
              matchResult: match.matchResult,
              matchStats: MatchStats(
                competition: match.matchStats?.competition ?? '',
                round: matchday.isNotEmpty
                    ? 'Matchday $matchday'
                    : (match.matchStats?.round ?? ''),
                matchDate: match.matchStats?.matchDate ?? '',
                matchTime: match.matchStats?.matchTime ?? '',
                stadium: match.matchStats?.stadium,
                homeTeamForm: match.matchStats?.homeTeamForm,
                awayTeamForm: match.matchStats?.awayTeamForm,
                homeTeamHomeForm: match.matchStats?.homeTeamHomeForm,
                awayTeamAwayForm: match.matchStats?.awayTeamAwayForm,
                homeTeamExpectedGoals: match.matchStats?.homeTeamExpectedGoals,
                awayTeamExpectedGoals: match.matchStats?.awayTeamExpectedGoals,
              ),
              league: match.league,
              leagueId: leagueId,
              season: match.season,
            ));
          }
        }
      }
    }

    return matches;
  }

  /// Fallback parsing for generic predicd HTML structure
  List<MatchPrediction> _parseMatchesFromGenericStructure(
      Document document, DateTime targetDate) {
    final matches = <MatchPrediction>[];

    // Predicd wraps matches in containers; look for all links to league pages
    // and paired h5 elements for team names
    String currentLeague = '';
    String currentLeagueId = '';
    String currentSeason = '';

    // Get all elements in order
    final body = document.body;
    if (body == null) return matches;

    // Strategy: find all anchor elements linking to /league/ and extract context
    final leagueLinks =
        document.querySelectorAll('a[href*="/football/league/"]');
    final seenLeagueIds = <String>{};

    for (final link in leagueLinks) {
      final href = link.attributes['href'] ?? '';
      final idMatch = RegExp(r'/league/(\d+)/').firstMatch(href);
      if (idMatch != null) {
        currentLeagueId = idMatch.group(1)!;
      }

      final linkText = link.text.trim();
      // Extract league name and season
      if (linkText.contains('|')) {
        final parts = linkText.split('|');
        currentLeague = _normalizeLeagueName(parts[0].trim());
        currentSeason = parts.length > 1 ? parts[1].trim() : '';
      } else {
        final seasonMatch = RegExp(r'(\d{4}(?:-\d{4})?)').firstMatch(linkText);
        if (seasonMatch != null) {
          currentSeason = seasonMatch.group(1)!;
          currentLeague = _normalizeLeagueName(
              linkText.replaceAll(currentSeason, '').trim());
        } else {
          currentLeague = _normalizeLeagueName(linkText);
        }
      }

      if (currentLeague.isEmpty) continue;

      // Find the parent container and extract team names from h5 siblings
      final parent = link.parent?.parent?.parent;
      if (parent == null) continue;

      // Avoid re-processing the same block
      final blockKey = '${currentLeagueId}_${parent.hashCode}';
      if (seenLeagueIds.contains(blockKey)) continue;
      seenLeagueIds.add(blockKey);

      final h5s = parent.querySelectorAll('h5');
      final teamNames = h5s
          .map((el) => el.text.trim())
          .where((text) => text.isNotEmpty && !text.contains('Match Info'))
          .toList();

      // Process pairs of team names
      for (int i = 0; i + 1 < teamNames.length; i += 2) {
        final homeTeam = _extractTeamName(teamNames[i]);
        final awayTeam = _extractTeamName(teamNames[i + 1]);

        if (homeTeam.isEmpty || awayTeam.isEmpty) continue;

        final cleanLeague = currentLeague.replaceAll(RegExp(r'[^\w]'), '');
        final id =
            '${cleanLeague}_${homeTeam.replaceAll(' ', '_')}_${awayTeam.replaceAll(' ', '_')}_${targetDate.toIso8601String().substring(0, 10)}';

        matches.add(MatchPrediction(
          id: id,
          matchTime: '00:00', // Unknown for generic
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          matchUrl: '${AppConfig.baseUrl}${AppConfig.footballPath}',
          league: currentLeague,
          leagueId: currentLeagueId,
          season: currentSeason,
        ));
      }
    }

    return matches;
  }

  // ========== HELPERS ==========

  String _extractTeamName(String raw) {
    // Remove position like "(1.)" or "(12.)"
    return raw.replaceAll(RegExp(r'\s*\(\d+\.\)\s*$'), '').trim();
  }

  String _normalizeLeagueName(String raw) {
    final clean = raw.trim();
    return AppConfig.leagueNameMapping[clean] ?? clean;
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Decodes obfuscated 'meta-info' data used for scores and stats
  String _decodeMetaInfo(String? metaInfo) {
    if (metaInfo == null || metaInfo.isEmpty) return '';

    try {
      // 1. Base64 Decode
      final Uint8List bytes = base64.decode(metaInfo);

      // 2. Check for UTF-16LE BOM (FF FE)
      if (bytes.length < 2 || bytes[0] != 0xFF || bytes[1] != 0xFE) {
        return '';
      }

      // 3. Convert bytes to UTF-16 code units (skip BOM)
      final buffer = StringBuffer();
      for (int i = 2; i + 1 < bytes.length; i += 2) {
        if (i + 1 < bytes.length) {
          int codeUnit = bytes[i] | (bytes[i + 1] << 8);
          buffer.writeCharCode(codeUnit);
        }
      }

      String decoded = buffer.toString();

      // 4. Remove the 8-digit date salt (e.g., 20240219)
      decoded = decoded.replaceAll(RegExp(r'\d{8}'), '');

      // 5. Map PUA characters to actual digits/symbols
      // Based on analysis:
      // \uE001 -> .
      // \uE006 -> 0
      // \uE007 -> 1
      // ...
      // \uE00F -> 9
      final result = StringBuffer();
      for (final char in decoded.runes) {
        if (char == 0xE001) {
          result.write('.');
        } else if (char >= 0xE006 && char <= 0xE00F) {
          result.write((char - 0xE006).toString());
        } else {
          result.writeCharCode(char);
        }
      }

      return result.toString().trim();
    } catch (e) {
      debugPrint('Error decoding meta-info: $e');
      return '';
    }
  }

  /// Extracts a YYYY-MM-DD date string from matchTime (e.g. "15.08. 19:00")
  String _extractDateStringFromTime(String matchTime, DateTime fallbackDate) {
    // Look for DD.MM.
    final dateMatch = RegExp(r'(\d{2})\.(\d{2})\.').firstMatch(matchTime);
    if (dateMatch != null) {
      final day = dateMatch.group(1)!;
      final month = dateMatch.group(2)!;

      final now = DateTime.now();
      int year = now.year;

      // Heuristic: If we are in January/February and the match month is December,
      // it's likely from the previous year.
      if (now.month <= 2 && int.parse(month) >= 11) {
        year--;
      }

      return '$year-$month-$day';
    }
    return fallbackDate.toIso8601String().substring(0, 10);
  }
}
