/// Computes completion percentage and progress from totals.
class ProgressCalculator {
  /// Creates a calculator for [total] items of which [completed] are done.
  const ProgressCalculator({required this.total, required this.completed});

  /// Total item count.
  final int total;

  /// Completed item count.
  final int completed;

  /// Completion percentage rounded to the nearest integer.
  int get percentage => total > 0 ? (completed / total * 100).round() : 0;

  /// Completion percentage as a whole-number string.
  String get percentageString =>
      total > 0 ? (completed / total * 100).toStringAsFixed(0) : '0';

  /// Completion ratio in the range 0.0–1.0.
  double get progress => total > 0 ? completed / total : 0.0;

  /// Whether every item is completed.
  bool get isComplete => total > 0 && completed == total;

  /// Items still incomplete, clamped to non-negative.
  int get remaining => (total - completed).clamp(0, total);

  /// Returns a copy with optional updated [total] or [completed].
  ProgressCalculator copyWith({int? total, int? completed}) {
    return ProgressCalculator(
      total: total ?? this.total,
      completed: completed ?? this.completed,
    );
  }
}
