import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prediction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'historical_matches.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE matches(id TEXT PRIMARY KEY, matchDate TEXT, leagueId TEXT, fullJson TEXT)',
        );
      },
    );
  }

  Future<void> insertMatch(MatchPrediction match) async {
    final db = await database;
    await db.insert(
      'matches',
      {
        'id': match.id,
        'matchDate': match.matchDate.toIso8601String(),
        'leagueId': match.leagueId,
        'fullJson': jsonEncode(match.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertMatches(List<MatchPrediction> matches) async {
    final db = await database;
    final batch = db.batch();
    for (var match in matches) {
      batch.insert(
        'matches',
        {
          'id': match.id,
          'matchDate': match.matchDate.toIso8601String(),
          'leagueId': match.leagueId,
          'fullJson': jsonEncode(match.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<MatchPrediction>> getMatches({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      orderBy: 'matchDate DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final jsonStr = maps[i]['fullJson'] as String;
      return MatchPrediction.fromJson(jsonDecode(jsonStr));
    });
  }

  Future<List<MatchPrediction>> getMatchesPaginated({
    required int limit,
    required int offset,
    String? leagueId,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'matches',
      where: leagueId != null && leagueId != 'ALL' ? 'leagueId = ?' : null,
      whereArgs: leagueId != null && leagueId != 'ALL' ? [leagueId] : null,
      orderBy: 'matchDate DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      final jsonStr = maps[i]['fullJson'] as String;
      return MatchPrediction.fromJson(jsonDecode(jsonStr));
    });
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('matches');
  }

  Future<int> getCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM matches');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
