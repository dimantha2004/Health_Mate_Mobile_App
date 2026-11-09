import 'formatters.dart';

String? validateWholeNumber(String? value,
    {required String label, required int max, int min = 0}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$label is required';
  final number = int.tryParse(text);
  if (number == null) return 'Enter a whole number';
  if (number < 0) return '$label cannot be negative';
  if (number < min) return '$label must be at least ${formatNumber(min)}';
  if (number > max) return '$label must be ${formatNumber(max)} or less';
  return null;
}

String? validateRecordDate(DateTime? date) {
  if (date == null) return 'Select a date';
  if (date.isAfter(today())) return 'Date cannot be in the future';
  return null;
}
