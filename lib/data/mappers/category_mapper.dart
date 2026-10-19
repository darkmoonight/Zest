import 'package:zest/data/models/db.dart';
import 'package:zest/domain/entities/category.dart';

/// Maps between Isar [Tasks] rows and domain [Category] entities.
abstract final class CategoryMapper {
  /// Converts an Isar [Tasks] row to a domain [Category].
  static Category toDomain(Tasks row) => Category(
    id: row.id,
    title: row.title,
    description: row.description,
    colorArgb: row.taskColor,
    archive: row.archive,
    index: row.index,
    sortOption: row.sortOption,
    recurrence: row.recurrence,
    recurrenceWeekdays: List<int>.from(row.recurrenceWeekdays),
    recurrenceMode: row.recurrenceMode,
    recurrenceMinuteOfDay: row.recurrenceMinuteOfDay,
    isSystem: row.isSystem,
  );

  /// Applies domain fields onto an existing Isar [row].
  static void applyDomain(Tasks row, Category category) {
    row.title = category.title;
    row.description = category.description;
    row.taskColor = category.colorArgb;
    row.archive = category.archive;
    row.index = category.index;
    row.sortOption = category.sortOption;
    row.recurrence = category.recurrence;
    row.recurrenceWeekdays = List<int>.from(category.recurrenceWeekdays);
    row.recurrenceMode = category.recurrenceMode;
    row.recurrenceMinuteOfDay = category.recurrenceMinuteOfDay;
    row.isSystem = category.isSystem;
  }

  /// Maps a list of Isar rows to domain categories.
  static List<Category> toDomainList(List<Tasks> rows) =>
      rows.map(toDomain).toList();
}
