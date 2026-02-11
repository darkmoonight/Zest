import 'package:flutter/foundation.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/utils/notification.dart';
import 'package:zest/main.dart';

class NotificationService {
  final _notificationShow = NotificationShow();

  // ==================== SCHEDULE ====================

  Future<void> scheduleForTodo(Todos todo) async {
    final completedTime = todo.todoCompletedTime;

    if (completedTime == null || !DateTime.now().isBefore(completedTime)) {
      return;
    }

    try {
      await _notificationShow.showNotification(
        todo.id,
        todo.name,
        todo.description,
        completedTime,
      );
    } catch (e) {
      debugPrint('Error scheduling notification for todo ${todo.id}: $e');
    }
  }

  Future<void> scheduleForTask(List<Todos> todos) async {
    if (todos.isEmpty) return;

    final now = DateTime.now();
    final todosToSchedule = todos.where((todo) {
      final completedTime = todo.todoCompletedTime;
      return completedTime != null && completedTime.isAfter(now);
    }).toList();

    for (final todo in todosToSchedule) {
      await scheduleForTodo(todo);
    }
  }

  // ==================== CANCEL ====================

  Future<void> cancel(int todoId) async {
    try {
      await flutterLocalNotificationsPlugin?.cancel(id: todoId);
    } catch (e) {
      debugPrint('Error canceling notification $todoId: $e');
    }
  }

  Future<void> cancelBatch(List<int> todoIds) async {
    if (todoIds.isEmpty) return;

    for (final id in todoIds) {
      await cancel(id);
    }
  }

  Future<void> cancelForTask(List<Todos> todos) async {
    if (todos.isEmpty) return;

    final now = DateTime.now();
    final idsToCancel = todos
        .where((todo) {
          final completedTime = todo.todoCompletedTime;
          return completedTime != null && completedTime.isAfter(now);
        })
        .map((todo) => todo.id)
        .toList();

    await cancelBatch(idsToCancel);
  }

  Future<void> cancelAll() async {
    try {
      await flutterLocalNotificationsPlugin?.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  // ==================== RESCHEDULE ====================

  Future<void> reschedule(Todos todo) async {
    await cancel(todo.id);
    await scheduleForTodo(todo);
  }
}
