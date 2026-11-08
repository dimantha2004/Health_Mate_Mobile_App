import '../../../core/database/database_helper.dart';
import '../../../core/utils/formatters.dart';
import 'daily_summary.dart';
import 'health_record.dart';

/// Thrown when an update or delete targets a record that no longer exists.
class RecordNotFoundException implements Exception {
  final int id;
  const RecordNotFoundException(this.id);

  @override
  String toString() => 'Health record $id was not found.';
}

/// All SQL for the `health_records` table. Every query uses `?` arguments,
/// never string concatenation, so user input cannot inject SQL.
class HealthRecordRepository {
  static const _table = 'health_records';

  final DatabaseHelper _databaseHelper;

  HealthRecordRepository(this._databaseHelper);

  /// Records newest first. Pass [from] and/or [to] (inclusive) to filter by
  /// date; pass the same day for both to get a single date.
  Future<List<HealthRecord>> getRecords({DateTime? from, DateTime? to}) async {
    final db = await _databaseHelper.database;
    final where = <String>[];
    final args = <Object?>[];
    if (from != null) {
      where.add('date >= ?');
      args.add(toDbDate(from));
    }
    if (to != null) {
      where.add('date <= ?');
      args.add(toDbDate(to));
    }
    final rows = await db.query(
      _table,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(HealthRecord.fromMap).toList();
  }

  /// Inserts [record] and returns it with the id SQLite assigned.
  Future<HealthRecord> insert(HealthRecord record) async {
    final db = await _databaseHelper.database;
    final id = await db.insert(_table, record.toMap()..remove('id'));
    return record.copyWith(id: id);
  }

  Future<void> update(HealthRecord record) async {
    final id = record.id;
    if (id == null) {
      throw ArgumentError('Cannot update a record that has not been saved.');
    }
    final db = await _databaseHelper.database;
    final changed = await db.update(
      _table,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    if (changed == 0) throw RecordNotFoundException(id);
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    final deleted = await db.delete(_table, where: 'id = ?', whereArgs: [id]);
    if (deleted == 0) throw RecordNotFoundException(id);
  }

  /// Sums every record on [date]. Returns zeros when there are none.
  Future<DailySummary> getDailySummary(DateTime date) async =>
      (await getDailySummaries(date, date)).single;

  /// One summary per day from [from] to [to] (inclusive), oldest first.
  /// Days without records are included with zero totals, so charts always
  /// get a complete series.
  Future<List<DailySummary>> getDailySummaries(
      DateTime from, DateTime to) async {
    final db = await _databaseHelper.database;
    final rows = await db.rawQuery('''
      SELECT date,
             SUM(steps)    AS steps,
             SUM(calories) AS calories,
             SUM(water)    AS water,
             COUNT(*)      AS entries
      FROM $_table
      WHERE date BETWEEN ? AND ?
      GROUP BY date
    ''', [toDbDate(from), toDbDate(to)]);
    final byDate = {for (final row in rows) row['date'] as String: row};

    return [
      // DateTime(y, m, d + 1) steps one calendar day, safe across DST.
      for (var day = from;
          !day.isAfter(to);
          day = DateTime(day.year, day.month, day.day + 1))
        _toSummary(day, byDate[toDbDate(day)]),
    ];
  }

  static DailySummary _toSummary(DateTime date, Map<String, Object?>? row) =>
      DailySummary(
        date: date,
        steps: row?['steps'] as int? ?? 0,
        calories: row?['calories'] as int? ?? 0,
        water: row?['water'] as int? ?? 0,
        entryCount: row?['entries'] as int? ?? 0,
      );
}
