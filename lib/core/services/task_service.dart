import 'package:flutter/material.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
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
    );

    showSnackBar('createCategory'.tr);
    return task;
  }

  // ==================== UPDATE ====================

  /// Updates task title, description, and color.
  Future<void> updateTask({
    required Tasks task,
    required String title,
    required String description,
    required Color color,
  }) async {
    await _taskRepo.updateFields(
      task: task,
      title: title,
      description: description,
      color: color,
    );

    showSnackBar('editCategory'.tr);
  }

  /// Archives [tasks], cancels their todo reminders, and persists archive state.
  Future<void> archiveTasks(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    final tasksCopy = List<Tasks>.from(tasks);

    final allTodos = <Todos>[];
    for (final task in tasksCopy) {
      final todos = await _todoRepo.getByTaskId(task.id);
      allTodos.addAll(todos);
    }

    await _notificationService.cancelForTask(allTodos);
    await _taskRepo.updateArchiveStatusBatch(tasksCopy, true);

    showSnackBar('categoryArchive'.tr);
  }

  /// Unarchives [tasks], reschedules todo reminders, and persists state.
  Future<void> unarchiveTasks(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    final tasksCopy = List<Tasks>.from(tasks);

    final allTodos = <Todos>[];
    for (final task in tasksCopy) {
      final todos = await _todoRepo.getByTaskId(task.id);
      allTodos.addAll(todos);
    }
    await _notificationService.scheduleForTask(allTodos);
    await _taskRepo.updateArchiveStatusBatch(tasksCopy, false);

    showSnackBar('noCategoryArchive'.tr);
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
