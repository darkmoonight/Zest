/// Data model holding statistics values.
class StatisticsData {
  /// The total items.
  final int totalTodos;

  /// The completed items.
  final int completedTodos;

  /// The completion rate.
  final double completionRate;

  /// The completion heatmap.
  final Map<DateTime, int> completionHeatmap;

  /// The today completed.
  final int todayCompleted;

  /// The week completed.
  final int weekCompleted;

  /// The current streak.
  final int currentStreak;

  /// The longest streak.
  final int longestStreak;

  /// The weekly progress keyed by weekday (1 = Monday … 7 = Sunday).
  final Map<int, int> weeklyProgress;

  /// The hourly progress.
  final Map<int, int> hourlyProgress;

  /// Creates a [StatisticsData].
  StatisticsData({
    required this.totalTodos,
    required this.completedTodos,
    required this.completionRate,
    required this.completionHeatmap,
    required this.todayCompleted,
    required this.weekCompleted,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyProgress,
    required this.hourlyProgress,
  });
}
