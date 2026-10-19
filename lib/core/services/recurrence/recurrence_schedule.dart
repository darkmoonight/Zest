part of 'recurrence_service.dart';

/// Occurrence / reminder schedule math for [RecurrenceService].
abstract final class _RecurrenceSchedule {
  static const maxMinuteOfDay = 24 * 60 - 1;
  static const maxReminderLookaheadDays = 370;

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
      final clamped = minuteOfDay.clamp(0, maxMinuteOfDay);
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
    for (var i = 0; i < maxReminderLookaheadDays; i++) {
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
