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

    final completedTodos =
        todos.where((t) => t.status == TodoStatus.done).toList();

    final todayCompleted = completedTodos.where((t) {
      if (t.todoCompletionTime == null) return false;
      final completionDate = DateTime(
        t.todoCompletionTime!.year,
        t.todoCompletionTime!.month,
        t.todoCompletionTime!.day,
      );
      return completionDate == today;
    }).length;

    final weekCompleted = completedTodos
        .where((t) =>
            t.todoCompletionTime != null &&
            t.todoCompletionTime!.isAfter(weekAgo))
        .length;

    final completionRate =
        todos.isEmpty ? 0.0 : (completedTodos.length / todos.length) * 100;

    return StatisticsData(
      totalTodos: todos.length,
      completedTodos: completedTodos.length,
      completionRate: completionRate,
      completionHeatmap: _calculateHeatmap(completedTodos),
      todayCompleted: todayCompleted,
      weekCompleted: weekCompleted,
    );
  }

  static Map<DateTime, int> _calculateHeatmap(List<Todos> completedTodos) {
    final heatmap = <DateTime, int>{};
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));

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
}
