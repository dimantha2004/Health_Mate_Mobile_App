import '../../../core/utils/date_format.dart';

/// One row of the `health_records` table.
class HealthRecord {
  /// Null until the record has been inserted into the database.
  final int? id;
  final DateTime date;
  final int steps;

  /// Calories burned, in kcal.
  final int calories;

  /// Water intake, in ml.
  final int water;

  const HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  factory HealthRecord.fromMap(Map<String, Object?> map) => HealthRecord(
        id: map['id'] as int?,
        date: fromDbDate(map['date'] as String),
        steps: map['steps'] as int,
        calories: map['calories'] as int,
        water: map['water'] as int,
      );

  /// Column map for sqflite. `id` is left out when null so SQLite assigns it.
  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'date': toDbDate(date),
        'steps': steps,
        'calories': calories,
        'water': water,
      };

  HealthRecord copyWith({
    int? id,
    DateTime? date,
    int? steps,
    int? calories,
    int? water,
  }) =>
      HealthRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        steps: steps ?? this.steps,
        calories: calories ?? this.calories,
        water: water ?? this.water,
      );

  @override
  bool operator ==(Object other) =>
      other is HealthRecord &&
      other.id == id &&
      other.date == date &&
      other.steps == steps &&
      other.calories == calories &&
      other.water == water;

  @override
  int get hashCode => Object.hash(id, date, steps, calories, water);

  @override
  String toString() =>
      'HealthRecord(id: $id, date: ${toDbDate(date)}, steps: $steps, '
      'calories: $calories, water: $water)';
}
