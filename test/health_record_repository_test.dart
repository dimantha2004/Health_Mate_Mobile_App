import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/database/database_helper.dart';
import 'package:healthmate/core/utils/formatters.dart';
import 'package:healthmate/features/health_records/data/health_record.dart';
import 'package:healthmate/features/health_records/data/health_record_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper helper;
  late HealthRecordRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  void openDb({bool seed = false}) {
    helper = DatabaseHelper(path: inMemoryDatabasePath, seed: seed);
    repo = HealthRecordRepository(helper);
  }

  tearDown(() => helper.close());

  HealthRecord record(DateTime date, {int steps = 1000}) => HealthRecord(
      date: date, steps: steps, calories: 100, water: 500);

  group('seed data', () {
    setUp(() => openDb(seed: true));

    test('creates two weeks of records', () async {
      final records = await repo.getRecords();
      expect(records, hasLength(16));
      expect(records.first.date, today());
    });

    test("today's summary matches the brief example", () async {
      final summary = await repo.getDailySummary(today());
      expect(summary.steps, 7850);
      expect(summary.calories, 420);
      expect(summary.water, 2000);
      expect(summary.entryCount, 2);
    });
  });

  group('CRUD', () {
    setUp(() => openDb());

    test('insert assigns an id and the record can be read back', () async {
      final saved = await repo.insert(record(DateTime(2026, 11, 1)));
      expect(saved.id, isNotNull);
      expect(await repo.getRecords(), [saved]);
    });

    test('update changes the stored values', () async {
      final saved = await repo.insert(record(DateTime(2026, 11, 1)));
      final edited = saved.copyWith(steps: 9999, water: 2500);
      await repo.update(edited);
      expect(await repo.getRecords(), [edited]);
    });

    test('update of a deleted record throws RecordNotFoundException', () async {
      final saved = await repo.insert(record(DateTime(2026, 11, 1)));
      await repo.delete(saved.id!);
      expect(() => repo.update(saved),
          throwsA(isA<RecordNotFoundException>()));
    });

    test('delete removes only that record', () async {
      final a = await repo.insert(record(DateTime(2026, 11, 1)));
      final b = await repo.insert(record(DateTime(2026, 11, 2)));
      await repo.delete(a.id!);
      expect(await repo.getRecords(), [b]);
    });

    test('delete of an unknown id throws RecordNotFoundException', () {
      expect(() => repo.delete(12345), throwsA(isA<RecordNotFoundException>()));
    });

    test('database rejects negative values', () {
      expect(() => repo.insert(record(DateTime(2026, 11, 1), steps: -5)),
          throwsA(isA<DatabaseException>()));
    });
  });

  group('search and summary', () {
    setUp(() async {
      openDb();
      for (final day in [1, 2, 2, 3, 5]) {
        await repo.insert(record(DateTime(2026, 11, day), steps: day * 1000));
      }
    });

    test('records are listed newest first', () async {
      final dates = (await repo.getRecords()).map((r) => r.date.day).toList();
      expect(dates, [5, 3, 2, 2, 1]);
    });

    test('filter by a single date', () async {
      final day = DateTime(2026, 11, 2);
      final records = await repo.getRecords(from: day, to: day);
      expect(records, hasLength(2));
      expect(records.every((r) => r.date == day), isTrue);
    });

    test('filter by an inclusive date range', () async {
      final records = await repo.getRecords(
          from: DateTime(2026, 11, 2), to: DateTime(2026, 11, 3));
      expect(records.map((r) => r.date.day), [3, 2, 2]);
    });

    test('filter with no matches returns an empty list', () async {
      final day = DateTime(2026, 11, 4);
      expect(await repo.getRecords(from: day, to: day), isEmpty);
    });

    test('daily summary adds up every record on that date', () async {
      final summary = await repo.getDailySummary(DateTime(2026, 11, 2));
      expect(summary.steps, 4000);
      expect(summary.calories, 200);
      expect(summary.water, 1000);
      expect(summary.entryCount, 2);
    });

    test('daily summaries cover every day in the range, oldest first',
        () async {
      final days = await repo.getDailySummaries(
          DateTime(2026, 11, 1), DateTime(2026, 11, 5));
      expect(days.map((d) => d.date.day), [1, 2, 3, 4, 5]);
      expect(days.map((d) => d.steps), [1000, 4000, 3000, 0, 5000]);
      expect(days.map((d) => d.entryCount), [1, 2, 1, 0, 1]);
    });

    test('daily summaries work across a month boundary', () async {
      final days = await repo.getDailySummaries(
          DateTime(2026, 10, 30), DateTime(2026, 11, 2));
      expect(days.map((d) => d.date),
          [DateTime(2026, 10, 30), DateTime(2026, 10, 31),
           DateTime(2026, 11, 1), DateTime(2026, 11, 2)]);
    });

    test('daily summary for a day without records is all zeros', () async {
      final summary = await repo.getDailySummary(DateTime(2026, 11, 4));
      expect(summary.isEmpty, isTrue);
      expect([summary.steps, summary.calories, summary.water], [0, 0, 0]);
    });
  });
}
