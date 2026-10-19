part of 'recurrence_service.dart';

/// Due-date resolution helpers for [RecurrenceService].
abstract final class _RecurrenceDue {
  static DateTime? resolveActiveReminderDue({
    required DateTime now,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    required int? minuteOfDay,
    DateTime? baseDay,
    DateTime? fallbackTime,
  }) {
    if (!_RecurrenceSchedule.isRecurring(frequency) || minuteOfDay == null) return fallbackTime;

    final day = _RecurrenceSchedule.calendarDay(baseDay ?? now);
    final anchor = fallbackTime ?? baseDay ?? now;
    if (!_RecurrenceSchedule._isOccurrenceDay(
      day,
      frequency,
      weekdays,
      monthlyDayOfMonth: anchor.day,
      fallbackWeekday: anchor.weekday,
    )) {
      return _RecurrenceSchedule.nextReminderAfter(
        now: now,
        frequency: frequency,
        weekdays: weekdays,
        minuteOfDay: minuteOfDay,
        fallbackTime: fallbackTime,
      );
    }

    var due = _RecurrenceSchedule.dueForOccurrenceDay(day, minuteOfDay, fallbackTime: fallbackTime);
    if (due == null) return fallbackTime;
    if (!due.isAfter(now)) {
      due = _RecurrenceSchedule.nextReminderAfter(
        now: now,
        frequency: frequency,
        weekdays: weekdays,
        minuteOfDay: minuteOfDay,
        fallbackTime: fallbackTime ?? due,
      );
    }
    return due;
  }

  /// Resolves due for a list item living under [task], preferring the item's own rule.
  ///
  /// - Own recurring item → [todoMinuteOfDay] / weekdays.
  /// - Otherwise category habit (`todoRecurrence == none`) → [task] reminder.
  /// - Explicit [fallbackTime] (parsed due) wins over a missing category minute.
  static DateTime? resolveDueForTodoInCategory({
    required DateTime now,
    required Category category,
    required RecurrenceFrequency todoRecurrence,
    required List<int> todoWeekdays,
    required int? todoMinuteOfDay,
    DateTime? baseDay,
    DateTime? fallbackTime,
  }) {
    if (_RecurrenceSchedule.isRecurring(todoRecurrence)) {
      return resolveActiveReminderDue(
        now: now,
        frequency: todoRecurrence,
        weekdays: todoWeekdays,
        minuteOfDay: todoMinuteOfDay,
        baseDay: baseDay,
        fallbackTime: fallbackTime,
      );
    }

    if (fallbackTime != null) return fallbackTime;

    return resolveActiveReminderDue(
      now: now,
      frequency: category.recurrence,
      weekdays: category.recurrenceWeekdays,
      minuteOfDay: category.recurrenceMinuteOfDay,
      baseDay: baseDay,
      fallbackTime: fallbackTime,
    );
  }

  /// Convenience wrapper around [resolveDueForTodoInCategory] using [item] fields.
  static DateTime? resolveDueForTodo({
    required Todo todo,
    required Category category,
    required DateTime now,
    DateTime? baseDay,
    DateTime? fallbackTime,
  }) => resolveDueForTodoInCategory(
    now: now,
    category: category,
    todoRecurrence: todo.recurrence,
    todoWeekdays: todo.recurrenceWeekdays,
    todoMinuteOfDay: todo.recurrenceMinuteOfDay,
    baseDay: baseDay,
    fallbackTime: fallbackTime,
  );
}
