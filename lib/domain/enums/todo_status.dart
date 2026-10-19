/// Item lifecycle status.
enum TodoStatus {
  /// Open and not completed.
  active,

  /// Completed successfully.
  done,

  /// Cancelled without completion.
  cancelled;

  /// Whether this status counts as finished.
  bool get isCompleted =>
      this == TodoStatus.done || this == TodoStatus.cancelled;

  /// Maps a status tab index to the corresponding [TodoStatus].
  static TodoStatus fromTabIndex(int index) => switch (index) {
    0 => TodoStatus.active,
    1 => TodoStatus.done,
    _ => TodoStatus.cancelled,
  };
}
