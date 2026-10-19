import 'package:zest/domain/enums/enums.dart';

/// Domain model for a category that groups list items.
class Category {
  const Category({
    required this.id,
    required this.title,
    this.description = '',
    required this.colorArgb,
    this.archive = false,
    this.index,
    this.sortOption = SortOption.none,
    this.recurrence = RecurrenceFrequency.none,
    this.recurrenceWeekdays = const [],
    this.recurrenceMode = RecurrenceMode.reopen,
    this.recurrenceMinuteOfDay,
    this.isSystem = false,
  });

  final int id;
  final String title;
  final String description;
  final int colorArgb;
  final bool archive;
  final int? index;
  final SortOption sortOption;
  final RecurrenceFrequency recurrence;
  final List<int> recurrenceWeekdays;
  final RecurrenceMode recurrenceMode;
  final int? recurrenceMinuteOfDay;
  final bool isSystem;

  Category copyWith({
    int? id,
    String? title,
    String? description,
    int? colorArgb,
    bool? archive,
    int? index,
    bool clearIndex = false,
    SortOption? sortOption,
    RecurrenceFrequency? recurrence,
    List<int>? recurrenceWeekdays,
    RecurrenceMode? recurrenceMode,
    int? recurrenceMinuteOfDay,
    bool clearRecurrenceMinuteOfDay = false,
    bool? isSystem,
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      colorArgb: colorArgb ?? this.colorArgb,
      archive: archive ?? this.archive,
      index: clearIndex ? null : (index ?? this.index),
      sortOption: sortOption ?? this.sortOption,
      recurrence: recurrence ?? this.recurrence,
      recurrenceWeekdays: recurrenceWeekdays ?? this.recurrenceWeekdays,
      recurrenceMode: recurrenceMode ?? this.recurrenceMode,
      recurrenceMinuteOfDay: clearRecurrenceMinuteOfDay
          ? null
          : (recurrenceMinuteOfDay ?? this.recurrenceMinuteOfDay),
      isSystem: isSystem ?? this.isSystem,
    );
  }
}
