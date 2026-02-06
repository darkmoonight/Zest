class StatisticsData {
  final int totalTodos;
  final int completedTodos;
  final double completionRate;
  final Map<DateTime, int> completionHeatmap;
  final int todayCompleted;
  final int weekCompleted;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> weeklyProgress;
  final Map<int, int> hourlyProgress;

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
