import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/features/health_records/data/health_record.dart';

void main() {
  final record = HealthRecord(
    id: 7,
    date: DateTime(2026, 8, 18),
    steps: 7850,
    calories: 420,
    water: 2000,
  );

  test('toMap stores the date as yyyy-MM-dd text', () {
    expect(record.toMap(), {
      'id': 7,
      'date': '2026-08-18',
      'steps': 7850,
      'calories': 420,
      'water': 2000,
    });
  });

  test('toMap omits id for a new record so SQLite can assign it', () {
    final unsaved = HealthRecord(
        date: DateTime(2026, 8, 18), steps: 1, calories: 1, water: 1);
    expect(unsaved.toMap().containsKey('id'), isFalse);
  });

  test('fromMap(toMap) round-trips the record', () {
    expect(HealthRecord.fromMap(record.toMap()), record);
  });
}
