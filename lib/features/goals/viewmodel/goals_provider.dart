import 'package:flutter/foundation.dart';

import '../data/daily_goals.dart';
import '../data/goals_repository.dart';

/// ViewModel for the user's daily goals, used by the Goals screen (to edit)
/// and the Dashboard (to show progress).
class GoalsProvider extends ChangeNotifier {
  final GoalsRepository _repository;

  GoalsProvider(this._repository);

  DailyGoals? _goals;
  bool _isLoading = false;
  String? _loadError;

  /// Null until the first load completes.
  DailyGoals? get goals => _goals;
  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  Future<void> load() async {
    _isLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      _goals = await _repository.getGoals();
    } catch (error, stack) {
      debugPrint('Failed to load goals: $error\n$stack');
      _loadError = 'Could not load your goals. Please try again.';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Saves [goals]. Returns null on success, or a message for the UI.
  Future<String?> save(DailyGoals goals) async {
    try {
      await _repository.saveGoals(goals);
    } catch (error, stack) {
      debugPrint('Failed to save goals: $error\n$stack');
      return 'Could not save your goals. Please try again.';
    }
    _goals = goals;
    notifyListeners();
    return null;
  }
}
