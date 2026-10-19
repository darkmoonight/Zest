/// Item list sort options stored in settings and task/item records.
enum SortOption {
  /// No custom sort applied.
  none,

  /// Alphabetical ascending.
  alphaAsc,

  /// Alphabetical descending.
  alphaDesc,

  /// Due date ascending.
  dateAsc,

  /// Due date descending.
  dateDesc,

  /// Notification date ascending.
  dateNotifAsc,

  /// Notification date descending.
  dateNotifDesc,

  /// Priority ascending.
  priorityAsc,

  /// Priority descending.
  priorityDesc,

  /// Random order.
  random,
}
