import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/statistics_service.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    isar = await openTestIsar();
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('empty database returns zeroed statistics', () async {
    final stats = await StatisticsService.calculateStatistics(isar);

    expect(stats.totalTodos, 0);
    expect(stats.completedTodos, 0);
    expect(stats.completionRate, 0);
    expect(stats.currentStreak, 0);
    expect(stats.longestStreak, 0);
    expect(stats.todayCompleted, 0);
    expect(stats.weekCompleted, 0);
  });

  test('calculates completion rate and today count', () async {
    final task = await createTestTask(isar);
    final now = DateTime.now();

    await createTestTodo(isar, task: task, name: 'Active');
    await createTestTodo(
      isar,
      task: task,
      name: 'Done today',
      status: TodoStatus.done,
      completionTime: now,
    );
    await createTestTodo(
      isar,
      task: task,
      name: 'Done yesterday',
      status: TodoStatus.done,
      completionTime: now.subtract(const Duration(days: 1)),
    );

    final stats = await StatisticsService.calculateStatistics(isar);

    expect(stats.totalTodos, 3);
    expect(stats.completedTodos, 2);
    expect(stats.completionRate, closeTo(66.67, 0.1));
    expect(stats.todayCompleted, 1);
    expect(stats.weekCompleted, greaterThanOrEqualTo(1));
  });

  test('streak counts consecutive completion days', () async {
    final task = await createTestTask(isar);
    final today = DateTime.now();

    for (var offset = 0; offset < 3; offset++) {
      await createTestTodo(
        isar,
        task: task,
        name: 'Done $offset',
        status: TodoStatus.done,
        completionTime: DateTime(
          today.year,
          today.month,
          today.day,
        ).subtract(Duration(days: offset)),
      );
    }

    final stats = await StatisticsService.calculateStatistics(isar);

    expect(stats.currentStreak, greaterThanOrEqualTo(1));
    expect(stats.longestStreak, greaterThanOrEqualTo(3));
    expect(stats.completionHeatmap, isNotEmpty);
  });

  test('populates weekly and hourly progress buckets', () async {
    final task = await createTestTask(isar);
    final completionTime = DateTime.now();

    await createTestTodo(
      isar,
      task: task,
      name: 'Recent afternoon',
      status: TodoStatus.done,
      completionTime: completionTime,
    );

    final stats = await StatisticsService.calculateStatistics(isar);

    expect(
      stats.weeklyProgress[completionTime.weekday],
      greaterThanOrEqualTo(1),
    );
    expect(stats.hourlyProgress[completionTime.hour], greaterThanOrEqualTo(1));
  });

  test('weekly progress ignores completions older than seven days', () async {
    final task = await createTestTask(isar);
    final old = DateTime.now().subtract(const Duration(days: 20));

    await createTestTodo(
      isar,
      task: task,
      name: 'Old Monday',
      status: TodoStatus.done,
      completionTime: old,
    );

    final stats = await StatisticsService.calculateStatistics(isar);

    expect(stats.weeklyProgress.values.every((count) => count == 0), isTrue);
    expect(stats.hourlyProgress[old.hour], greaterThanOrEqualTo(1));
  });

  test('streak breaks after a gap day', () async {
    final task = await createTestTask(isar);
    final today = DateTime.now();

    await createTestTodo(
      isar,
      task: task,
      name: 'Today',
      status: TodoStatus.done,
      completionTime: DateTime(today.year, today.month, today.day),
    );
    await createTestTodo(
      isar,
      task: task,
      name: 'Three days ago',
      status: TodoStatus.done,
      completionTime: DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(const Duration(days: 3)),
    );

    final stats = await StatisticsService.calculateStatistics(isar);

    expect(stats.longestStreak, 1);
    expect(stats.currentStreak, lessThanOrEqualTo(1));
  });

  test('excludes todos from archived categories by default', () async {
    final active = await createTestTask(isar, title: 'Active');
    final archived = await createTestTask(
      isar,
      title: 'Archived',
      archive: true,
    );

    await createTestTodo(isar, task: active, name: 'Keep');
    await createTestTodo(isar, task: archived, name: 'Skip');

    final stats = await StatisticsService.calculateStatistics(isar);

    expect(stats.totalTodos, 1);
  });

  test('includes archived categories when requested', () async {
    final active = await createTestTask(isar, title: 'Active');
    final archived = await createTestTask(
      isar,
      title: 'Archived',
      archive: true,
    );

    await createTestTodo(isar, task: active, name: 'Keep');
    await createTestTodo(isar, task: archived, name: 'Include');

    final stats = await StatisticsService.calculateStatistics(
      isar,
      includeArchivedCategories: true,
    );

    expect(stats.totalTodos, 2);
  });
}
