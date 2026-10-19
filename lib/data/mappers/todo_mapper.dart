import 'package:zest/data/models/db.dart';
import 'package:zest/domain/entities/todo.dart';

/// Maps between Isar [Todos] rows and domain [Todo] entities.
abstract final class TodoMapper {
  /// Converts an Isar row to a domain [Todo].
  ///
  /// Expects `task` / `parent` links to be loaded when [categoryId] / [parentId]
  /// should be populated.
  static Todo toDomain(Todos row) => Todo(
    id: row.id,
    name: row.name,
    description: row.description,
    dueAt: row.todoCompletedTime,
    createdAt: row.createdTime,
    completedAt: row.todoCompletionTime,
    fix: row.fix,
    priority: row.priority,
    status: row.status,
    tags: List<String>.from(row.tags),
    index: row.index,
    childrenSortOption: row.childrenSortOption,
    categoryId: row.task.value?.id,
    parentId: row.parent.value?.id,
    deviceCalendarEventId: row.deviceCalendarEventId,
    caldavUid: row.caldavUid,
    caldavHref: row.caldavHref,
    caldavEtag: row.caldavEtag,
    caldavDirty: row.caldavDirty,
    recurrence: row.recurrence,
    recurrenceWeekdays: List<int>.from(row.recurrenceWeekdays),
    recurrenceMode: row.recurrenceMode,
    recurrenceMinuteOfDay: row.recurrenceMinuteOfDay,
  );

  /// Applies domain fields onto an existing Isar [row] (does not set links).
  static void applyDomain(Todos row, Todo todo) {
    row.name = todo.name;
    row.description = todo.description;
    row.todoCompletedTime = todo.dueAt;
    row.createdTime = todo.createdAt;
    row.todoCompletionTime = todo.completedAt;
    row.fix = todo.fix;
    row.priority = todo.priority;
    row.status = todo.status;
    row.tags = List<String>.from(todo.tags);
    row.index = todo.index;
    row.childrenSortOption = todo.childrenSortOption;
    row.deviceCalendarEventId = todo.deviceCalendarEventId;
    row.caldavUid = todo.caldavUid;
    row.caldavHref = todo.caldavHref;
    row.caldavEtag = todo.caldavEtag;
    row.caldavDirty = todo.caldavDirty;
    row.recurrence = todo.recurrence;
    row.recurrenceWeekdays = List<int>.from(todo.recurrenceWeekdays);
    row.recurrenceMode = todo.recurrenceMode;
    row.recurrenceMinuteOfDay = todo.recurrenceMinuteOfDay;
  }

  /// Maps a list of Isar rows to domain todos.
  static List<Todo> toDomainList(List<Todos> rows) =>
      rows.map(toDomain).toList();
}
