import 'package:zest/core/utils/app_log.dart';
import 'package:zest/core/notifications/notification_i18n.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/i18n/tr.dart';

/// Schedules, snoozes, and cancels local item reminder notifications.
class NotificationService {
  /// Creates a service with an optional custom [NotificationShow] delegate.
  NotificationService({
    NotificationShow? notificationShow,
    this._settings,
    this._categoryRepo,
  }) : _notificationShow = notificationShow ?? NotificationShow();

  /// Platform wrapper that shows and cancels local notifications.
  final NotificationShow _notificationShow;

  /// Default snooze/action labels source when callers omit [settings].
  final AppSettings? _settings;

  /// Optional category lookup for habit-based past-due scheduling.
  final CategoryRepositoryPort? _categoryRepo;

  /// Schedules a reminder at [todo.dueAt] for active items only.
  Future<bool> scheduleForTodo(
    Todo todo, {
    AppSettings? settings,
    Category? category,
    bool firePastDueImmediately = true,
  }) async {
    final completedTime = todo.dueAt;

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
          category: category,
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
      AppLog.d('Error scheduling notification for todo ${todo.id}: $e');
      return false;
    }
  }

  /// Next fire time for a past-due active item, or null to skip scheduling.
  Future<DateTime?> _resolvePastDueSchedule({
    required Todo todo,
    required Category? category,
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

    var resolvedCategory = category;
    if (resolvedCategory == null && todo.categoryId != null) {
      resolvedCategory = await _categoryRepo?.getById(todo.categoryId!);
    }
    if (resolvedCategory != null &&
        RecurrenceService.isCategoryHabitChild(
          todo: todo,
          category: resolvedCategory,
        ) &&
        resolvedCategory.recurrenceMinuteOfDay != null) {
      return RecurrenceService.nextReminderAfter(
        now: now,
        frequency: resolvedCategory.recurrence,
        weekdays: resolvedCategory.recurrenceWeekdays,
        minuteOfDay: resolvedCategory.recurrenceMinuteOfDay,
        fallbackTime: completedTime,
      );
    }

    if (firePastDueImmediately) {
      return now.add(const Duration(seconds: 1));
    }
    return null;
  }

  /// Schedules reminders for every item in [todos] that has a due time.
  Future<void> scheduleForTask(List<Todo> todos) async {
    if (todos.isEmpty) return;

    final todosToSchedule = todos.where((todo) {
      return todo.dueAt != null;
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
      AppLog.d('Error canceling notification for todo $todoId: $e');
    }
  }

  /// Cancels reminders for items in [todos] that have a due time.
  Future<void> cancelForTask(List<Todo> todos) async {
    for (final todo in todos) {
      if (todo.dueAt != null) {
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
      AppLog.d('Error canceling all notifications: $e');
    }
  }

  /// Replaces the existing reminder with an updated schedule.
  Future<bool> reschedule(
    Todo todo, {
    AppSettings? settings,
    Category? category,
    bool firePastDueImmediately = true,
  }) async {
    await cancel(todo.id);
    return scheduleForTodo(
      todo,
      settings: settings,
      category: category,
      firePastDueImmediately: firePastDueImmediately,
    );
  }

  /// Re-schedules active reminders so action labels pick up current [settings].
  Future<void> rescheduleActiveReminders(
    Iterable<Todo> todos, {
    AppSettings? settings,
    bool firePastDueImmediately = false,
  }) async {
    for (final todo in todos) {
      if (todo.dueAt == null || todo.status != TodoStatus.active) {
        continue;
      }
      await reschedule(
        todo,
        settings: settings,
        firePastDueImmediately: firePastDueImmediately,
      );
    }
  }

  /// Delays [todo]'s reminder by [settings.snoozeDuration] minutes.
  Future<void> snooze(Todo todo, AppSettings settings) async {
    final snoozeText = snoozeActionLabel(settings.snoozeDuration);

    await _notificationShow.snoozeNotification(
      todo.id,
      todo.name,
      todo.description,
      snoozeActionText: snoozeText,
      markDoneActionText: 'markAsDone'.tr,
      snoozeMinutes: settings.snoozeDuration,
      settings: null,
      priority: todo.priority,
    );
  }
}
