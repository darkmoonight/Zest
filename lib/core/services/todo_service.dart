import 'package:flutter/foundation.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/i18n/tr.dart';

/// Item CRUD, status changes, moves, and notification scheduling.
class TodoService {
  /// Creates a service with repository, notifications, and locale formatting.
  TodoService({
    required this._todoRepo,
    required this._notificationService,
    this._calendarSync,
    this._timeformat = AppConstants.defaultTimeformat,
    this._languageCode = AppConstants.defaultLanguageCode,
  });

  /// Persistence layer for item entities.
  final TodoRepository _todoRepo;

  /// Schedules and cancels item reminder notifications.
  final NotificationService _notificationService;

  /// Optional one-way export of deadlines to the device calendar.
  final DeviceCalendarSyncService? _calendarSync;

  /// User time format for parsing due-date strings.
  final String _timeformat;

  /// Language code used when parsing due-date strings.
  final String _languageCode;

  // ==================== CREATE ====================

  /// Creates a list item under [task] and schedules a reminder when a due time is set.
  Future<Todos> createTodo({
    required Tasks task,
    required String title,
    required String description,
    required String timeString,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    required int currentTodoCount,
    Todos? parent,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final date = _resolveDueDate(
      timeString: timeString,
      task: task,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    final todo = await _todoRepo.create(
      name: title,
      description: description,
      completedTime: date,
      fix: pinned,
      priority: priority,
      tags: tags,
      index: currentTodoCount,
      task: task,
      parent: parent,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    if (date != null) {
      await _notificationService.scheduleForTodo(todo);
    }
    await _calendarSync?.ensureSynced(todo);

    showSnackBar('todoCreate'.tr);
    return todo;
  }

  // ==================== UPDATE ====================

  /// Updates item fields and reschedules or cancels its reminder.
  Future<void> updateTodo({
    required Todos todo,
    required Tasks task,
    required String title,
    required String description,
    required String timeString,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  }) async {
    final date = _resolveDueDate(
      timeString: timeString,
      task: task,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    await _todoRepo.updateFields(
      todo: todo,
      name: title,
      description: description,
      completedTime: date,
      fix: pinned,
      priority: priority,
      tags: tags,
      task: task,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    if (date != null) {
      await _notificationService.reschedule(todo);
    } else {
      await _notificationService.cancel(todo.id);
    }
    await _calendarSync?.ensureSynced(todo);

    showSnackBar('updateTodo'.tr);
  }

  /// Persists [item] status and syncs its notification schedule.
  ///
  /// Recurring clones / reopens happen at local midnight via
  /// [RecurrenceCoordinator.runMidnightRollover], not on mark-done.
  Future<void> updateTodoStatus(Todos todo) async {
    await _todoRepo.update(todo);

    final completedTime = todo.todoCompletedTime;

    if (todo.status == TodoStatus.done || todo.status == TodoStatus.cancelled) {
      await _notificationService.cancel(todo.id);
    } else if (completedTime != null) {
      await _notificationService.scheduleForTodo(todo);
    } else {
      await _notificationService.cancel(todo.id);
    }
    await _calendarSync?.ensureSynced(todo);
  }

  /// Marks [item] done and cancels its reminder (notification action / handler).
  Future<void> markTodoAsDone(Todos todo) async {
    if (todo.status == TodoStatus.done) return;

    todo.status = TodoStatus.done;
    todo.todoCompletionTime = DateTime.now();
    await updateTodoStatus(todo);
  }

  /// Snoozes [item] by [settings.snoozeDuration] and reschedules its reminder.
  Future<void> snoozeTodo(Todos todo, Settings settings) async {
    final newTime = DateTime.now().add(
      Duration(minutes: settings.snoozeDuration),
    );
    todo.todoCompletedTime = newTime;
    await _todoRepo.update(todo);
    await _notificationService.snooze(todo, settings);
    await _calendarSync?.ensureSynced(todo);
  }

  /// Sets [item] and all subtasks to [status] and updates notifications.
  Future<void> updateStatusWithSubtasks(Todos todo, TodoStatus status) async {
    await _todoRepo.updateStatusWithSubtasks(parentTodo: todo, status: status);

    final allIds = await _collectSubtreeIds(todo);

    if (status.isCompleted) {
      await _notificationService.cancelBatch(allIds.toList());
      for (final id in allIds) {
        final todoItem = await _todoRepo.getById(id);
        if (todoItem != null) {
          await _calendarSync?.ensureSynced(todoItem);
        }
      }
    } else {
      for (final id in allIds) {
        final todoItem = await _todoRepo.getById(id);
        if (todoItem != null && todoItem.todoCompletedTime != null) {
          await _notificationService.scheduleForTodo(todoItem);
        }
        if (todoItem != null) {
          await _calendarSync?.ensureSynced(todoItem);
        }
      }
    }
  }

  // ==================== MOVE ====================

  /// Moves [items] and their subtrees to [task].
  Future<void> moveTodos({
    required List<Todos> todos,
    required Tasks task,
  }) async {
    if (todos.isEmpty) return;

    final todosCopy = List<Todos>.from(todos);
    final allIds = <int>{};

    for (final root in todosCopy) {
      final subtreeIds = await _collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _todoRepo.moveToTask(todoIds: allIds, task: task);
    showSnackBar('updateTodo'.tr);
  }

  /// Reparents [rootTodos] under [newParent], preserving nested subtrees.
  ///
  /// Only selected roots (not their descendants) are linked to [newParent].
  /// Descendant parent links inside each moved tree are kept. Rejects moves
  /// that would create a cycle ([newParent] inside a moved subtree).
  Future<void> moveTodosToParent({
    required List<Todos> rootTodos,
    required Todos? newParent,
  }) async {
    if (rootTodos.isEmpty) return;

    final rootTodosCopy = List<Todos>.from(rootTodos);
    final subtreeByRoot = <int, Set<int>>{};
    for (final root in rootTodosCopy) {
      subtreeByRoot[root.id] = await _collectSubtreeIds(root);
    }

    // If both an ancestor and descendant are selected, only move the ancestor.
    final effectiveRoots = rootTodosCopy.where((root) {
      return !rootTodosCopy.any(
        (other) =>
            other.id != root.id &&
            (subtreeByRoot[other.id]?.contains(root.id) ?? false),
      );
    }).toList();

    final rootIds = <int>{};
    final allIds = <int>{};
    for (final root in effectiveRoots) {
      rootIds.add(root.id);
      allIds.addAll(subtreeByRoot[root.id] ?? {root.id});
    }

    if (allIds.isEmpty) return;

    if (newParent != null && allIds.contains(newParent.id)) {
      debugPrint(
        'moveTodosToParent rejected: newParent ${newParent.id} is in moved subtree',
      );
      return;
    }

    await _todoRepo.moveToParent(
      rootIds: rootIds,
      subtreeIds: allIds,
      newParent: newParent,
      newTask: newParent?.task.value,
    );

    showSnackBar('updateTodo'.tr);
  }

  // ==================== DELETE ====================

  /// Deletes [items], their subtrees, and associated notifications.
  Future<void> deleteTodos(List<Todos> todos) async {
    if (todos.isEmpty) return;

    final todosCopy = List<Todos>.from(todos);
    final allIds = <int>{};

    for (final root in todosCopy) {
      final subtreeIds = await _collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _notificationService.cancelBatch(allIds.toList());
    for (final id in allIds) {
      final todoItem = await _todoRepo.getById(id);
      if (todoItem != null) {
        await _calendarSync?.removeSynced(todoItem);
      }
    }
    await _todoRepo.deleteBatch(allIds);

    showSnackBar('todoDelete'.tr);
  }

  // ==================== HELPERS ====================

  /// Resolves due from [timeString], item recurrence, or category habit reminder.
  ///
  /// Past recurring reminder times advance to the next valid occurrence
  /// instead of firing immediately.
  DateTime? _resolveDueDate({
    required String timeString,
    required Tasks task,
    required RecurrenceFrequency recurrence,
    required List<int> recurrenceWeekdays,
    required int? recurrenceMinuteOfDay,
  }) {
    final parsed = _parseDate(timeString);
    return RecurrenceService.resolveDueForTodoInTask(
      now: DateTime.now(),
      task: task,
      todoRecurrence: recurrence,
      todoWeekdays: recurrenceWeekdays,
      todoMinuteOfDay: recurrenceMinuteOfDay,
      baseDay: parsed,
      fallbackTime: parsed,
    );
  }

  /// Parses [timeString] using the configured format and language.
  DateTime? _parseDate(String timeString) => DateTimeFormatHelper.parseDateTime(
    timeString,
    timeformat: _timeformat,
    languageCode: _languageCode,
  );

  /// Collects ids for [root] and every descendant item.
  Future<Set<int>> _collectSubtreeIds(Todos root) async {
    final ids = <int>{};
    final stack = <Todos>[root];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (!ids.add(node.id)) continue;

      final children = await _todoRepo.getChildren(node.id);
      for (final child in children) {
        if (!ids.contains(child.id)) {
          stack.add(child);
        }
      }
    }

    return ids;
  }

  /// Returns whether [date1] and [date2] fall on the same calendar day.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // ==================== COUNTERS ====================

  /// Counts root-level items belonging to [task].
  int countForTask(Tasks task, List<Todos> allTodos) {
    return allTodos
        .where((t) => t.task.value?.id == task.id && t.parent.value == null)
        .length;
  }

  /// Counts completed root-level items belonging to [task].
  int countCompletedForTask(Tasks task, List<Todos> allTodos) {
    return allTodos
        .where(
          (t) =>
              t.task.value?.id == task.id &&
              t.status.isCompleted &&
              t.parent.value == null,
        )
        .length;
  }

  /// Counts root-level items in non-archived tasks.
  int countAll(List<Todos> allTodos) {
    return allTodos
        .where((t) => t.task.value?.archive == false && t.parent.value == null)
        .length;
  }

  /// Counts completed root-level items in non-archived tasks.
  int countAllCompleted(List<Todos> allTodos) {
    return allTodos
        .where(
          (t) =>
              t.task.value?.archive == false &&
              t.status.isCompleted &&
              t.parent.value == null,
        )
        .length;
  }

  /// Counts active root items due on [date].
  int countForCalendar(
    DateTime date,
    List<Todos> allTodos, {
    bool excludeArchivedCategories = true,
  }) {
    return allTodos.where((todo) {
      final completedTime = todo.todoCompletedTime;
      if (excludeArchivedCategories && todo.task.value?.archive != false) {
        return false;
      }
      return todo.status == TodoStatus.active &&
          completedTime != null &&
          todo.parent.value == null &&
          _isSameDay(date, completedTime);
    }).length;
  }

  /// Counts direct child items of [parent].
  int countForParent(Todos parent, List<Todos> allTodos) {
    return allTodos.where((t) => t.parent.value?.id == parent.id).length;
  }

  /// Counts completed direct child items of [parent].
  int countCompletedForParent(Todos parent, List<Todos> allTodos) {
    return allTodos
        .where((t) => t.parent.value?.id == parent.id && t.status.isCompleted)
        .length;
  }

  // ==================== FILTERS ====================

  /// Filters [allTodos] by status, search, and a single context scope.
  List<Todos> filterTodos({
    required List<Todos> allTodos,
    required TodoStatus? statusFilter,
    String searchQuery = '',
    DateTime? selectedDay,
    Tasks? task,
    Todos? parent,
    bool excludeArchivedCategories = false,
  }) {
    final contextCount = [
      selectedDay,
      task,
      parent,
    ].where((c) => c != null).length;

    if (contextCount > 1) {
      throw ArgumentError(
        'Specify only one context: selectedDay, task, or parent.',
      );
    }

    final isRootMode = contextCount == 0;
    final lowerQuery = searchQuery.trim().toLowerCase();

    return allTodos.where((todo) {
      if (statusFilter != null && todo.status != statusFilter) {
        return false;
      }

      if (lowerQuery.isNotEmpty) {
        final nameMatch = todo.name.toLowerCase().contains(lowerQuery);
        final descMatch = todo.description.toLowerCase().contains(lowerQuery);
        final tagsMatch = todo.tags.any(
          (tag) => tag.toLowerCase().contains(lowerQuery),
        );

        if (!nameMatch && !descMatch && !tagsMatch) return false;
      }

      if (isRootMode) {
        if (excludeArchivedCategories && todo.task.value?.archive != false) {
          return false;
        }
        return todo.parent.value == null;
      } else if (selectedDay != null) {
        final time = todo.todoCompletedTime;
        if (excludeArchivedCategories && todo.task.value?.archive != false) {
          return false;
        }
        // Match [countForCalendar]: root items only, inclusive calendar day.
        if (todo.parent.value != null) return false;
        if (time == null) return false;
        return _isSameDay(selectedDay, time);
      } else if (task != null) {
        return todo.task.value?.id == task.id && todo.parent.value == null;
      } else if (parent != null) {
        return todo.parent.value?.id == parent.id;
      }

      return false;
    }).toList();
  }
}
