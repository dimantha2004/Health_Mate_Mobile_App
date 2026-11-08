/// Converts a [DateTime] to the `yyyy-MM-dd` text stored in SQLite.
///
/// ISO dates sort and compare correctly as plain text, so `ORDER BY date`
/// and `BETWEEN` work without any date functions in SQL.
String toDbDate(DateTime date) => date.toIso8601String().substring(0, 10);

/// Parses a `yyyy-MM-dd` value read from SQLite back to a local date.
DateTime fromDbDate(String value) => DateTime.parse(value);

/// Today's date with the time stripped (local midnight).
DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
