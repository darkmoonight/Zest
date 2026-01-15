import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/data/repositories/todo_repository.dart';
import 'package:zest/app/services/notification_service.dart';
import 'package:zest/app/utils/show_snack_bar.dart';
import 'package:zest/main.dart';

class TodoService {
  final TodoRepository _todoRepo;
  final NotificationService _notificationService;

  TodoService({
    required TodoRepository todoRepo,
    required NotificationService notificationService,
  }) : _todoRepo = todoRepo,
       _notificationService = notificationService;

  // ==================== CREATE ====================

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

    if (date != null && DateTime.now().isBefore(date)) {
      await _notificationService.scheduleForTodo(todo);
    }

    showSnackBar('todoCreate'.tr);
    return todo;
  }

  // ==================== UPDATE ====================

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
    final now = DateTime.now();

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

    if (date != null && now.isBefore(date)) {
      await _notificationService.reschedule(todo);
    } else {
      await _notificationService.cancel(todo.id);
    }

    showSnackBar('updateTodo'.tr);
  }

  Future<void> toggleDone(Todos todo, List<Todos> allTodos) async {
    await _setDoneSingle(todo, todo.done);
  }

  Future<void> _setDoneSingle(Todos todo, bool done) async {
    await _todoRepo.updateDone(todo: todo, done: done);

    final now = DateTime.now();
    final completedTime = todo.todoCompletedTime;

    if (completedTime != null && completedTime.isAfter(now)) {
      if (done) {
        await _notificationService.cancel(todo.id);
      } else {
        await _notificationService.scheduleForTodo(todo);
      }
    } else {
      await _notificationService.cancel(todo.id);
    }
  }

  // ==================== MOVE ====================

  Future<void> moveTodos({
    required List<Todos> todos,
    required Tasks task,
  }) async {
    if (todos.isEmpty) return;

    final allIds = <int>{};
    for (final root in todos) {
      final subtreeIds = _collectSubtreeIdsSync(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _todoRepo.moveToTask(todoIds: allIds, task: task);
    showSnackBar('updateTodo'.tr);
  }

  Future<void> moveTodosToParent({
    required List<Todos> rootTodos,
    required Todos? newParent,
  }) async {
    if (rootTodos.isEmpty) return;

    final allIds = <int>{};
    final newTask = newParent?.task.value;

    for (final root in rootTodos) {
      final subtreeIds = _collectSubtreeIdsSync(root);
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

  Future<void> deleteTodos(List<Todos> todos) async {
    if (todos.isEmpty) return;

    final allIds = <int>{};

    for (final root in todos) {
      final subtreeIds = _collectSubtreeIdsSync(root);
      allIds.addAll(subtreeIds);
    }

    if (allIds.isEmpty) return;

    await _notificationService.cancelBatch(allIds.toList());
    await _todoRepo.deleteBatch(allIds);

    showSnackBar('todoDelete'.tr);
  }

  // ==================== HELPERS ====================

  DateTime? _parseDate(String timeString) {
    if (timeString.isEmpty) return null;

    try {
      return timeformat.value == '12'
          ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(timeString)
          : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(timeString);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  Set<int> _collectSubtreeIdsSync(Todos root) {
    final ids = <int>{};
    final stack = <Todos>[root];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (!ids.add(node.id)) continue;

      final children = _todoRepo.getChildren(node.id);
      for (final child in children) {
        if (!ids.contains(child.id)) {
          stack.add(child);
        }
      }
    }

    return ids;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // ==================== COUNTERS ====================

  int countForTask(Tasks task, List<Todos> allTodos) {
    return allTodos
        .where((t) => t.task.value?.id == task.id && t.parent.value == null)
        .length;
  }

  int countCompletedForTask(Tasks task, List<Todos> allTodos) {
    return allTodos
        .where(
          (t) =>
              t.task.value?.id == task.id && t.done && t.parent.value == null,
        )
        .length;
  }

  int countAll(List<Todos> allTodos) {
    return allTodos
        .where((t) => t.task.value?.archive == false && t.parent.value == null)
        .length;
  }

  int countAllCompleted(List<Todos> allTodos) {
    return allTodos
        .where(
          (t) =>
              t.task.value?.archive == false &&
              t.done &&
              t.parent.value == null,
        )
        .length;
  }

  int countForCalendar(DateTime date, List<Todos> allTodos) {
    return allTodos.where((todo) {
      final completedTime = todo.todoCompletedTime;
      return !todo.done &&
          completedTime != null &&
          todo.task.value?.archive == false &&
          todo.parent.value == null &&
          _isSameDay(date, completedTime);
    }).length;
  }

  int countForParent(Todos parent, List<Todos> allTodos) {
    return allTodos.where((t) => t.parent.value?.id == parent.id).length;
  }

  int countCompletedForParent(Todos parent, List<Todos> allTodos) {
    return allTodos
        .where((t) => t.parent.value?.id == parent.id && t.done)
        .length;
  }

  // ==================== FILTERS ====================

  List<Todos> filterTodos({
    required List<Todos> allTodos,
    required bool done,
    String searchQuery = '',
    DateTime? selectedDay,
    Tasks? task,
    Todos? parent,
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
      if (todo.done != done) return false;

      if (lowerQuery.isNotEmpty) {
        final nameMatch = todo.name.toLowerCase().contains(lowerQuery);
        final descMatch = todo.description.toLowerCase().contains(lowerQuery);
        final tagsMatch = todo.tags.any(
          (tag) => tag.toLowerCase().contains(lowerQuery),
        );

        if (!nameMatch && !descMatch && !tagsMatch) return false;
      }

      if (isRootMode) {
        return todo.parent.value == null;
      } else if (selectedDay != null) {
        final time = todo.todoCompletedTime;
        if (todo.task.value?.archive == true || time == null) return false;

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
