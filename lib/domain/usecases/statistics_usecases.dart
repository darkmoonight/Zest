import 'package:zest/core/utils/calendar_date.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/domain/repositories/todo_repository.dart';
import 'package:zest/domain/models/statistics_data.dart';

/// Aggregates completion metrics, streaks, and chart data from items.
class StatisticsService {
  /// Loads items and computes dashboard statistics.
  ///
  /// When [includeArchivedCategories] is false, items whose category is
  /// archived (or has no linked category) are excluded.
  static Future<StatisticsData> calculateStatistics(
    TodoRepositoryPort todoRepo, {
    CategoryRepositoryPort? categoryRepo,
    bool includeArchivedCategories = false,
  }) async {
    var todos = await todoRepo.getAll();
    if (!includeArchivedCategories) {
      final categories = await categoryRepo?.getAll() ?? const [];
      final archivedIds = {
        for (final c in categories)
          if (c.archive) c.id,
      };
      todos = todos
          .where(
            (todo) =>
                todo.categoryId != null &&
                !archivedIds.contains(todo.categoryId),
          )
          .toList();
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

    final completionDays = _completionDayCounts(completedTodos);
    final heatmap = _heatmapWindow(completionDays, today);
    final streakData = _calculateStreak(completionDays, today);

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

  static DateTime? _completionDay(Todo todo) {
    final time = todo.completedAt;
    return time == null ? null : CalendarDate.day(time);
  }

  /// All-time daily completion counts (used for streaks).
  static Map<DateTime, int> _completionDayCounts(List<Todo> completedTodos) {
    final counts = <DateTime, int>{};
    for (final todo in completedTodos) {
      final date = _completionDay(todo);
      if (date == null) continue;
      counts[date] = (counts[date] ?? 0) + 1;
    }
    return counts;
  }

  /// Daily completion counts for the past [CalendarDate.yearDays] (heatmap UI).
  static Map<DateTime, int> _heatmapWindow(
    Map<DateTime, int> completionDays,
    DateTime today,
  ) {
    final startDate = CalendarDate.addDays(today, -CalendarDate.yearDays);
    return {
      for (final entry in completionDays.entries)
        if (!entry.key.isBefore(startDate)) entry.key: entry.value,
    };
  }

  /// Current and all-time longest completion streaks from [completionDays].
  static Map<String, int> _calculateStreak(
    Map<DateTime, int> completionDays,
    DateTime todayDate,
  ) {
    if (completionDays.isEmpty) return {'current': 0, 'longest': 0};

    final sortedDates = completionDays.keys.toList()..sort();

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
    List<Todo> completedTodos,
    DateTime weekStart,
  ) {
    final weeklyData = <int, int>{
      for (var i = 1; i <= CalendarDate.weeklyDays; i++) i: 0,
    };

    for (final todo in completedTodos) {
      final date = _completionDay(todo);
      if (date == null || date.isBefore(weekStart)) continue;
      final weekday = todo.completedAt!.weekday;
      weeklyData[weekday] = (weeklyData[weekday] ?? 0) + 1;
    }

    return weeklyData;
  }

  /// Completions by hour of day (0–23).
  static Map<int, int> _calculateHourlyProgress(List<Todo> completedTodos) {
    final hourlyData = {for (var i = 0; i < 24; i++) i: 0};

    for (final todo in completedTodos) {
      final time = todo.completedAt;
      if (time == null) continue;
      hourlyData[time.hour] = (hourlyData[time.hour] ?? 0) + 1;
    }

    return hourlyData;
  }
}
