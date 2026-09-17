import 'dart:convert';
import 'prediction_model.dart';

class BetModel {
  final String id;
  final MatchPrediction match;
  final String userPrediction;
  final double stake;
  final String notes;
  final DateTime placedAt;

  BetModel({
    required this.id,
    required this.match,
    required this.userPrediction,
    required this.stake,
    this.notes = '',
    DateTime? placedAt,
  }) : placedAt = placedAt ?? DateTime.now();

  factory BetModel.fromJson(Map<String, dynamic> json) => BetModel(
        id: json['id'],
        match: MatchPrediction.fromJson(json['match']),
        userPrediction: json['userPrediction'],
        stake: (json['stake'] as num).toDouble(),
        notes: json['notes'] ?? '',
        placedAt: DateTime.tryParse(json['placedAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'match': match.toJson(),
        'userPrediction': userPrediction,
        'stake': stake,
        'notes': notes,
        'placedAt': placedAt.toIso8601String(),
      };

  static String encodeList(List<BetModel> bets) =>
      jsonEncode(bets.map((b) => b.toJson()).toList());

  static List<BetModel> decodeList(String str) =>
      (jsonDecode(str) as List<dynamic>)
          .map((i) => BetModel.fromJson(i as Map<String, dynamic>))
          .toList();
}
