import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/date_format.dart';

/// Owns the SQLite connection and schema. Queries live in the repositories.
///
/// One instance is created in `main()` and handed to the repositories, so
/// tests can use an in-memory database instead of the device file.
class DatabaseHelper {
  static const databaseName = 'healthmate.db';
  static const _version = 1;

  /// Database file path; defaults to `healthmate.db` in the app's
  /// database folder.
  final String? path;

  /// Inserts demo records the first time the database is created.
  final bool seed;

  Future<Database>? _database;

  DatabaseHelper({this.path, this.seed = true});

  /// Opens the database on first use. Caching the Future (not the Database)
  /// means concurrent callers share one open call instead of racing.
  Future<Database> get database => _database ??= _open();

  Future<Database> _open() async {
    final file = path ?? join(await getDatabasesPath(), databaseName);
    return openDatabase(file, version: _version, onCreate: _onCreate);
  }

  /// Runs only when the database file does not exist yet.
  Future<void> _onCreate(Database db, int version) async {
    // Field names and types are exactly those required by the brief.
    // CHECK constraints stop invalid data even if app validation is bypassed.
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
    // Every list, filter and dashboard query filters or sorts by date.
    await db.execute(
        'CREATE INDEX idx_health_records_date ON health_records(date)');

    if (seed) await _insertSeedData(db);
  }

  /// Two weeks of demo data ending today, so the dashboard and list have
  /// content on first launch. Today has two entries to show that the
  /// dashboard adds up multiple records (7,850 steps, 420 kcal, 2,000 ml).
  static const _seedRows = [
    // [days ago, steps, calories, water ml]
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
      // DateTime(y, m, d - n) handles month boundaries and DST correctly.
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
