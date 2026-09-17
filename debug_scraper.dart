import 'package:dio/dio.dart';
import 'package:html/parser.dart';

void main() async {
  final dio = Dio();
  dio.options.headers = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
  };

  try {
    print('Fetching https://www.predicd.com/en/football/');
    final response = await dio.get('https://www.predicd.com/en/football/');
    print('Status: ${response.statusCode}');

    final document = parse(response.data);

    // Check for matchStats
    final matches = document.querySelectorAll('.matchStats');
    if (matches.isNotEmpty) {
      print('Found ${matches.length} matches (selector: .matchStats)');
      final firstMatch = matches.first;

      // Clean up and print inner HTML
      print('First Match Inner HTML:');
      print(firstMatch.innerHtml.replaceAll(RegExp(r'\n\s*\n'), '\n'));

      // Check for images
      final images = firstMatch.querySelectorAll('img');
      print('\nImages in first match:');
      for (var img in images) {
        print(img.outerHtml);
      }

      // Check for text content to find tip
      print('\nText in first match:');
      print(firstMatch.text
          .replaceAll(RegExp(r'\s+'), ' ')
          .substring(0, 500)); // Limit to 500 chars
    } else {
      print('No .matchStats found.');
      // Dump first generic match inner HTML
      final genericMatches = document.querySelectorAll('div[class*="match"]');
      if (genericMatches.isNotEmpty) {
        print('First Generic Match Inner HTML:');
        print(genericMatches.first.innerHtml
            .replaceAll(RegExp(r'\n\s*\n'), '\n'));
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
