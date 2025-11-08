import 'package:flutter/foundation.dart';

enum PredictionResult {
  pending('PENDING'),
  won('WON'),
  lost('LOST');

  const PredictionResult(this.value);
  final String value;

  static PredictionResult fromString(String value) {
    return PredictionResult.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PredictionResult.pending,
    );
  }
}

enum GameType {
  vipGame('VIP_GAME'),
  betOfTheDay('BET_OF_THE_DAY'),
  freeGame('FREE_GAME'),
  correctScore('CORRECT_SCORE'),
  drawGame('DRAW_GAME');

  const GameType(this.value);
  final String value;

  static GameType fromString(String value) {
    return GameType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GameType.freeGame,
    );
  }

  String get displayName {
    switch (this) {
      case GameType.vipGame:
        return 'VIP Predictions';
      case GameType.betOfTheDay:
        return 'Bet of the Day';
      case GameType.freeGame:
        return 'Free Odds';
      case GameType.correctScore:
        return 'Correct Score';
      case GameType.drawGame:
        return 'Draw Games';
    }
  }
}

class PredictionModel {
  final String id;
  final String sportType;
  final String league;
  final String homeTeam;
  final String awayTeam;
  final String tip;
  final String? analysis;
  final String? odds;
  final PredictionResult result;
  final DateTime publishedAt;
  final String userId;
  final GameType gameType;
  final DateTime createdAt;
  final DateTime updatedAt;

  PredictionModel({
    required this.id,
    required this.sportType,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.tip,
    this.analysis,
    this.odds,
    required this.result,
    required this.publishedAt,
    required this.userId,
    required this.gameType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse DateTime safely
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          debugPrint('Error parsing date: $value, error: $e');
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return PredictionModel(
      id: json['id']?.toString() ?? '',
      sportType: json['sportType']?.toString() ?? '',
      league: json['league']?.toString() ?? '',
      homeTeam: json['homeTeam']?.toString() ?? '',
      awayTeam: json['awayTeam']?.toString() ?? '',
      tip: json['tip']?.toString() ?? '',
      analysis: json['analysis']?.toString(),
      odds: json['odds']?.toString(),
      result:
          PredictionResult.fromString(json['result']?.toString() ?? 'PENDING'),
      publishedAt: parseDateTime(json['publishedAt']),
      userId: json['userId']?.toString() ?? '',
      gameType:
          GameType.fromString(json['gameType']?.toString() ?? 'FREE_GAME'),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sportType': sportType,
      'league': league,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'tip': tip,
      'analysis': analysis,
      'odds': odds,
      'result': result.value,
      'publishedAt': publishedAt.toIso8601String(),
      'userId': userId,
      'gameType': gameType.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get matchDisplay => '$homeTeam vs $awayTeam';
  bool get isPending => result == PredictionResult.pending;
  bool get isWon => result == PredictionResult.won;
  bool get isLost => result == PredictionResult.lost;
}
