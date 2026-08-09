import 'package:flutter/foundation.dart';
import 'package:zest/core/notifications/notification_i18n.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/i18n/tr.dart';

/// Schedules, snoozes, and cancels local todo reminder notifications.
class NotificationService {
  /// Creates a service with an optional custom [NotificationShow] delegate.
  NotificationService({NotificationShow? notificationShow, this._settings})
    : _notificationShow = notificationShow ?? NotificationShow();

  /// Platform wrapper that shows and cancels local notifications.
  final NotificationShow _notificationShow;

  /// Default snooze/action labels source when callers omit [settings].
  final Settings? _settings;

  /// Schedules a reminder at [todo.todoCompletedTime] for active todos only.
  ///
  /// For recurring todos, a past due is moved to the next reminder instant
  /// via [RecurrenceService.nextReminderAfter] instead of firing immediately
  /// (`now + 1s`). Non-recurring past dues still use the short delay so the
  /// user sees the notification.
  Future<void> scheduleForTodo(Todos todo, {Settings? settings}) async {
    final completedTime = todo.todoCompletedTime;

    if (completedTime == null || todo.status != TodoStatus.active) {
      return;
    }

    final now = DateTime.now();

    try {
      DateTime effectiveTime;
      if (completedTime.isAfter(now)) {
        effectiveTime = completedTime;
      } else if (RecurrenceService.isRecurring(todo.recurrence)) {
        final next = RecurrenceService.nextReminderAfter(
          now: now,
          frequency: todo.recurrence,
          weekdays: todo.recurrenceWeekdays,
          minuteOfDay: todo.recurrenceMinuteOfDay,
          fallbackTime: completedTime,
        );
        if (next == null) return;
        effectiveTime = next;
      } else {
        // Non-recurring past due: fire shortly so the user still sees it.
        effectiveTime = now.add(const Duration(seconds: 1));
      }

      await _notificationShow.showNotification(
        todo.id,
        todo.name,
        todo.description,
        effectiveTime,
        settings: settings ?? _settings,
        priority: todo.priority,
      );
    } catch (e) {
      debugPrint('Error scheduling notification for todo ${todo.id}: $e');
    }
  }

  /// Schedules reminders for every todo in [todos] that has a due time.
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
      debugPrint('Error canceling notification $todoId: $e');
    }
  }

  /// Cancels notifications for each id in [todoIds].
  Future<void> cancelBatch(List<int> todoIds) async {
    if (todoIds.isEmpty) return;

    for (final id in todoIds) {
      await cancel(id);
    }
  }

  /// Cancels reminders for todos in [todos] that have a scheduled time.
  Future<void> cancelForTask(List<Todos> todos) async {
    if (todos.isEmpty) return;

    final idsToCancel = todos
        .where((todo) => todo.todoCompletedTime != null)
        .map((todo) => todo.id)
        .toList();

    await cancelBatch(idsToCancel);
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
  Future<void> reschedule(Todos todo, {Settings? settings}) async {
    await cancel(todo.id);
    await scheduleForTodo(todo, settings: settings);
  }

  /// Re-schedules active reminders so action labels pick up current [settings].
  Future<void> rescheduleActiveReminders(
    Iterable<Todos> todos, {
    Settings? settings,
  }) async {
    for (final todo in todos) {
      if (todo.todoCompletedTime == null || todo.status != TodoStatus.active) {
        continue;
      }
      await reschedule(todo, settings: settings);
    }
  }

  /// Delays [todo]'s reminder by [settings.snoozeDuration] minutes.
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
