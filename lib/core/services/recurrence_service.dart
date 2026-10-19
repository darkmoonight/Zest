import 'package:zest/core/utils/calendar_date.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';

/// Pure recurrence math and clone helpers for items / categories.
///
/// Day model:
/// - [recurrenceMinuteOfDay] is the reminder / notification clock.
/// - Local midnight is when clone-mode spawns or reopen-mode reactivates
///   (see [RecurrenceCoordinator.runMidnightRollover]).
class RecurrenceService {
  RecurrenceService._();

  static const _maxMinuteOfDay = 24 * 60 - 1;
  static const _maxReminderLookaheadDays = 370;

  /// Whether [frequency] means the item repeats.
  static bool isRecurring(RecurrenceFrequency frequency) =>
      frequency != RecurrenceFrequency.none;

  /// Local midnight for [date].
  static DateTime calendarDay(DateTime date) => CalendarDate.day(date);

  /// Attaches [minuteOfDay] (or [fallbackTime]'s clock) onto [date]'s calendar day.
  ///
  /// Returns null when [date] is null. When both minute and fallback are null,
  /// returns a date-only value at local midnight.
  static DateTime? applyRecurrenceTime(
    DateTime? date,
    int? minuteOfDay, {
    DateTime? fallbackTime,
  }) {
    if (date == null) return null;

    final day = calendarDay(date);
    if (minuteOfDay != null) {
      final clamped = minuteOfDay.clamp(0, _maxMinuteOfDay);
      return DateTime(
        day.year,
        day.month,
        day.day,
        clamped ~/ 60,
        clamped % 60,
      );
    }
    if (fallbackTime != null) {
      return DateTime(
        day.year,
        day.month,
        day.day,
        fallbackTime.hour,
        fallbackTime.minute,
        fallbackTime.second,
        fallbackTime.millisecond,
        fallbackTime.microsecond,
      );
    }
    return day;
  }

  /// Due datetime for an occurrence on [day] using [minuteOfDay] / [fallbackTime].
  ///
  /// Returns null when there is no reminder time and no fallback clock.
  static DateTime? dueForOccurrenceDay(
    DateTime day,
    int? minuteOfDay, {
    DateTime? fallbackTime,
  }) {
    if (minuteOfDay == null && fallbackTime == null) return null;
    return applyRecurrenceTime(
      calendarDay(day),
      minuteOfDay,
      fallbackTime: fallbackTime,
    );
  }

  /// Due for an active occurrence: [baseDay] + reminder, or next future slot.
  ///
  /// When [minuteOfDay] is null or [frequency] is not recurring, returns
  /// [fallbackTime] unchanged (caller may pass a parsed due).
  static DateTime? resolveActiveReminderDue({
    required DateTime now,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    required int? minuteOfDay,
    DateTime? baseDay,
    DateTime? fallbackTime,
  }) {
    if (!isRecurring(frequency) || minuteOfDay == null) return fallbackTime;

    final day = calendarDay(baseDay ?? now);
    final anchor = fallbackTime ?? baseDay ?? now;
    if (!_isOccurrenceDay(
      day,
      frequency,
      weekdays,
      monthlyDayOfMonth: anchor.day,
      fallbackWeekday: anchor.weekday,
    )) {
      return nextReminderAfter(
        now: now,
        frequency: frequency,
        weekdays: weekdays,
        minuteOfDay: minuteOfDay,
        fallbackTime: fallbackTime,
      );
    }

    var due = dueForOccurrenceDay(day, minuteOfDay, fallbackTime: fallbackTime);
    if (due == null) return fallbackTime;
    if (!due.isAfter(now)) {
      due = nextReminderAfter(
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
    if (isRecurring(todoRecurrence)) {
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

  /// Whether [item] is an active child governed by [task]'s habit (no own repeat).
  static bool isCategoryHabitChild({
    required Todo todo,
    required Category category,
  }) =>
      todo.status == TodoStatus.active &&
      !isRecurring(todo.recurrence) &&
      isRecurring(category.recurrence);

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

    final todayDate = calendarDay(today ?? DateTime.now());
    final due = todo.dueAt;
    if (due == null) return true;
    if (!calendarDay(due).isBefore(todayDate)) return false;

    final anchor = _scheduleAnchor(due: due, created: todo.createdAt);
    return _isOccurrenceDay(
      todayDate,
      category.recurrence,
      category.recurrenceWeekdays,
      monthlyDayOfMonth: anchor.day,
      fallbackWeekday: anchor.weekday,
    );
  }

  /// Next reminder at or after [now] for the given recurrence rule.
  ///
  /// If today's reminder is still in the future, returns today + time.
  /// Otherwise advances by the recurrence rule until a future instant.
  static DateTime? nextReminderAfter({
    required DateTime now,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    required int? minuteOfDay,
    DateTime? fallbackTime,
  }) {
    if (!isRecurring(frequency)) return null;
    if (minuteOfDay == null && fallbackTime == null) return null;

    final anchor = fallbackTime ?? now;
    var day = calendarDay(now);
    for (var i = 0; i < _maxReminderLookaheadDays; i++) {
      if (!_isOccurrenceDay(
        day,
        frequency,
        weekdays,
        monthlyDayOfMonth: anchor.day,
        fallbackWeekday: anchor.weekday,
      )) {
        day = _addCalendarDays(day, 1);
        continue;
      }
      final candidate = dueForOccurrenceDay(
        day,
        minuteOfDay,
        fallbackTime: fallbackTime,
      );
      if (candidate != null && candidate.isAfter(now)) {
        return candidate;
      }
      day = _addCalendarDays(day, 1);
    }
    return null;
  }

  /// Whether [day] is a valid occurrence for [frequency] / [weekdays].
  static bool isOccurrenceDay({
    required DateTime day,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    int? monthlyDayOfMonth,
    int? fallbackWeekday,
  }) => _isOccurrenceDay(
    calendarDay(day),
    frequency,
    weekdays,
    monthlyDayOfMonth: monthlyDayOfMonth,
    fallbackWeekday: fallbackWeekday,
  );

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

  /// Next occurrence after [from] for [frequency] / [weekdays].
  static DateTime? nextOccurrence({
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    DateTime? from,
    DateTime? now,
    int? minuteOfDay,
  }) {
    if (!isRecurring(frequency)) return null;

    final anchor = from ?? (now ?? DateTime.now());
    final base = from != null
        ? anchor
        : DateTime(anchor.year, anchor.month, anchor.day);

    final next = switch (frequency) {
      RecurrenceFrequency.none => null,
      RecurrenceFrequency.daily => _addCalendarDays(base, 1),
      RecurrenceFrequency.weekly => _nextWeekly(base, weekdays),
      RecurrenceFrequency.monthly => _nextMonthly(base),
    };

    return applyRecurrenceTime(next, minuteOfDay, fallbackTime: from);
  }

  /// Whether a category habit reset should reopen [item] given [task] rule.
  ///
  /// Category habits only support reopen; legacy [RecurrenceMode.clone] on a
  /// category is treated as reopen (clone spawning is item-level only).
  static bool shouldResetCategoryHabit({
    required Todo todo,
    required Category category,
    DateTime? today,
  }) {
    if (!isRecurring(category.recurrence)) return false;
    if (isRecurring(todo.recurrence)) return false;
    return _shouldReopenCompleted(
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
    if (!isRecurring(todo.recurrence)) return false;
    return _shouldReopenCompleted(
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
    if (!isRecurring(todo.recurrence)) return false;
    if (todo.status != TodoStatus.done) return false;
    final completed = todo.completedAt;
    if (completed == null) return false;

    final todayDate = calendarDay(today ?? DateTime.now());
    if (!_isCompletedBefore(completed, todayDate)) return false;

    final anchor = _scheduleAnchor(
      due: todo.dueAt,
      completed: completed,
      created: todo.createdAt,
    );
    return _isOccurrenceDay(
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
    if (!isRecurring(todo.recurrence)) return false;
    if (todo.status != TodoStatus.active) return false;

    final todayDate = calendarDay(today ?? DateTime.now());
    final due = todo.dueAt;
    if (due != null && !calendarDay(due).isBefore(todayDate)) return false;

    final anchor = _scheduleAnchor(due: due, created: todo.createdAt);
    return _isOccurrenceDay(
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
    final day = occurrenceDay != null ? calendarDay(occurrenceDay) : null;
    final nextDue = day != null
        ? dueForOccurrenceDay(
            day,
            source.recurrenceMinuteOfDay,
            fallbackTime: source.dueAt,
          )
        : nextOccurrence(
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

  static DateTime _scheduleAnchor({
    DateTime? due,
    DateTime? completed,
    DateTime? created,
  }) => due ?? completed ?? created ?? DateTime.now();

  static DateTime _addCalendarDays(DateTime from, int days) =>
      CalendarDate.addDays(from, days, keepTime: true);

  static bool _isCompletedBefore(DateTime completed, DateTime todayDate) =>
      calendarDay(completed).isBefore(todayDate);

  static bool _isOccurrenceDay(
    DateTime day,
    RecurrenceFrequency frequency,
    List<int> weekdays, {
    int? monthlyDayOfMonth,
    int? fallbackWeekday,
  }) {
    if (!isRecurring(frequency)) return false;
    if (frequency == RecurrenceFrequency.daily) return true;
    if (frequency == RecurrenceFrequency.weekly) {
      return _matchesWeekday(day, weekdays, fallbackWeekday: fallbackWeekday);
    }
    if (frequency != RecurrenceFrequency.monthly) return false;
    if (monthlyDayOfMonth == null) return false;
    return _matchesMonthlyDay(day, monthlyDayOfMonth);
  }

  static bool _matchesWeekday(
    DateTime day,
    List<int> weekdays, {
    int? fallbackWeekday,
  }) {
    if (weekdays.isNotEmpty) return weekdays.contains(day.weekday);
    if (fallbackWeekday == null) return false;
    return day.weekday == fallbackWeekday;
  }

  static bool _matchesMonthlyDay(DateTime day, int targetDay) {
    final lastDay = DateTime(day.year, day.month + 1, 0).day;
    final effectiveDay = targetDay > lastDay ? lastDay : targetDay;
    return day.day == effectiveDay;
  }

  static bool _shouldReopenCompleted({
    required TodoStatus status,
    required DateTime? completed,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    DateTime? due,
    DateTime? created,
    DateTime? today,
  }) {
    if (status != TodoStatus.done) return false;
    if (completed == null) return false;

    final todayDate = calendarDay(today ?? DateTime.now());
    if (!_isCompletedBefore(completed, todayDate)) return false;

    final anchor = _scheduleAnchor(
      due: due,
      completed: completed,
      created: created,
    );
    return _isOccurrenceDay(
      todayDate,
      frequency,
      weekdays,
      monthlyDayOfMonth: anchor.day,
      fallbackWeekday: anchor.weekday,
    );
  }

  static DateTime _nextWeekly(DateTime from, List<int> weekdays) {
    final targets = (weekdays.isEmpty ? <int>[from.weekday] : weekdays).toSet()
      ..removeWhere((d) => d < 1 || d > 7);
    if (targets.isEmpty) {
      return _addCalendarDays(from, 7);
    }

    for (var offset = 1; offset <= 7; offset++) {
      final candidate = _addCalendarDays(from, offset);
      if (targets.contains(candidate.weekday)) return candidate;
    }
    return _addCalendarDays(from, 7);
  }

  static DateTime _nextMonthly(DateTime from) {
    final day = from.day;
    var year = from.year;
    var month = from.month + 1;
    if (month > 12) {
      month = 1;
      year++;
    }
    final lastDay = DateTime(year, month + 1, 0).day;
    final clampedDay = day > lastDay ? lastDay : day;
    return DateTime(
      year,
      month,
      clampedDay,
      from.hour,
      from.minute,
      from.second,
      from.millisecond,
      from.microsecond,
    );
  }
}
