import 'package:flutter/foundation.dart' hide Category;
import 'package:zest/core/caldav/caldav_sync_service.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/domain/repositories/todo_repository.dart';

/// Midnight rollover and reopen for recurring items / habit categories.
class RecurrenceCoordinator {
  /// Creates a coordinator using repositories and optional side-effect services.
  RecurrenceCoordinator({
    required this._todoRepo,
    required this._categoryRepo,
    this._notificationService,
    this._calendarSync,
    this._caldavSync,
  });

  final TodoRepositoryPort _todoRepo;
  final CategoryRepositoryPort _categoryRepo;
  final NotificationService? _notificationService;
  final DeviceCalendarSyncService? _calendarSync;
  final CalDavSyncService? _caldavSync;

  /// Runs midnight rollover (clone ensure + reopen) and returns changed count.
  Future<int> runMidnightRollover({DateTime? now}) async {
    final today = RecurrenceService.calendarDay(now ?? DateTime.now());
    final todos = await _todoRepo.getAll();
    final categories = await _categoryRepo.getAll();
    final categoriesById = {for (final c in categories) c.id: c};
    final archivedIds = {
      for (final c in categories)
        if (c.archive) c.id,
    };

    var count = 0;
    count += await _bumpStaleActiveClones(today, todos, archivedIds);
    count += await _spawnCloneOccurrences(today, todos, categoriesById);
    count += await _processCategoryHabits(today, categories);
    count += await _resetTodoReopenHabits(today, todos, archivedIds);

    if (count > 0) {
      debugPrint('Recurrence midnight rollover changed $count todo(s)');
    }
    return count;
  }

  Future<int> _bumpStaleActiveClones(
    DateTime today,
    List<Todo> todos,
    Set<int> archivedIds,
  ) async {
    var count = 0;
    for (final todo in todos) {
      if (todo.categoryId != null && archivedIds.contains(todo.categoryId)) {
        continue;
      }
      if (!RecurrenceService.shouldBumpActiveCloneDue(
        todo: todo,
        today: today,
      )) {
        continue;
      }
      final updated = todo.copyWith(
        dueAt: RecurrenceService.dueForOccurrenceDay(
          today,
          todo.recurrenceMinuteOfDay,
          fallbackTime: todo.dueAt,
        ),
      );
      await _persistScheduled(updated);
      count++;
    }
    return count;
  }

  Future<int> _spawnCloneOccurrences(
    DateTime today,
    List<Todo> todos,
    Map<int, Category> categoriesById,
  ) async {
    final activeFingerprints = <String>{};
    for (final todo in todos) {
      if (todo.status != TodoStatus.active) continue;
      if (!RecurrenceService.isRecurring(todo.recurrence)) continue;
      if (todo.recurrenceMode != RecurrenceMode.clone) continue;
      final categoryId = todo.categoryId;
      if (categoryId == null) continue;
      final category = categoriesById[categoryId];
      if (category == null || category.archive) continue;
      activeFingerprints.add(
        RecurrenceService.cloneSiblingKey(categoryId, todo),
      );
    }

    final candidates = <String, Todo>{};
    for (final todo in todos) {
      if (!RecurrenceService.shouldSpawnCloneForToday(
        todo: todo,
        today: today,
      )) {
        continue;
      }
      if (todo.parentId != null) continue;
      final categoryId = todo.categoryId;
      if (categoryId == null) continue;
      final category = categoriesById[categoryId];
      if (category == null || category.archive) continue;
      final key = RecurrenceService.cloneSiblingKey(categoryId, todo);
      if (activeFingerprints.contains(key)) continue;
      final existing = candidates[key];
      if (existing == null ||
          (todo.completedAt ?? todo.createdAt).isAfter(
            existing.completedAt ?? existing.createdAt,
          )) {
        candidates[key] = todo;
      }
    }

    var count = 0;
    var nextIndex = await _todoRepo.nextIndex();
    for (final todo in candidates.values) {
      final categoryId = todo.categoryId;
      if (categoryId == null) continue;

      final clone = RecurrenceService.buildNextClone(
        todo,
        now: today,
        occurrenceDay: today,
      );
      final created = await _todoRepo.create(
        name: clone.name,
        description: clone.description,
        completedTime: clone.dueAt,
        fix: clone.fix,
        priority: clone.priority,
        tags: clone.tags,
        index: nextIndex++,
        categoryId: categoryId,
        recurrence: clone.recurrence,
        recurrenceWeekdays: clone.recurrenceWeekdays,
        recurrenceMode: clone.recurrenceMode,
        recurrenceMinuteOfDay: clone.recurrenceMinuteOfDay,
      );
      await _scheduleOrCancel(created);
      await _calendarSync?.ensureSynced(created);
      await _caldavSync?.markDirty(created);
      count++;
    }
    return count;
  }

  Future<int> _processCategoryHabits(
    DateTime today,
    List<Category> categories,
  ) async {
    var count = 0;

    for (final category in categories) {
      if (category.archive) continue;
      if (!RecurrenceService.isRecurring(category.recurrence)) continue;

      final habitTodos = await _todoRepo.getByCategoryId(category.id);
      for (final todo in habitTodos) {
        if (RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          category: category,
          today: today,
        )) {
          final updated = todo.copyWith(
            dueAt: RecurrenceService.resolveActiveReminderDue(
              now: today,
              frequency: category.recurrence,
              weekdays: category.recurrenceWeekdays,
              minuteOfDay: category.recurrenceMinuteOfDay,
              fallbackTime: todo.dueAt ?? todo.createdAt,
            ),
          );
          await _persistScheduled(updated);
          count++;
          continue;
        }

        if (RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          category: category,
          today: today,
        )) {
          await _reopenTodo(
            todo,
            minuteOfDay: category.recurrenceMinuteOfDay,
            today: today,
          );
          count++;
        }
      }
    }
    return count;
  }

  Future<int> _resetTodoReopenHabits(
    DateTime today,
    List<Todo> todos,
    Set<int> archivedIds,
  ) async {
    var count = 0;

    for (final todo in todos) {
      if (todo.categoryId != null && archivedIds.contains(todo.categoryId)) {
        continue;
      }
      if (!RecurrenceService.shouldResetTodoHabit(todo: todo, today: today)) {
        continue;
      }

      await _reopenTodo(
        todo,
        minuteOfDay: todo.recurrenceMinuteOfDay,
        today: today,
      );
      count++;
    }
    return count;
  }

  Future<void> _reopenTodo(
    Todo todo, {
    required int? minuteOfDay,
    required DateTime today,
  }) async {
    final previousDue = todo.dueAt;
    final updated = todo.copyWith(
      status: TodoStatus.active,
      clearCompletedAt: true,
      dueAt: RecurrenceService.dueForOccurrenceDay(
        today,
        minuteOfDay,
        fallbackTime: previousDue,
      ),
    );
    await _persistScheduled(updated);
  }

  Future<void> _persistScheduled(Todo todo) async {
    await _todoRepo.update(todo);
    await _scheduleOrCancel(todo);
    await _calendarSync?.ensureSynced(todo);
    await _caldavSync?.markDirty(todo);
  }

  Future<void> _scheduleOrCancel(Todo todo) async {
    if (todo.dueAt != null) {
      await _notificationService?.scheduleForTodo(todo);
    } else {
      await _notificationService?.cancel(todo.id);
    }
  }
}
