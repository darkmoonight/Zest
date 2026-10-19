/// Item priority levels with display labels.
enum Priority {
  /// High priority.
  high(name: 'highPriority'),

  /// Medium priority.
  medium(name: 'mediumPriority'),

  /// Low priority.
  low(name: 'lowPriority'),

  /// No priority set.
  none(name: 'noPriority');

  /// Creates a priority with slang [name].
  const Priority({required this.name});

  /// Slang translation key for the priority label.
  final String name;
}
