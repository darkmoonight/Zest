class StatisticsData {
  final int totalTodos;
  final int completedTodos;
  final double completionRate;
  final Map<DateTime, int> completionHeatmap;
  final int todayCompleted;
  final int weekCompleted;

  StatisticsData({
    required this.totalTodos,
    required this.completedTodos,
    required this.completionRate,
    required this.completionHeatmap,
    required this.todayCompleted,
    required this.weekCompleted,
  });
}
