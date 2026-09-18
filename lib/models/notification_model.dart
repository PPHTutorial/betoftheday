import 'dart:convert';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'live', 'kickoff', 'finished', 'bookmark', 'favorite', 'server', 'general'
  final bool isRead;
  final String? matchId;
  final String? homeTeam;
  final String? awayTeam;
  final String? score;
  final String? xg;
  final String? prediction;
  final String? odds;
  final String? league;
  final String? venue;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.type = 'general',
    this.isRead = false,
    this.matchId,
    this.homeTeam,
    this.awayTeam,
    this.score,
    this.xg,
    this.prediction,
    this.odds,
    this.league,
    this.venue,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    bool? isRead,
    String? matchId,
    String? homeTeam,
    String? awayTeam,
    String? score,
    String? xg,
    String? prediction,
    String? odds,
    String? league,
    String? venue,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      matchId: matchId ?? this.matchId,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      score: score ?? this.score,
      xg: xg ?? this.xg,
      prediction: prediction ?? this.prediction,
      odds: odds ?? this.odds,
      league: league ?? this.league,
      venue: venue ?? this.venue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
      'matchId': matchId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'score': score,
      'xg': xg,
      'prediction': prediction,
      'odds': odds,
      'league': league,
      'venue': venue,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      type: json['type'] ?? 'general',
      isRead: json['isRead'] ?? false,
      matchId: json['matchId'],
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      score: json['score'],
      xg: json['xg'],
      prediction: json['prediction'],
      odds: json['odds'],
      league: json['league'],
      venue: json['venue'],
    );
  }

  static String encodeList(List<AppNotification> list) {
    return jsonEncode(list.map((n) => n.toJson()).toList());
  }

  static List<AppNotification> decodeList(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr) as List;
      return decoded.map((e) => AppNotification.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
