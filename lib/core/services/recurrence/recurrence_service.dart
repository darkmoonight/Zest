import 'package:zest/core/utils/calendar_date.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';

part 'recurrence_schedule.dart';
part 'recurrence_due.dart';
part 'recurrence_habits_and_clones.dart';

/// Pure recurrence math and clone helpers for items / categories.
///
/// Day model:
/// - [recurrenceMinuteOfDay] is the reminder / notification clock.
/// - Local midnight is when clone-mode spawns or reopen-mode reactivates
///   (see [RecurrenceCoordinator.runMidnightRollover]).
class RecurrenceService {
  RecurrenceService._();

  /// Whether [frequency] means the item repeats.
  static bool isRecurring(RecurrenceFrequency frequency) =>
      _RecurrenceSchedule.isRecurring(frequency);

  /// Local midnight for [date].
  static DateTime calendarDay(DateTime date) =>
      _RecurrenceSchedule.calendarDay(date);

  /// Attaches [minuteOfDay] (or [fallbackTime]'s clock) onto [date]'s calendar day.
  static DateTime? applyRecurrenceTime(
    DateTime? date,
    int? minuteOfDay, {
    DateTime? fallbackTime,
  }) => _RecurrenceSchedule.applyRecurrenceTime(
    date,
    minuteOfDay,
    fallbackTime: fallbackTime,
  );

  /// Due datetime for an occurrence on [day] using [minuteOfDay] / [fallbackTime].
  static DateTime? dueForOccurrenceDay(
    DateTime day,
    int? minuteOfDay, {
    DateTime? fallbackTime,
  }) => _RecurrenceSchedule.dueForOccurrenceDay(
    day,
    minuteOfDay,
    fallbackTime: fallbackTime,
  );

  /// Due for an active occurrence: [baseDay] + reminder, or next future slot.
  static DateTime? resolveActiveReminderDue({
    required DateTime now,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    required int? minuteOfDay,
    DateTime? baseDay,
    DateTime? fallbackTime,
  }) => _RecurrenceDue.resolveActiveReminderDue(
    now: now,
    frequency: frequency,
    weekdays: weekdays,
    minuteOfDay: minuteOfDay,
    baseDay: baseDay,
    fallbackTime: fallbackTime,
  );

  /// Resolves due for a list item living under [category], preferring the item's own rule.
  static DateTime? resolveDueForTodoInCategory({
    required DateTime now,
    required Category category,
    required RecurrenceFrequency todoRecurrence,
    required List<int> todoWeekdays,
    required int? todoMinuteOfDay,
    DateTime? baseDay,
    DateTime? fallbackTime,
  }) => _RecurrenceDue.resolveDueForTodoInCategory(
    now: now,
    category: category,
    todoRecurrence: todoRecurrence,
    todoWeekdays: todoWeekdays,
    todoMinuteOfDay: todoMinuteOfDay,
    baseDay: baseDay,
    fallbackTime: fallbackTime,
  );

  /// Convenience wrapper around [resolveDueForTodoInCategory] using [todo] fields.
  static DateTime? resolveDueForTodo({
    required Todo todo,
    required Category category,
    required DateTime now,
    DateTime? baseDay,
    DateTime? fallbackTime,
  }) => _RecurrenceDue.resolveDueForTodo(
    todo: todo,
    category: category,
    now: now,
    baseDay: baseDay,
    fallbackTime: fallbackTime,
  );

  /// Whether [todo] is an active child governed by [category]'s habit (no own repeat).
  static bool isCategoryHabitChild({
    required Todo todo,
    required Category category,
  }) => _RecurrenceHabits.isCategoryHabitChild(todo: todo, category: category);

  /// Whether an active category-habit item needs due stamped from [category].
  static bool shouldEnsureCategoryHabitDue({
    required Todo todo,
    required Category category,
    DateTime? today,
  }) => _RecurrenceHabits.shouldEnsureCategoryHabitDue(
    todo: todo,
    category: category,
    today: today,
  );

  /// Next reminder at or after [now] for the given recurrence rule.
  static DateTime? nextReminderAfter({
    required DateTime now,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    required int? minuteOfDay,
    DateTime? fallbackTime,
  }) => _RecurrenceSchedule.nextReminderAfter(
    now: now,
    frequency: frequency,
    weekdays: weekdays,
    minuteOfDay: minuteOfDay,
    fallbackTime: fallbackTime,
  );

  /// Whether [day] is a valid occurrence for [frequency] / [weekdays].
  static bool isOccurrenceDay({
    required DateTime day,
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    int? monthlyDayOfMonth,
    int? fallbackWeekday,
  }) => _RecurrenceSchedule.isOccurrenceDay(
    day: day,
    frequency: frequency,
    weekdays: weekdays,
    monthlyDayOfMonth: monthlyDayOfMonth,
    fallbackWeekday: fallbackWeekday,
  );

  /// Fingerprint for matching clone-mode siblings in the same category.
  static String cloneFingerprint(Todo todo) =>
      _RecurrenceHabits.cloneFingerprint(todo);

  /// Stable key for a clone sibling group within [taskId].
  static String cloneSiblingKey(int taskId, Todo todo) =>
      _RecurrenceHabits.cloneSiblingKey(taskId, todo);

  /// Next occurrence after [from] for [frequency] / [weekdays].
  static DateTime? nextOccurrence({
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    DateTime? from,
    DateTime? now,
    int? minuteOfDay,
  }) => _RecurrenceSchedule.nextOccurrence(
    frequency: frequency,
    weekdays: weekdays,
    from: from,
    now: now,
    minuteOfDay: minuteOfDay,
  );

  /// Whether a category habit reset should reopen [todo] given [category] rule.
  static bool shouldResetCategoryHabit({
    required Todo todo,
    required Category category,
    DateTime? today,
  }) => _RecurrenceHabits.shouldResetCategoryHabit(
    todo: todo,
    category: category,
    today: today,
  );

  /// Whether a list item with its own reopen recurrence should become active again.
  static bool shouldResetTodoHabit({required Todo todo, DateTime? today}) =>
      _RecurrenceHabits.shouldResetTodoHabit(todo: todo, today: today);

  /// Whether a done clone-mode item should spawn an active sibling for [today].
  static bool shouldSpawnCloneForToday({required Todo todo, DateTime? today}) =>
      _RecurrenceHabits.shouldSpawnCloneForToday(todo: todo, today: today);

  /// Whether an active clone-mode item's due should be bumped to [today].
  static bool shouldBumpActiveCloneDue({required Todo todo, DateTime? today}) =>
      _RecurrenceHabits.shouldBumpActiveCloneDue(todo: todo, today: today);

  /// Builds an unsaved clone of [source] for [occurrenceDay] (default: tomorrow).
  static Todo buildNextClone(
    Todo source, {
    DateTime? now,
    DateTime? occurrenceDay,
  }) => _RecurrenceHabits.buildNextClone(
    source,
    now: now,
    occurrenceDay: occurrenceDay,
  );
}
