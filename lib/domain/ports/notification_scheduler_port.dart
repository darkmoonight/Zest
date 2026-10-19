import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';

/// Schedules and cancels local item reminder notifications.
abstract interface class NotificationSchedulerPort {
  /// Schedules a reminder at [todo.dueAt] for active items only.
  Future<bool> scheduleForTodo(
    Todo todo, {
    AppSettings? settings,
    Category? category,
    bool firePastDueImmediately = true,
  });

  /// Schedules reminders for every item in [todos].
  Future<void> scheduleForTask(List<Todo> todos);

  /// Cancels the reminder for [todoId].
  Future<void> cancel(int todoId);

  /// Cancels reminders for every item in [todos].
  Future<void> cancelForTask(List<Todo> todos);

  /// Cancels reminders for the given item ids.
  Future<void> cancelBatch(List<int> todoIds);

  /// Replaces the existing reminder with an updated schedule.
  Future<bool> reschedule(
    Todo todo, {
    AppSettings? settings,
    Category? category,
    bool firePastDueImmediately = true,
  });

  /// Delays [todo]'s reminder by [settings.snoozeDuration] minutes.
  Future<void> snooze(Todo todo, AppSettings settings);
}
