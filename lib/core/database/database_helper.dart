import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/formatters.dart';

class DatabaseHelper {
  static const databaseName = 'healthmate.db';
  static const _version = 2;

  final String? path;

  final bool seed;

  Future<Database>? _database;

  DatabaseHelper({this.path, this.seed = true});

  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    final file = path ?? join(await getDatabasesPath(), databaseName);
    return openDatabase(
      file,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createHealthRecordsTable(db);
    await _createGoalsTable(db);
    if (seed) await _insertSeedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) await _createGoalsTable(db);
  }

  Future<void> _createHealthRecordsTable(Database db) async {
    await db.execute('''
      CREATE TABLE health_records (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        date     TEXT    NOT NULL
                 CHECK (date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
        steps    INTEGER NOT NULL CHECK (steps >= 0),
        calories INTEGER NOT NULL CHECK (calories >= 0),
        water    INTEGER NOT NULL CHECK (water >= 0)
      )
    ''');
    await db.execute(
        'CREATE INDEX idx_health_records_date ON health_records(date)');
  }

  Future<void> _createGoalsTable(Database db) async {
    await db.execute('''
      CREATE TABLE daily_goals (
        id            INTEGER PRIMARY KEY CHECK (id = 1),
        steps_goal    INTEGER NOT NULL CHECK (steps_goal > 0),
        calories_goal INTEGER NOT NULL CHECK (calories_goal > 0),
        water_goal    INTEGER NOT NULL CHECK (water_goal > 0)
      )
    ''');
    await db.insert('daily_goals', {
      'id': 1,
      'steps_goal': 10000,
      'calories_goal': 500,
      'water_goal': 2500,
    });
  }

  static const _seedRows = [
    [0, 4200, 230, 1000],
    [0, 3650, 190, 1000],
    [1, 9120, 480, 2300],
    [2, 6540, 350, 1800],
    [3, 11230, 610, 2600],
    [4, 7850, 420, 2000],
    [5, 5310, 280, 1500],
    [5, 2400, 130, 500],
    [6, 8760, 460, 2200],
    [7, 10450, 560, 2400],
    [8, 4980, 260, 1600],
    [9, 7320, 390, 2100],
    [10, 12010, 650, 2800],
    [11, 6890, 370, 1900],
    [12, 8240, 440, 2000],
    [13, 9530, 500, 2500],
  ];

  Future<void> _insertSeedData(Database db) async {
    final now = today();
    final batch = db.batch();
    for (final [daysAgo, steps, calories, water] in _seedRows) {
      final date = DateTime(now.year, now.month, now.day - daysAgo);
      batch.insert('health_records', {
        'date': toDbDate(date),
        'steps': steps,
        'calories': calories,
        'water': water,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) await (await db).close();
  }
}
