import 'package:isar_community/isar.dart';
import 'package:zest/core/utils/calendar_date.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/statistics/presentation/models/statistics_data.dart';

/// Aggregates completion metrics, streaks, and chart data from Isar items.
class StatisticsService {
  /// Loads items and computes dashboard statistics.
  ///
  /// When [includeArchivedCategories] is false, items whose category is
  /// archived (or has no linked category) are excluded.
  static Future<StatisticsData> calculateStatistics(
    Isar isar, {
    bool includeArchivedCategories = false,
  }) async {
    var todos = await isar.todos.where().findAll();
    if (!includeArchivedCategories) {
      todos = todos.where((todo) => todo.task.value?.archive == false).toList();
    }
    final today = CalendarDate.day(DateTime.now());
    final weekStart = CalendarDate.addDays(today, 1 - CalendarDate.weeklyDays);
    final completedTodos = todos.where((t) => t.status.isCompleted).toList();

    final todayCompleted = completedTodos.where((t) {
      final date = _completionDay(t);
      return date != null && date == today;
    }).length;

    final weekCompleted = completedTodos.where((t) {
      final date = _completionDay(t);
      return date != null && !date.isBefore(weekStart);
    }).length;

    final completionRate = todos.isEmpty
        ? 0.0
        : (completedTodos.length / todos.length) * 100;

    final heatmap = _calculateHeatmap(completedTodos, today);
    final streakData = _calculateStreak(heatmap, today);

    return StatisticsData(
      totalTodos: todos.length,
      completedTodos: completedTodos.length,
      completionRate: completionRate,
      completionHeatmap: heatmap,
      todayCompleted: todayCompleted,
      weekCompleted: weekCompleted,
      currentStreak: streakData['current']!,
      longestStreak: streakData['longest']!,
      weeklyProgress: _calculateWeeklyProgress(completedTodos, weekStart),
      hourlyProgress: _calculateHourlyProgress(completedTodos),
    );
  }

  static DateTime? _completionDay(Todos todo) {
    final time = todo.todoCompletionTime;
    return time == null ? null : CalendarDate.day(time);
  }

  /// Daily completion counts for the past [CalendarDate.yearDays].
  static Map<DateTime, int> _calculateHeatmap(
    List<Todos> completedTodos,
    DateTime today,
  ) {
    final heatmap = <DateTime, int>{};
    final startDate = CalendarDate.addDays(today, -CalendarDate.yearDays);

    for (final todo in completedTodos) {
      final date = _completionDay(todo);
      if (date == null || date.isBefore(startDate)) continue;
      heatmap[date] = (heatmap[date] ?? 0) + 1;
    }

    return heatmap;
  }

  /// Current and longest completion streaks from [heatmap].
  static Map<String, int> _calculateStreak(
    Map<DateTime, int> heatmap,
    DateTime todayDate,
  ) {
    if (heatmap.isEmpty) return {'current': 0, 'longest': 0};

    final sortedDates = heatmap.keys.toList()..sort();

    var currentStreak = 0;
    var longestStreak = 0;
    var tempStreak = 0;
    DateTime? lastDate;

    for (final date in sortedDates) {
      if (lastDate != null && CalendarDate.daysBetween(lastDate, date) != 1) {
        longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
        tempStreak = 0;
      }
      tempStreak++;
      lastDate = date;
    }

    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    if (lastDate != null &&
        CalendarDate.daysBetween(lastDate, todayDate) <= 1) {
      currentStreak = tempStreak;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  /// Completions by weekday within the current weekly window.
  static Map<int, int> _calculateWeeklyProgress(
    List<Todos> completedTodos,
    DateTime weekStart,
  ) {
    final weeklyData = <int, int>{
      for (var i = 1; i <= CalendarDate.weeklyDays; i++) i: 0,
    };

    for (final todo in completedTodos) {
      final date = _completionDay(todo);
      if (date == null || date.isBefore(weekStart)) continue;
      final weekday = todo.todoCompletionTime!.weekday;
      weeklyData[weekday] = (weeklyData[weekday] ?? 0) + 1;
    }

    return weeklyData;
  }

  /// Completions by hour of day (0–23).
  static Map<int, int> _calculateHourlyProgress(List<Todos> completedTodos) {
    final hourlyData = {for (var i = 0; i < 24; i++) i: 0};

    for (final todo in completedTodos) {
      final time = todo.todoCompletionTime;
      if (time == null) continue;
      hourlyData[time.hour] = (hourlyData[time.hour] ?? 0) + 1;
    }

    return hourlyData;
  }
}
