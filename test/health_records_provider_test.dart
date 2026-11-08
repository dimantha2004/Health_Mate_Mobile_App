import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/database/database_helper.dart';
import 'package:healthmate/core/utils/date_format.dart';
import 'package:healthmate/features/health_records/data/health_record.dart';
import 'package:healthmate/features/health_records/data/health_record_repository.dart';
import 'package:healthmate/features/health_records/viewmodel/health_records_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late DatabaseHelper helper;
  late HealthRecordsProvider provider;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    helper = DatabaseHelper(path: inMemoryDatabasePath, seed: false);
    provider = HealthRecordsProvider(HealthRecordRepository(helper));
  });

  tearDown(() => helper.close());

  HealthRecord record(DateTime date) =>
      HealthRecord(date: date, steps: 1000, calories: 100, water: 250);

  test('load fills records and today summary and notifies listeners',
      () async {
    var notifications = 0;
    provider.addListener(() => notifications++);

    await provider.load();

    expect(provider.isLoading, isFalse);
    expect(provider.loadError, isNull);
    expect(provider.records, isEmpty);
    expect(provider.todaySummary!.isEmpty, isTrue);
    expect(notifications, 2); // loading started, loading finished
  });

  test('adding a record refreshes the list and today summary', () async {
    await provider.load();

    final error = await provider.addRecord(record(today()));

    expect(error, isNull);
    expect(provider.records, hasLength(1));
    expect(provider.todaySummary!.water, 250);
  });

  test('update and delete are reflected in the list', () async {
    await provider.addRecord(record(today()));
    final saved = provider.records.single;

    await provider.updateRecord(saved.copyWith(water: 750));
    expect(provider.records.single.water, 750);
    expect(provider.todaySummary!.water, 750);

    await provider.deleteRecord(saved.id!);
    expect(provider.records, isEmpty);
  });

  test('date filter limits the list and can be cleared', () async {
    await provider.addRecord(record(DateTime(2026, 11, 1)));
    await provider.addRecord(record(DateTime(2026, 11, 2)));

    final day = DateTime(2026, 11, 2);
    await provider.setDateFilter(day, day);
    expect(provider.isFiltered, isTrue);
    expect(provider.records.map((r) => r.date), [day]);

    await provider.clearDateFilter();
    expect(provider.isFiltered, isFalse);
    expect(provider.records, hasLength(2));
  });

  test('deleting a record that no longer exists returns a message', () async {
    final error = await provider.deleteRecord(999);
    expect(error, contains('no longer exists'));
  });

  group('when the database fails', () {
    // Dropping the table makes every real query throw a DatabaseException.
    setUp(() async {
      await (await helper.database).execute('DROP TABLE health_records');
    });

    test('loading sets loadError instead of crashing', () async {
      await provider.load();
      expect(provider.isLoading, isFalse);
      expect(provider.loadError, contains('Could not load'));
    });

    test('saving returns a message for the user', () async {
      final error = await provider.addRecord(record(today()));
      expect(error, 'Could not save the record. A database error occurred.');
    });
  });
}
