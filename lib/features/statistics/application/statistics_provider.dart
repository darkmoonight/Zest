import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/statistics_service.dart';
import 'package:zest/features/statistics/presentation/models/statistics_data.dart';
import 'package:zest/features/tasks/application/tasks_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

/// Recomputes statistics when todos, tasks, or the database revision changes.
final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  ref.watch(todosNotifierProvider);
  ref.watch(tasksNotifierProvider);

  final isar = ref.watch(isarProvider);
  return StatisticsService.calculateStatistics(isar);
});
