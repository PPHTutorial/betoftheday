import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

/// Script to download football team logos and league logos from 1000logos.net
/// Usage: dart scripts/download_logos.dart
///
/// First install dependencies:
/// Add to pubspec.yaml dev_dependencies:
///   html: ^0.15.4
/// Then run: flutter pub get

Future<void> main() async {
  print('Starting logo download...');

  final baseUrl = 'https://1000logos.net';

  // Team logos pages
  final teamPages = [
    '$baseUrl/soccer/',
    '$baseUrl/soccer/page/2/',
  ];

  // League logos pages
  final leaguePages = [
    '$baseUrl/sports-leagues/',
    '$baseUrl/sports-leagues/page/2/',
  ];

  // Create directories
  final teamsDir = Directory('assets/teams');
  final leaguesDir = Directory('assets/leagues');

  if (!await teamsDir.exists()) {
    await teamsDir.create(recursive: true);
    print('Created directory: assets/teams');
  }

  if (!await leaguesDir.exists()) {
    await leaguesDir.create(recursive: true);
    print('Created directory: assets/leagues');
  }

  // Download Team Logos
  print('\n${'=' * 60}');
  print('DOWNLOADING TEAM LOGOS');
  print('${'=' * 60}');

  final allTeamLogos = <String, String>{};

  for (final pageUrl in teamPages) {
    print('\nFetching team logos from: $pageUrl');
    final logos = await _getLogoUrlsFromPage(pageUrl, baseUrl);
    allTeamLogos.addAll(logos);
    print('Found ${logos.length} team logos on this page');
  }

  print('\nTotal team logos to download: ${allTeamLogos.length}');
  print('Starting downloads...\n');

  var teamSuccess = 0;
  var teamFail = 0;

  for (final entry in allTeamLogos.entries) {
    final teamName = entry.key;
    final logoUrl = entry.value;

    final extension = _getExtension(logoUrl);
    final file = File('assets/teams/$teamName.$extension');

    print('Downloading team: $teamName...');
    if (await _downloadLogo(logoUrl, file)) {
      print('  ✓ Saved: $teamName.$extension');
      teamSuccess++;
    } else {
      print('  ✗ Failed: $teamName');
      teamFail++;
    }

    await Future.delayed(Duration(milliseconds: 300));
  }

  print('\nTeam Logos - Success: $teamSuccess, Failed: $teamFail');

  // Download League Logos
  print('\n${'=' * 60}');
  print('DOWNLOADING LEAGUE LOGOS');
  print('${'=' * 60}');

  final allLeagueLogos = <String, String>{};

  for (final pageUrl in leaguePages) {
    print('\nFetching league logos from: $pageUrl');
    final logos = await _getLogoUrlsFromPage(pageUrl, baseUrl);
    allLeagueLogos.addAll(logos);
    print('Found ${logos.length} league logos on this page');
  }

  print('\nTotal league logos to download: ${allLeagueLogos.length}');
  print('Starting downloads...\n');

  var leagueSuccess = 0;
  var leagueFail = 0;

  for (final entry in allLeagueLogos.entries) {
    final leagueName = entry.key;
    final logoUrl = entry.value;

    final extension = _getExtension(logoUrl);
    final file = File('assets/leagues/$leagueName.$extension');

    print('Downloading league: $leagueName...');
    if (await _downloadLogo(logoUrl, file)) {
      print('  ✓ Saved: $leagueName.$extension');
      leagueSuccess++;
    } else {
      print('  ✗ Failed: $leagueName');
      leagueFail++;
    }

    await Future.delayed(Duration(milliseconds: 300));
  }

  print('\nLeague Logos - Success: $leagueSuccess, Failed: $leagueFail');

  // Summary
  print('\n${'=' * 60}');
  print('DOWNLOAD SUMMARY');
  print('${'=' * 60}');
  print(
      'Team Logos:  $teamSuccess success, $teamFail failed, ${allTeamLogos.length} total');
  print(
      'League Logos: $leagueSuccess success, $leagueFail failed, ${allLeagueLogos.length} total');
  print(
      'Grand Total: ${teamSuccess + leagueSuccess} success, ${teamFail + leagueFail} failed');
  print('Total Files: ${allTeamLogos.length + allLeagueLogos.length}');
  print('${'=' * 60}');
}

Future<Map<String, String>> _getLogoUrlsFromPage(
    String pageUrl, String baseUrl) async {
  final logoUrls = <String, String>{};

  try {
    final response = await http.get(Uri.parse(pageUrl));
    if (response.statusCode == 200) {
      final document = html_parser.parse(response.body);
      final links = document.querySelectorAll('a[href*="/logo"]');

      for (final link in links) {
        final logoPageUrl = link.attributes['href'];
        if (logoPageUrl != null && logoPageUrl.startsWith('/')) {
          final fullUrl = '$baseUrl$logoPageUrl';

          try {
            final teamPage = await http.get(Uri.parse(fullUrl));
            if (teamPage.statusCode == 200) {
              final teamDoc = html_parser.parse(teamPage.body);

              // Extract name
              String name = logoPageUrl
                  .replaceAll('/logo/', '')
                  .replaceAll('-logo/', '')
                  .replaceAll('/', '')
                  .replaceAll('-', '_');

              final title = teamDoc.querySelector('h1');
              if (title != null) {
                name = title.text
                    .toLowerCase()
                    .replaceAll(' logo', '')
                    .replaceAll(' ', '_')
                    .replaceAll(RegExp(r'[^a-z0-9_]'), '');
              }

              // Find logo image
              final img = teamDoc.querySelector('img[src*="logo"]') ??
                  teamDoc.querySelector('img[src*=".png"]') ??
                  teamDoc.querySelector('img[src*=".svg"]') ??
                  teamDoc.querySelector('img[src*=".jpg"]');

              if (img != null) {
                var logoUrl =
                    img.attributes['src'] ?? img.attributes['data-src'];
                if (logoUrl != null) {
                  if (logoUrl.startsWith('/')) {
                    logoUrl = '$baseUrl$logoUrl';
                  } else if (!logoUrl.startsWith('http')) {
                    logoUrl = '$baseUrl/$logoUrl';
                  }
                  logoUrls[name] = logoUrl;
                }
              }
            }

            await Future.delayed(Duration(milliseconds: 500));
          } catch (e) {
            print('  Error processing $fullUrl: $e');
          }
        }
      }
    }
  } catch (e) {
    print('Error fetching $pageUrl: $e');
  }

  return logoUrls;
}

Future<bool> _downloadLogo(String logoUrl, File file) async {
  try {
    final response = await http.get(Uri.parse(logoUrl));
    if (response.statusCode == 200) {
      await file.writeAsBytes(response.bodyBytes);
      return true;
    }
  } catch (e) {
    print('  Error: $e');
  }
  return false;
}

String _getExtension(String url) {
  final lowerUrl = url.toLowerCase();
  if (lowerUrl.contains('.svg')) return 'svg';
  if (lowerUrl.contains('.jpg') || lowerUrl.contains('.jpeg')) return 'jpg';
  if (lowerUrl.contains('.webp')) return 'webp';
  return 'png';
}
