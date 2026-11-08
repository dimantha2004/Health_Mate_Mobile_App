import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/utils/formatters.dart';
import '../data/daily_summary.dart';
import '../data/health_record.dart';
import '../data/health_record_repository.dart';

/// ViewModel shared by the Records list, the Add/Edit form and the Dashboard.
///
/// Screens read state from here and call its methods; they never talk to the
/// repository directly. After every change the data is reloaded from SQLite
/// and [notifyListeners] rebuilds every screen that is listening, so the list
/// and dashboard always show what is actually stored.
class HealthRecordsProvider extends ChangeNotifier {
  final HealthRecordRepository _repository;

  HealthRecordsProvider(this._repository);

  List<HealthRecord> _records = const [];
  List<DailySummary> _lastSevenDays = const [];
  bool _isLoading = false;
  String? _loadError;
  DateTime? _filterFrom;
  DateTime? _filterTo;

  /// Increases on every [load]; a slower, older load must not overwrite the
  /// result of a newer one (e.g. when the filter changes quickly).
  int _loadRequest = 0;

  /// Records matching the current date filter, newest first.
  List<HealthRecord> get records => _records;

  /// Daily totals for the last 7 days ending today, oldest first.
  /// Empty before the first load completes.
  List<DailySummary> get lastSevenDays => _lastSevenDays;

  /// Totals for today, or null before the first load completes.
  DailySummary? get todaySummary =>
      _lastSevenDays.isEmpty ? null : _lastSevenDays.last;

  bool get isLoading => _isLoading;

  /// Message to show instead of the data when loading failed.
  String? get loadError => _loadError;

  DateTime? get filterFrom => _filterFrom;
  DateTime? get filterTo => _filterTo;
  bool get isFiltered => _filterFrom != null || _filterTo != null;

  /// Reloads the record list (with the current filter) and the daily totals
  /// for the last 7 days, which include today's summary.
  Future<void> load() async {
    final request = ++_loadRequest;
    _isLoading = true;
    _loadError = null;
    notifyListeners();

    try {
      final records =
          await _repository.getRecords(from: _filterFrom, to: _filterTo);
      final end = today();
      final week = await _repository.getDailySummaries(
          DateTime(end.year, end.month, end.day - 6), end);
      if (request != _loadRequest) return;
      _records = records;
      _lastSevenDays = week;
    } catch (error, stack) {
      if (request != _loadRequest) return;
      debugPrint('Failed to load health records: $error\n$stack');
      _loadError = _messageFor(error, 'Could not load your health records.');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Shows only records between [from] and [to] (inclusive). Pass the same
  /// day for both to show a single date.
  Future<void> setDateFilter(DateTime from, DateTime to) {
    _filterFrom = from;
    _filterTo = to;
    return load();
  }

  Future<void> clearDateFilter() {
    _filterFrom = null;
    _filterTo = null;
    return load();
  }

  // The write methods return null on success, or a message for the UI to show.

  Future<String?> addRecord(HealthRecord record) => _write(
      () => _repository.insert(record), 'Could not save the record.');

  Future<String?> updateRecord(HealthRecord record) => _write(
      () => _repository.update(record), 'Could not update the record.');

  Future<String?> deleteRecord(int id) => _write(
      () => _repository.delete(id), 'Could not delete the record.');

  Future<String?> _write(Future<void> Function() action, String fallback) async {
    try {
      await action();
    } catch (error, stack) {
      debugPrint('Health record write failed: $error\n$stack');
      // Reload anyway so the list drops records that no longer exist.
      await load();
      return _messageFor(error, fallback);
    }
    await load();
    return null;
  }

  String _messageFor(Object error, String fallback) => switch (error) {
        RecordNotFoundException() =>
          'This record no longer exists. The list has been refreshed.',
        DatabaseException() => '$fallback A database error occurred.',
        _ => '$fallback Please try again.',
      };
}
