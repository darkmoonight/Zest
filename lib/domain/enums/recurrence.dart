/// How often a list item or category habit repeats.
enum RecurrenceFrequency {
  /// No recurrence.
  none,

  /// Every day.
  daily,

  /// On selected weekdays (or same weekday as due date).
  weekly,

  /// Same day of month (clamped).
  monthly,
}

/// What happens when a recurring item is completed.
enum RecurrenceMode {
  /// Keep the completed item and create a new active copy.
  clone,

  /// Keep the same item and reopen it on the next occurrence.
  reopen,
}
