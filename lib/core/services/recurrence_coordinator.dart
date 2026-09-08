import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/caldav/caldav_sync_service.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Midnight rollover and reopen for recurring items / habit categories.
///
/// Day model: reminder time drives notifications; local midnight creates the
/// next clone or reopens a habit. Category habits apply only to items with
/// [RecurrenceFrequency.none]. Catch-up is safe on app open / resume / Workmanager.
class RecurrenceCoordinator {
  /// Creates a coordinator using [todoRepo] and optional notification/calendar.
  RecurrenceCoordinator({
    required this._todoRepo,
    required this._isar,
    this._notificationService,
    this._calendarSync,
    this._caldavSync,
  });

  final TodoRepository _todoRepo;
  final Isar _isar;
  final NotificationService? _notificationService;
  final DeviceCalendarSyncService? _calendarSync;
  final CalDavSyncService? _caldavSync;

  /// Runs midnight rollover (clone ensure + reopen) and returns changed count.
  ///
  /// Safe to call on app open / resume as catch-up when the background job
  /// missed local midnight.
  Future<int> runMidnightRollover({DateTime? now}) async {
    final today = RecurrenceService.calendarDay(now ?? DateTime.now());
    final todos = await _todoRepo.getAll();

    var count = 0;
    count += await _bumpStaleActiveClones(today, todos);
    count += await _spawnCloneOccurrences(today, todos);
    count += await _processCategoryHabits(today);
    count += await _resetTodoReopenHabits(today, todos);

    if (count > 0) {
      debugPrint('Recurrence midnight rollover changed $count todo(s)');
    }
    return count;
  }

  Future<int> _bumpStaleActiveClones(DateTime today, List<Todos> todos) async {
    var count = 0;
    for (final todo in todos) {
      await todo.task.load();
      if (todo.task.value?.archive == true) continue;
      if (!RecurrenceService.shouldBumpActiveCloneDue(
        todo: todo,
        today: today,
      )) {
        continue;
      }
      todo.todoCompletedTime = RecurrenceService.dueForOccurrenceDay(
        today,
        todo.recurrenceMinuteOfDay,
        fallbackTime: todo.todoCompletedTime,
      );
      await _persistScheduled(todo);
      count++;
    }
    return count;
  }

  Future<int> _spawnCloneOccurrences(DateTime today, List<Todos> todos) async {
    final activeFingerprints = <String>{};
    for (final todo in todos) {
      if (todo.status != TodoStatus.active) continue;
      if (!RecurrenceService.isRecurring(todo.recurrence)) continue;
      if (todo.recurrenceMode != RecurrenceMode.clone) continue;
      await todo.task.load();
      if (todo.task.value?.archive == true) continue;
      final taskId = todo.task.value?.id;
      if (taskId == null) continue;
      activeFingerprints.add(RecurrenceService.cloneSiblingKey(taskId, todo));
    }

    // Prefer the most recently completed done clone per fingerprint.
    final candidates = <String, Todos>{};
    for (final todo in todos) {
      if (!RecurrenceService.shouldSpawnCloneForToday(
        todo: todo,
        today: today,
      )) {
        continue;
      }
      await todo.parent.load();
      if (todo.parent.value != null) continue;
      await todo.task.load();
      final task = todo.task.value;
      if (task == null || task.archive) continue;
      final key = RecurrenceService.cloneSiblingKey(task.id, todo);
      if (activeFingerprints.contains(key)) continue;
      final existing = candidates[key];
      if (existing == null ||
          (todo.todoCompletionTime ?? todo.createdTime).isAfter(
            existing.todoCompletionTime ?? existing.createdTime,
          )) {
        candidates[key] = todo;
      }
    }

    var count = 0;
    var nextIndex = await _todoRepo.nextIndex();
    for (final todo in candidates.values) {
      await todo.task.load();
      final task = todo.task.value;
      if (task == null) continue;

      final clone = RecurrenceService.buildNextClone(
        todo,
        now: today,
        occurrenceDay: today,
      );
      final created = await _todoRepo.create(
        name: clone.name,
        description: clone.description,
        completedTime: clone.todoCompletedTime,
        fix: clone.fix,
        priority: clone.priority,
        tags: clone.tags,
        index: nextIndex++,
        task: task,
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

  /// Ensures dues for active category habits and reopens stale done ones.
  Future<int> _processCategoryHabits(DateTime today) async {
    final tasks = await _isar.tasks.where().findAll();
    var count = 0;

    for (final task in tasks) {
      if (task.archive) continue;
      if (!RecurrenceService.isRecurring(task.recurrence)) continue;

      final habitTodos = await _todoRepo.getByTaskId(task.id);
      for (final todo in habitTodos) {
        if (RecurrenceService.shouldEnsureCategoryHabitDue(
          todo: todo,
          task: task,
          today: today,
        )) {
          todo.todoCompletedTime = RecurrenceService.resolveActiveReminderDue(
            now: today,
            frequency: task.recurrence,
            weekdays: task.recurrenceWeekdays,
            minuteOfDay: task.recurrenceMinuteOfDay,
            fallbackTime: todo.todoCompletedTime ?? todo.createdTime,
          );
          await _persistScheduled(todo);
          count++;
          continue;
        }

        if (RecurrenceService.shouldResetCategoryHabit(
          todo: todo,
          task: task,
          today: today,
        )) {
          await _reopenTodo(
            todo,
            minuteOfDay: task.recurrenceMinuteOfDay,
            today: today,
          );
          count++;
        }
      }
    }
    return count;
  }

  Future<int> _resetTodoReopenHabits(DateTime today, List<Todos> todos) async {
    var count = 0;

    for (final todo in todos) {
      await todo.task.load();
      if (todo.task.value?.archive == true) continue;
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
    Todos todo, {
    required int? minuteOfDay,
    required DateTime today,
  }) async {
    final previousDue = todo.todoCompletedTime;
    todo.status = TodoStatus.active;
    todo.todoCompletionTime = null;
    todo.todoCompletedTime = RecurrenceService.dueForOccurrenceDay(
      today,
      minuteOfDay,
      fallbackTime: previousDue,
    );
    await _persistScheduled(todo);
  }

  Future<void> _persistScheduled(Todos todo) async {
    await _todoRepo.update(todo);
    await _scheduleOrCancel(todo);
    await _calendarSync?.ensureSynced(todo);
    await _caldavSync?.markDirty(todo);
  }

  Future<void> _scheduleOrCancel(Todos todo) async {
    if (todo.todoCompletedTime != null) {
      await _notificationService?.scheduleForTodo(todo);
    } else {
      await _notificationService?.cancel(todo.id);
    }
  }
}
