import 'dart:convert';

class League {
  final String id;
  final String name;
  final String country;
  final String url;
  final String? season;
  final String leagueLogo;
  final String leagueCountry;
  final String leagueCountryFlag;

  League({
    required this.id,
    required this.name,
    required this.country,
    required this.url,
    required this.leagueLogo,
    required this.leagueCountry,
    required this.leagueCountryFlag,
    this.season,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      id: json['id']?.toString() ?? json['leagueId']?.toString() ?? '',
      name: json['name']?.toString() ?? json['leagueName']?.toString() ?? '',
      country: json['country']?.toString() ??
          json['leagueCountry']?.toString() ??
          '',
      url: json['url']?.toString() ?? json['leagueUrl']?.toString() ?? '',
      leagueLogo: json['leagueLogo']?.toString() ?? '',
      leagueCountry: json['leagueCountry']?.toString() ?? '',
      leagueCountryFlag: json['leagueCountryFlag']?.toString() ?? '',
      season: json['season']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leagueId': id,
      'name': name,
      'leagueName': name,
      'country': country,
      'leagueCountry': country,
      'url': url,
      'leagueUrl': url,
      'leagueLogo': leagueLogo,
      'leagueCountryFlag': leagueCountryFlag,
      'season': season,
    };
  }

  static String encodeList(List<League> leagues) {
    return jsonEncode(leagues.map((l) => l.toJson()).toList());
  }

  static List<League> decodeList(String jsonStr) {
    final List<dynamic> list = jsonDecode(jsonStr);
    return list
        .map((item) => League.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
