import '../../../core/database/database_helper.dart';
import 'daily_goals.dart';

class GoalsRepository {
  final DatabaseHelper _databaseHelper;

  GoalsRepository(this._databaseHelper);

  Future<DailyGoals> getGoals() async {
    final db = await _databaseHelper.database;
    final rows = await db.query('daily_goals', where: 'id = 1');
    return DailyGoals.fromMap(rows.single);
  }

  Future<void> saveGoals(DailyGoals goals) async {
    final db = await _databaseHelper.database;
    await db.update('daily_goals', goals.toMap(), where: 'id = 1');
  }
}
