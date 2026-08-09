import 'package:flutter/material.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/i18n/tr.dart';

/// Category (task list) CRUD, archive, and notification cleanup.
class TaskService {
  /// Creates a service with task/todo repositories and notifications.
  TaskService({
    required this._taskRepo,
    required this._todoRepo,
    required this._notificationService,
    this._calendarSync,
  });

  /// Persistence layer for task (category) entities.
  final TaskRepository _taskRepo;

  /// Persistence layer for todo entities.
  final TodoRepository _todoRepo;

  /// Schedules and cancels todo reminder notifications.
  final NotificationService _notificationService;

  /// Optional device-calendar cleanup when todos are deleted with a category.
  final DeviceCalendarSyncService? _calendarSync;

  // ==================== CREATE ====================

  /// Creates a task when [title] is unique; shows an error snackbar otherwise.
  Future<Tasks?> createTask({
    required String title,
    required String description,
    required Color color,
    required int currentTaskCount,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    if (await _taskRepo.existsByTitle(title)) {
      showSnackBar('duplicateCategory'.tr, isError: true);
      return null;
    }

    final task = await _taskRepo.create(
      title: title,
      description: description,
      color: color,
      index: currentTaskCount,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    showSnackBar('createCategory'.tr);
    return task;
  }

  // ==================== UPDATE ====================

  /// Updates task fields and syncs category-habit dues on eligible children.
  ///
  /// Active todos without their own recurrence get [Tasks.recurrenceMinuteOfDay]
  /// written to [Todos.todoCompletedTime] and are rescheduled (or cancelled).
  Future<void> updateTask({
    required Tasks task,
    required String title,
    required String description,
    required Color color,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    await _taskRepo.updateFields(
      task: task,
      title: title,
      description: description,
      color: color,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    // Refresh in-memory fields used by due resolution below.
    task.recurrence = recurrence;
    task.recurrenceWeekdays = recurrenceWeekdays;
    task.recurrenceMode = recurrenceMode;
    task.recurrenceMinuteOfDay = recurrenceMinuteOfDay;

    await _syncCategoryHabitDues(task);

    showSnackBar('editCategory'.tr);
  }

  /// Stamps due + notifications for active children without their own recurrence.
  Future<void> _syncCategoryHabitDues(Tasks task) async {
    if (!RecurrenceService.isRecurring(task.recurrence)) return;

    final todos = await _todoRepo.getByTaskId(task.id);
    final now = DateTime.now();

    for (final todo in todos) {
      if (!RecurrenceService.isCategoryHabitChild(todo: todo, task: task)) {
        continue;
      }

      final due = RecurrenceService.resolveDueForTodo(
        todo: todo,
        task: task,
        now: now,
      );

      todo.todoCompletedTime = due;
      await _todoRepo.update(todo);

      if (due != null) {
        await _notificationService.reschedule(todo);
      } else {
        await _notificationService.cancel(todo.id);
      }
      await _calendarSync?.ensureSynced(todo);
    }
  }

  /// Archives [tasks], cancels their todo reminders, and persists archive state.
  Future<void> archiveTasks(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    final tasksCopy = List<Tasks>.from(tasks);
    final allTodos = await _collectTodosForTasks(tasksCopy);

    await _notificationService.cancelForTask(allTodos);
    await _taskRepo.updateArchiveStatusBatch(tasksCopy, true);

    showSnackBar('categoryArchive'.tr);
  }

  /// Unarchives [tasks], reschedules todo reminders, and persists state.
  Future<void> unarchiveTasks(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    final tasksCopy = List<Tasks>.from(tasks);
    final allTodos = await _collectTodosForTasks(tasksCopy);

    await _notificationService.scheduleForTask(allTodos);
    await _taskRepo.updateArchiveStatusBatch(tasksCopy, false);

    showSnackBar('noCategoryArchive'.tr);
  }

  Future<List<Todos>> _collectTodosForTasks(List<Tasks> tasks) async {
    final allTodos = <Todos>[];
    for (final task in tasks) {
      allTodos.addAll(await _todoRepo.getByTaskId(task.id));
    }
    return allTodos;
  }

  // ==================== DELETE ====================

  /// Deletes [tasks], their todos, and associated notifications.
  Future<void> deleteTasks(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    final tasksCopy = List<Tasks>.from(tasks);

    for (final task in tasksCopy) {
      final todos = await _todoRepo.getByTaskId(task.id);
      await _notificationService.cancelForTask(todos);
      await _deleteAllTodosForTask(todos);
      await _taskRepo.delete(task);
    }

    showSnackBar('categoryDelete'.tr);
  }

  /// Deletes every todo in [todos] including descendant subtrees.
  Future<void> _deleteAllTodosForTask(List<Todos> todos) async {
    if (todos.isEmpty) return;

    final todosCopy = List<Todos>.from(todos);
    final allIds = <int>{};

    for (final root in todosCopy) {
      final subtreeIds = await _collectSubtreeIds(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isNotEmpty) {
      for (final id in allIds) {
        final todoItem = await _todoRepo.getById(id);
        if (todoItem != null) {
          await _calendarSync?.removeSynced(todoItem);
        }
      }
      await _todoRepo.deleteBatch(allIds);
    }
  }

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

  // ==================== REORDER ====================

  /// Reorders [allTasks] to match the order of [filteredTasks].
  Future<void> reorderTasks({
    required List<Tasks> allTasks,
    required List<Tasks> filteredTasks,
  }) async {
    if (filteredTasks.isEmpty) return;

    final filteredIds = filteredTasks.map((t) => t.id).toSet();
    int position = 0;

    for (
      int i = 0;
      i < allTasks.length && position < filteredTasks.length;
      i++
    ) {
      if (filteredIds.contains(allTasks[i].id)) {
        allTasks[i] = filteredTasks[position++];
      }
    }

    await _taskRepo.updateIndexes(allTasks);
  }

  // ==================== FILTERS ====================

  /// Filters [tasks] by archive state and optional [searchQuery].
  List<Tasks> filterTasks({
    required List<Tasks> tasks,
    required bool archived,
    String searchQuery = '',
  }) {
    final query = searchQuery.trim().toLowerCase();

    return tasks.where((task) {
      if (task.archive != archived) return false;
      if (query.isEmpty) return true;

      final titleMatch = task.title.toLowerCase().contains(query);
      final descMatch = task.description.toLowerCase().contains(query);

      return titleMatch || descMatch;
    }).toList();
  }
}
