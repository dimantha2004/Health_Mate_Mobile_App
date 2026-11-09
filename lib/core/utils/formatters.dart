import 'package:intl/intl.dart';

String toDbDate(DateTime date) => date.toIso8601String().substring(0, 10);

DateTime fromDbDate(String value) => DateTime.parse(value);

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

final _longDate = DateFormat('d MMMM y');
final _mediumDate = DateFormat('EEE, d MMM y');
final _shortDate = DateFormat('d MMM');
final _number = NumberFormat('#,##0');

String formatLongDate(DateTime date) => _longDate.format(date);

String formatMediumDate(DateTime date) => _mediumDate.format(date);

String formatShortDate(DateTime date) => _shortDate.format(date);

String formatNumber(int value) => _number.format(value);
