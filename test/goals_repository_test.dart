import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/database/database_helper.dart';
import 'package:healthmate/features/goals/data/daily_goals.dart';
import 'package:healthmate/features/goals/data/goals_repository.dart';
import 'package:healthmate/features/health_records/data/health_record_repository.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('goals on a new database', () {
    late DatabaseHelper helper;
    late GoalsRepository repo;

    setUp(() {
      helper = DatabaseHelper(path: inMemoryDatabasePath, seed: false);
      repo = GoalsRepository(helper);
    });

    tearDown(() => helper.close());

    test('start with the default goals', () async {
      expect(await repo.getGoals(),
          const DailyGoals(steps: 10000, calories: 500, water: 2500));
    });

    test('saved goals are read back', () async {
      const goals = DailyGoals(steps: 8000, calories: 400, water: 3000);
      await repo.saveGoals(goals);
      expect(await repo.getGoals(), goals);
    });

    test('database rejects a goal of 0', () {
      expect(
          () => repo.saveGoals(
              const DailyGoals(steps: 0, calories: 400, water: 3000)),
          throwsA(isA<DatabaseException>()));
    });
  });

  test('upgrading a version 1 database adds goals and keeps records',
      () async {
    final dir = await Directory.systemTemp.createTemp('healthmate_test');
    final file = join(dir.path, 'v1.db');

    final v1 = await openDatabase(file, version: 1, onCreate: (db, _) async {
      await db.execute('CREATE TABLE health_records (id INTEGER PRIMARY KEY '
          'AUTOINCREMENT, date TEXT NOT NULL, steps INTEGER NOT NULL, '
          'calories INTEGER NOT NULL, water INTEGER NOT NULL)');
      await db.insert('health_records',
          {'date': '2026-11-01', 'steps': 1, 'calories': 2, 'water': 3});
    });
    await v1.close();

    final helper = DatabaseHelper(path: file);
    try {
      expect(await (await helper.database).getVersion(), 2);
      expect((await GoalsRepository(helper).getGoals()).steps, 10000);
      expect(await HealthRecordRepository(helper).getRecords(), hasLength(1));
    } finally {
      await helper.close();
      await dir.delete(recursive: true);
    }
  });
}
