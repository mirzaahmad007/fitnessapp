import '../userscreens/waterpage.dart';

abstract class WaterRepository {
  Future<void> saveDailyGoal(double dailyGoalMl);
  Future<double> loadDailyGoal();
  Future<void> saveTodayIntake(String dateKey, double intakeMl);
  Future<double> loadTodayIntake(String dateKey);
  Future<void> saveHistory(List<DayRecord> history);
  Future<List<DayRecord>> loadHistory();
}