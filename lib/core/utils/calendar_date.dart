/// Calendar-day helpers that ignore DST wall-clock duration math.
abstract final class CalendarDate {
  /// Length of a weekly window or retention interval, in calendar days.
  static const weeklyDays = 7;

  /// Heatmap lookback, in calendar days.
  static const yearDays = 365;

  /// Local midnight for [date]'s year/month/day.
  static DateTime day(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Shifts [date] by [days] on the calendar.
  ///
  /// When [keepTime] is false, the result is local midnight.
  static DateTime addDays(DateTime date, int days, {bool keepTime = false}) {
    final next = DateTime(date.year, date.month, date.day + days);
    if (!keepTime) return DateTime(next.year, next.month, next.day);
    return DateTime(
      next.year,
      next.month,
      next.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  /// Whole calendar days from [from] to [to] (UTC date components).
  static int daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// Whether [a] and [b] fall on the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether [a] and [b] fall in the same calendar month.
  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
