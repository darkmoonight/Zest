part of 'recurrence_service.dart';

/// Category habit and clone/reopen helpers for [RecurrenceService].
abstract final class _RecurrenceHabits {
  /// Whether [item] is an active child governed by [task]'s habit (no own repeat).
  static bool isCategoryHabitChild({
    required Todo todo,
    required Category category,
  }) =>
      todo.status == TodoStatus.active &&
      !_RecurrenceSchedule.isRecurring(todo.recurrence) &&
      _RecurrenceSchedule.isRecurring(category.recurrence);

  /// Whether an active category-habit item needs due stamped from [task].
  ///
  /// Null due always stamps. Stale due restamps only on an occurrence day
  /// (weekly/monthly use [Todo.todoCompletedTime] as the schedule anchor).
  static bool shouldEnsureCategoryHabitDue({
    required Todo todo,
    required Category category,
    DateTime? today,
  }) {
    if (!isCategoryHabitChild(todo: todo, category: category)) return false;
    if (category.recurrenceMinuteOfDay == null) return false;

    final todayDate = _RecurrenceSchedule.calendarDay(today ?? DateTime.now());
    final due = todo.dueAt;
    if (due == null) return true;
    if (!_RecurrenceSchedule.calendarDay(due).isBefore(todayDate)) return false;

    final anchor = _RecurrenceSchedule._scheduleAnchor(
      due: due,
      created: todo.createdAt,
    );
    return _RecurrenceSchedule._isOccurrenceDay(
      todayDate,
      category.recurrence,
      category.recurrenceWeekdays,
      monthlyDayOfMonth: anchor.day,
      fallbackWeekday: anchor.weekday,
    );
  }

  /// Fingerprint for matching clone-mode siblings in the same category.
  static String cloneFingerprint(Todo todo) {
    final days = List<int>.from(todo.recurrenceWeekdays)..sort();
    return [
      todo.name,
      todo.recurrence.name,
      days.join(','),
      todo.recurrenceMode.name,
      '${todo.recurrenceMinuteOfDay}',
    ].join('|');
  }

  /// Stable key for a clone sibling group within [taskId].
  static String cloneSiblingKey(int taskId, Todo todo) =>
      '$taskId|${cloneFingerprint(todo)}';

  /// Whether a category habit reset should reopen [item] given [task] rule.
  ///
  /// Category habits only support reopen; legacy [RecurrenceMode.clone] on a
  /// category is treated as reopen (clone spawning is item-level only).
  static bool shouldResetCategoryHabit({
    required Todo todo,
    required Category category,
    DateTime? today,
  }) {
    if (!_RecurrenceSchedule.isRecurring(category.recurrence)) return false;
    if (_RecurrenceSchedule.isRecurring(todo.recurrence)) return false;
    return _RecurrenceSchedule._shouldReopenCompleted(
      status: todo.status,
      due: todo.dueAt,
      completed: todo.completedAt,
      created: todo.createdAt,
      frequency: category.recurrence,
      weekdays: category.recurrenceWeekdays,
      today: today,
    );
  }

  /// Whether a list item with its own reopen recurrence should become active again.
  static bool shouldResetTodoHabit({required Todo todo, DateTime? today}) {
    if (todo.recurrenceMode != RecurrenceMode.reopen) return false;
    if (!_RecurrenceSchedule.isRecurring(todo.recurrence)) return false;
    return _RecurrenceSchedule._shouldReopenCompleted(
      status: todo.status,
      due: todo.dueAt,
      completed: todo.completedAt,
      created: todo.createdAt,
      frequency: todo.recurrence,
      weekdays: todo.recurrenceWeekdays,
      today: today,
    );
  }

  /// Whether a done clone-mode item should spawn an active sibling for [today].
  static bool shouldSpawnCloneForToday({required Todo todo, DateTime? today}) {
    if (todo.recurrenceMode != RecurrenceMode.clone) return false;
    if (!_RecurrenceSchedule.isRecurring(todo.recurrence)) return false;
    if (todo.status != TodoStatus.done) return false;
    final completed = todo.completedAt;
    if (completed == null) return false;

    final todayDate = _RecurrenceSchedule.calendarDay(today ?? DateTime.now());
    if (!_RecurrenceSchedule._isCompletedBefore(completed, todayDate))
      return false;

    final anchor = _RecurrenceSchedule._scheduleAnchor(
      due: todo.dueAt,
      completed: completed,
      created: todo.createdAt,
    );
    return _RecurrenceSchedule._isOccurrenceDay(
      todayDate,
      todo.recurrence,
      todo.recurrenceWeekdays,
      monthlyDayOfMonth: anchor.day,
      fallbackWeekday: anchor.weekday,
    );
  }

  /// Whether an active clone-mode item's due should be bumped to [today].
  static bool shouldBumpActiveCloneDue({required Todo todo, DateTime? today}) {
    if (todo.recurrenceMode != RecurrenceMode.clone) return false;
    if (!_RecurrenceSchedule.isRecurring(todo.recurrence)) return false;
    if (todo.status != TodoStatus.active) return false;

    final todayDate = _RecurrenceSchedule.calendarDay(today ?? DateTime.now());
    final due = todo.dueAt;
    if (due != null &&
        !_RecurrenceSchedule.calendarDay(due).isBefore(todayDate))
      return false;

    final anchor = _RecurrenceSchedule._scheduleAnchor(
      due: due,
      created: todo.createdAt,
    );
    return _RecurrenceSchedule._isOccurrenceDay(
      todayDate,
      todo.recurrence,
      todo.recurrenceWeekdays,
      monthlyDayOfMonth: anchor.day,
      fallbackWeekday: anchor.weekday,
    );
  }

  /// Builds an unsaved clone of [source] for [occurrenceDay] (default: tomorrow).
  static Todo buildNextClone(
    Todo source, {
    DateTime? now,
    DateTime? occurrenceDay,
  }) {
    final day = occurrenceDay != null
        ? _RecurrenceSchedule.calendarDay(occurrenceDay)
        : null;
    final nextDue = day != null
        ? _RecurrenceSchedule.dueForOccurrenceDay(
            day,
            source.recurrenceMinuteOfDay,
            fallbackTime: source.dueAt,
          )
        : _RecurrenceSchedule.nextOccurrence(
            frequency: source.recurrence,
            weekdays: source.recurrenceWeekdays,
            from: source.dueAt,
            now: now,
            minuteOfDay: source.recurrenceMinuteOfDay,
          );

    return Todo(
      id: 0,
      name: source.name,
      description: source.description,
      dueAt: nextDue,
      createdAt: now ?? DateTime.now(),
      fix: source.fix,
      priority: source.priority,
      tags: List<String>.from(source.tags),
      recurrence: source.recurrence,
      recurrenceWeekdays: List<int>.from(source.recurrenceWeekdays),
      recurrenceMode: source.recurrenceMode,
      recurrenceMinuteOfDay: source.recurrenceMinuteOfDay,
      status: TodoStatus.active,
      categoryId: source.categoryId,
    );
  }
}
