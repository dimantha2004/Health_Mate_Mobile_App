/// Totals of all health records for one day, as shown on the dashboard.
class DailySummary {
  final DateTime date;
  final int steps;
  final int calories;
  final int water;

  /// How many records were added for this day.
  final int entryCount;

  const DailySummary({
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
    required this.entryCount,
  });

  bool get isEmpty => entryCount == 0;
}
