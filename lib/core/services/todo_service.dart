import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/i18n/tr.dart';

/// Todo CRUD, status changes, moves, and notification scheduling.
class TodoService {
  /// Creates a service with repository, notifications, and locale formatting.
  TodoService({
    required this._todoRepo,
    required this._notificationService,
    this._calendarSync,
    this._timeformat = AppConstants.defaultTimeformat,
    this._languageCode = AppConstants.defaultLanguageCode,
  });

  /// Persistence layer for todo entities.
  final TodoRepository _todoRepo;

  /// Schedules and cancels todo reminder notifications.
  final NotificationService _notificationService;

  /// Optional one-way export of deadlines to the device calendar.
  final DeviceCalendarSyncService? _calendarSync;

  /// User time format for parsing due-date strings.
  final String _timeformat;

  /// Language code used when parsing due-date strings.
  final String _languageCode;

  // ==================== CREATE ====================

  /// Creates a todo under [task] and schedules a reminder when a due time is set.
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
  }) async {
    final date = _parseDate(timeString);

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
    );

    if (date != null) {
      await _notificationService.scheduleForTodo(todo);
    }
    await _calendarSync?.ensureSynced(todo);

    showSnackBar('todoCreate'.tr);
    return todo;
  }

  // ==================== UPDATE ====================

  /// Updates todo fields and reschedules or cancels its reminder.
  Future<void> updateTodo({
    required Todos todo,
    required Tasks task,
    required String title,
    required String description,
    required String timeString,
    required bool pinned,
    required Priority priority,
    required List<String> tags,
  }) async {
    final date = _parseDate(timeString);

    await _todoRepo.updateFields(
      todo: todo,
      name: title,
      description: description,
      completedTime: date,
      fix: pinned,
      priority: priority,
      tags: tags,
      task: task,
    );

    if (date != null) {
      await _notificationService.reschedule(todo);
    } else {
      await _notificationService.cancel(todo.id);
    }
    await _calendarSync?.ensureSynced(todo);

    showSnackBar('updateTodo'.tr);
  }

  /// Persists [todo] status and syncs its notification schedule.
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

  /// Marks [todo] done and cancels its reminder (notification action / handler).
  Future<void> markTodoAsDone(Todos todo) async {
    if (todo.status == TodoStatus.done) return;

    todo.status = TodoStatus.done;
    todo.todoCompletionTime = DateTime.now();
    await updateTodoStatus(todo);
  }

  /// Snoozes [todo] by [settings.snoozeDuration] and reschedules its reminder.
  Future<void> snoozeTodo(Todos todo, Settings settings) async {
    final newTime = DateTime.now().add(
      Duration(minutes: settings.snoozeDuration),
    );
    todo.todoCompletedTime = newTime;
    await _todoRepo.update(todo);
    await _notificationService.snooze(todo, settings);
    await _calendarSync?.ensureSynced(todo);
  }

  /// Sets [todo] and all subtasks to [status] and updates notifications.
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

  /// Moves [todos] and their subtrees to [task].
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

  /// Reparents [rootTodos] and their subtrees under [newParent].
  Future<void> moveTodosToParent({
    required List<Todos> rootTodos,
    required Todos? newParent,
  }) async {
    if (rootTodos.isEmpty) return;

    final rootTodosCopy = List<Todos>.from(rootTodos);
    final allIds = <int>{};
    final newTask = newParent?.task.value;

    for (final root in rootTodosCopy) {
      final subtreeIds = await _collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _todoRepo.moveToParent(
      todoIds: allIds,
      newParent: newParent,
      newTask: newTask,
    );

    showSnackBar('updateTodo'.tr);
  }

  // ==================== DELETE ====================

  /// Deletes [todos], their subtrees, and associated notifications.
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

  /// Parses [timeString] using the configured format and language.
  DateTime? _parseDate(String timeString) => DateTimeFormatHelper.parseDateTime(
    timeString,
    timeformat: _timeformat,
    languageCode: _languageCode,
  );

  /// Collects ids for [root] and every descendant todo.
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

  /// Counts root-level todos belonging to [task].
  int countForTask(Tasks task, List<Todos> allTodos) {
    return allTodos
        .where((t) => t.task.value?.id == task.id && t.parent.value == null)
        .length;
  }

  /// Counts completed root-level todos belonging to [task].
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

  /// Counts root-level todos in non-archived tasks.
  int countAll(List<Todos> allTodos) {
    return allTodos
        .where((t) => t.task.value?.archive == false && t.parent.value == null)
        .length;
  }

  /// Counts completed root-level todos in non-archived tasks.
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

  /// Counts active root todos due on [date].
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

  /// Counts direct child todos of [parent].
  int countForParent(Todos parent, List<Todos> allTodos) {
    return allTodos.where((t) => t.parent.value?.id == parent.id).length;
  }

  /// Counts completed direct child todos of [parent].
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
        if (time == null) return false;

        final startOfDay = DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
        );
        final endOfDay = startOfDay.add(const Duration(days: 1));

        return time.isAfter(startOfDay) && time.isBefore(endOfDay);
      } else if (task != null) {
        return todo.task.value?.id == task.id && todo.parent.value == null;
      } else if (parent != null) {
        return todo.parent.value?.id == parent.id;
      }

      return false;
    }).toList();
  }
}
