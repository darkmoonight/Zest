class ProgressCalculator {
  final int total;
  final int completed;

  const ProgressCalculator({required this.total, required this.completed});

  int get percentage => total > 0 ? (completed / total * 100).round() : 0;

  String get percentageString =>
      total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

  double get progress => total > 0 ? completed / total : 0.0;

  bool get isComplete => total > 0 && completed == total;

  int get remaining => (total - completed).clamp(0, total);

  ProgressCalculator copyWith({int? total, int? completed}) {
    return ProgressCalculator(
      total: total ?? this.total,
      completed: completed ?? this.completed,
    );
  }
}
