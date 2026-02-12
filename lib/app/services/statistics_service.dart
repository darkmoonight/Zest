import 'package:isar_community/isar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/statistics/models/statistics_data.dart';
import 'package:zest/main.dart';

class StatisticsService {
  static Future<StatisticsData> calculateStatistics() async {
    final todos = await isar.todos.where().findAll();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    final completedTodos = todos.where((t) => t.status.isCompleted).toList();

    final todayCompleted = completedTodos.where((t) {
      if (t.todoCompletionTime == null) return false;
      final date = DateTime(
        t.todoCompletionTime!.year,
        t.todoCompletionTime!.month,
        t.todoCompletionTime!.day,
      );
      return date == today;
    }).length;

    final weekCompleted = completedTodos
        .where(
          (t) =>
              t.todoCompletionTime != null &&
              t.todoCompletionTime!.isAfter(weekAgo),
        )
        .length;

    final completionRate = todos.isEmpty
        ? 0.0
        : (completedTodos.length / todos.length) * 100;

    final heatmap = _calculateHeatmap(completedTodos);
    final streakData = _calculateStreak(heatmap);
    final weeklyProgress = _calculateWeeklyProgress(completedTodos, weekAgo);
    final hourlyProgress = _calculateHourlyProgress(completedTodos);

    return StatisticsData(
      totalTodos: todos.length,
      completedTodos: completedTodos.length,
      completionRate: completionRate,
      completionHeatmap: heatmap,
      todayCompleted: todayCompleted,
      weekCompleted: weekCompleted,
      currentStreak: streakData['current']!,
      longestStreak: streakData['longest']!,
      weeklyProgress: weeklyProgress,
      hourlyProgress: hourlyProgress,
    );
  }

  static Map<DateTime, int> _calculateHeatmap(List<Todos> completedTodos) {
    final heatmap = <DateTime, int>{};
    final startDate = DateTime.now().subtract(const Duration(days: 365));

    for (var todo in completedTodos) {
      if (todo.todoCompletionTime != null &&
          todo.todoCompletionTime!.isAfter(startDate)) {
        final date = DateTime(
          todo.todoCompletionTime!.year,
          todo.todoCompletionTime!.month,
          todo.todoCompletionTime!.day,
        );
        heatmap[date] = (heatmap[date] ?? 0) + 1;
      }
    }

    return heatmap;
  }

  static Map<String, int> _calculateStreak(Map<DateTime, int> heatmap) {
    if (heatmap.isEmpty) return {'current': 0, 'longest': 0};

    final sortedDates = heatmap.keys.toList()..sort();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    for (var date in sortedDates) {
      if (lastDate == null) {
        tempStreak = 1;
      } else {
        final difference = date.difference(lastDate).inDays;
        if (difference == 1) {
          tempStreak++;
        } else {
          longestStreak = tempStreak > longestStreak
              ? tempStreak
              : longestStreak;
          tempStreak = 1;
        }
      }
      lastDate = date;
    }

    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    if (lastDate != null && todayDate.difference(lastDate).inDays <= 1) {
      currentStreak = tempStreak;
    }

    return {'current': currentStreak, 'longest': longestStreak};
  }

  static Map<String, int> _calculateWeeklyProgress(
    List<Todos> completedTodos,
    DateTime weekAgo,
  ) {
    final weeklyData = <String, int>{
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (var todo in completedTodos) {
      if (todo.todoCompletionTime != null) {
        final dayName = dayNames[todo.todoCompletionTime!.weekday - 1];
        weeklyData[dayName] = (weeklyData[dayName] ?? 0) + 1;
      }
    }

    return weeklyData;
  }

  static Map<int, int> _calculateHourlyProgress(List<Todos> completedTodos) {
    final hourlyData = {for (var i = 0; i < 24; i++) i: 0};

    for (var todo in completedTodos) {
      if (todo.todoCompletionTime != null) {
        hourlyData[todo.todoCompletionTime!.hour] =
            (hourlyData[todo.todoCompletionTime!.hour] ?? 0) + 1;
      }
    }

    return hourlyData;
  }
}
