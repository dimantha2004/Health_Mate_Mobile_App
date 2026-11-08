/// The user's daily targets: the single row of the `daily_goals` table.
class DailyGoals {
  final int steps;
  final int calories;
  final int water;

  const DailyGoals({
    required this.steps,
    required this.calories,
    required this.water,
  });

  factory DailyGoals.fromMap(Map<String, Object?> map) => DailyGoals(
        steps: map['steps_goal'] as int,
        calories: map['calories_goal'] as int,
        water: map['water_goal'] as int,
      );

  Map<String, Object?> toMap() => {
        'steps_goal': steps,
        'calories_goal': calories,
        'water_goal': water,
      };

  @override
  bool operator ==(Object other) =>
      other is DailyGoals &&
      other.steps == steps &&
      other.calories == calories &&
      other.water == water;

  @override
  int get hashCode => Object.hash(steps, calories, water);
}
