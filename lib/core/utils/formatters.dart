import 'package:intl/intl.dart';

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

final _longDate = DateFormat('d MMMM y');
final _mediumDate = DateFormat('EEE, d MMM y');
final _shortDate = DateFormat('d MMM');
final _number = NumberFormat('#,##0');

/// "8 November 2026"
String formatLongDate(DateTime date) => _longDate.format(date);

/// "Sun, 8 Nov 2026"
String formatMediumDate(DateTime date) => _mediumDate.format(date);

/// "8 Nov"
String formatShortDate(DateTime date) => _shortDate.format(date);

/// "7,850"
String formatNumber(int value) => _number.format(value);
