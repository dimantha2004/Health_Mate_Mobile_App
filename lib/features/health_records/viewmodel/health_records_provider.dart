import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/utils/formatters.dart';
import '../data/daily_summary.dart';
import '../data/health_record.dart';
import '../data/health_record_repository.dart';

class HealthRecordsProvider extends ChangeNotifier {
  final HealthRecordRepository _repository;

  HealthRecordsProvider(this._repository);

  List<HealthRecord> _records = const [];
  List<DailySummary> _lastSevenDays = const [];
  bool _isLoading = false;
  String? _loadError;
  DateTime? _filterFrom;
  DateTime? _filterTo;

  int _loadRequest = 0;

  List<HealthRecord> get records => _records;

  List<DailySummary> get lastSevenDays => _lastSevenDays;

  DailySummary? get todaySummary =>
      _lastSevenDays.isEmpty ? null : _lastSevenDays.last;

  bool get isLoading => _isLoading;

  String? get loadError => _loadError;

  DateTime? get filterFrom => _filterFrom;
  DateTime? get filterTo => _filterTo;
  bool get isFiltered => _filterFrom != null || _filterTo != null;

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
