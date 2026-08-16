import 'package:flutter/foundation.dart';
import 'package:zest/core/notifications/notification_i18n.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/i18n/tr.dart';

/// Schedules, snoozes, and cancels local item reminder notifications.
class NotificationService {
  /// Creates a service with an optional custom [NotificationShow] delegate.
  NotificationService({NotificationShow? notificationShow, this._settings})
    : _notificationShow = notificationShow ?? NotificationShow();

  /// Platform wrapper that shows and cancels local notifications.
  final NotificationShow _notificationShow;

  /// Default snooze/action labels source when callers omit [settings].
  final Settings? _settings;

  /// Schedules a reminder at [item.todoCompletedTime] for active items only.
  ///
  /// For recurring items (and category-habit children), a past due is moved to
  /// the next reminder instant via [RecurrenceService.nextReminderAfter]
  /// instead of firing immediately (`now + 1s`).
  ///
  /// Non-recurring past dues use `now + 1s` when [firePastDueImmediately] is
  /// true (single-item UX). Bulk paths pass false to skip and avoid floods.
  ///
  /// Returns false when scheduling throws; intentional skips return true.
  Future<bool> scheduleForTodo(
    Todos todo, {
    Settings? settings,
    bool firePastDueImmediately = true,
  }) async {
    final completedTime = todo.todoCompletedTime;

    if (completedTime == null || todo.status != TodoStatus.active) {
      return true;
    }

    final now = DateTime.now();

    try {
      DateTime? effectiveTime;
      if (completedTime.isAfter(now)) {
        effectiveTime = completedTime;
      } else {
        effectiveTime = await _resolvePastDueSchedule(
          todo: todo,
          completedTime: completedTime,
          now: now,
          firePastDueImmediately: firePastDueImmediately,
        );
        if (effectiveTime == null) return true;
      }

      await _notificationShow.showNotification(
        todo.id,
        todo.name,
        todo.description,
        effectiveTime,
        settings: settings ?? _settings,
        priority: todo.priority,
      );
      return true;
    } catch (e) {
      debugPrint('Error scheduling notification for todo ${todo.id}: $e');
      return false;
    }
  }

  /// Next fire time for a past-due active item, or null to skip scheduling.
  Future<DateTime?> _resolvePastDueSchedule({
    required Todos todo,
    required DateTime completedTime,
    required DateTime now,
    required bool firePastDueImmediately,
  }) async {
    if (RecurrenceService.isRecurring(todo.recurrence)) {
      return RecurrenceService.nextReminderAfter(
        now: now,
        frequency: todo.recurrence,
        weekdays: todo.recurrenceWeekdays,
        minuteOfDay: todo.recurrenceMinuteOfDay,
        fallbackTime: completedTime,
      );
    }

    if (todo.task.value == null) {
      try {
        await todo.task.load();
      } catch (e) {
        debugPrint('task.load failed for todo ${todo.id}: $e');
      }
    }
    final task = todo.task.value;
    if (task != null &&
        RecurrenceService.isCategoryHabitChild(todo: todo, task: task) &&
        task.recurrenceMinuteOfDay != null) {
      return RecurrenceService.nextReminderAfter(
        now: now,
        frequency: task.recurrence,
        weekdays: task.recurrenceWeekdays,
        minuteOfDay: task.recurrenceMinuteOfDay,
        fallbackTime: completedTime,
      );
    }

    if (firePastDueImmediately) {
      return now.add(const Duration(seconds: 1));
    }
    return null;
  }

  /// Schedules reminders for every item in [items] that has a due time.
  Future<void> scheduleForTask(List<Todos> todos) async {
    if (todos.isEmpty) return;

    final todosToSchedule = todos.where((todo) {
      return todo.todoCompletedTime != null;
    }).toList();

    for (final todo in todosToSchedule) {
      await scheduleForTodo(todo);
    }
  }

  /// Cancels the notification for [todoId].
  Future<void> cancel(int todoId) async {
    try {
      await _notificationShow.cancelNotification(todoId);
    } catch (e) {
      debugPrint('Error canceling notification for todo $todoId: $e');
    }
  }

  /// Cancels reminders for items in [items] that have a due time.
  Future<void> cancelForTask(List<Todos> todos) async {
    for (final todo in todos) {
      if (todo.todoCompletedTime != null) {
        await cancel(todo.id);
      }
    }
  }

  /// Cancels notifications for each id in [todoIds].
  Future<void> cancelBatch(List<int> todoIds) async {
    for (final id in todoIds) {
      await cancel(id);
    }
  }

  /// Cancels every pending local notification.
  Future<void> cancelAll() async {
    try {
      await _notificationShow.cancelAllNotifications();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }

  /// Replaces the existing reminder with an updated schedule.
  ///
  /// Returns false when scheduling fails after cancel.
  Future<bool> reschedule(
    Todos todo, {
    Settings? settings,
    bool firePastDueImmediately = true,
  }) async {
    await cancel(todo.id);
    return scheduleForTodo(
      todo,
      settings: settings,
      firePastDueImmediately: firePastDueImmediately,
    );
  }

  /// Re-schedules active reminders so action labels pick up current [settings].
  ///
  /// Bulk path: skips non-recurring past dues ([firePastDueImmediately] false).
  Future<void> rescheduleActiveReminders(
    Iterable<Todos> todos, {
    Settings? settings,
    bool firePastDueImmediately = false,
  }) async {
    for (final todo in todos) {
      if (todo.todoCompletedTime == null || todo.status != TodoStatus.active) {
        continue;
      }
      await reschedule(
        todo,
        settings: settings,
        firePastDueImmediately: firePastDueImmediately,
      );
    }
  }

  /// Delays [item]'s reminder by [settings.snoozeDuration] minutes.
  Future<void> snooze(Todos todo, Settings settings) async {
    final snoozeText = snoozeActionLabel(settings.snoozeDuration);

    await _notificationShow.snoozeNotification(
      todo.id,
      todo.name,
      todo.description,
      snoozeActionText: snoozeText,
      markDoneActionText: 'markAsDone'.tr,
      snoozeMinutes: settings.snoozeDuration,
      settings: settings,
      priority: todo.priority,
    );
  }
}
