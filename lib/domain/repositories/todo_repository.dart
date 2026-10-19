import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';

/// Port for ⟦Items⟧ persistence and queries (domain [Todo]).
abstract interface class TodoRepositoryPort {
  /// Creates a list item linked to [categoryId] and optional [parentId].
  Future<Todo> create({
    required String name,
    required String description,
    required DateTime? completedTime,
    required bool fix,
    required Priority priority,
    required List<String> tags,
    required int index,
    required int categoryId,
    int? parentId,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  });

  /// Returns all items sorted by index (with category/parent ids loaded).
  Future<List<Todo>> getAll();

  /// Returns the item with [id], or null when missing.
  Future<Todo?> getById(int id);

  /// Returns items belonging to the category with [categoryId].
  Future<List<Todo>> getByCategoryId(int categoryId);

  /// Returns direct child items of the parent with [parentId].
  Future<List<Todo>> getChildren(int parentId);

  /// Persists changes on an existing item (scalar fields; links unchanged).
  Future<void> update(Todo todo);

  /// Sets [status] on the parent and all descendant subtasks.
  Future<void> updateStatusWithSubtasks({
    required int parentId,
    required TodoStatus status,
  });

  /// Updates editable fields on an item and re-links [categoryId].
  Future<void> updateFields({
    required Todo todo,
    required String name,
    required String description,
    required DateTime? completedTime,
    required bool fix,
    required Priority priority,
    required List<String> tags,
    required int categoryId,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.clone,
    int? recurrenceMinuteOfDay,
  });

  /// Moves items in [todoIds] to [categoryId], detaching from external parents.
  Future<void> moveToCategory({
    required Set<int> todoIds,
    required int categoryId,
  });

  /// Reparents [rootIds] under [newParentId]; keeps in-subtree parent links.
  Future<void> moveToParent({
    required Set<int> rootIds,
    required Set<int> subtreeIds,
    int? newParentId,
    int? newCategoryId,
  });

  /// Persists sequential index values for [todos] (order in the list).
  Future<void> updateIndexes(List<Todo> todos);

  /// Deletes the item with [id].
  Future<void> delete(int id);

  /// Deletes all items whose ids are in [ids].
  Future<void> deleteBatch(Set<int> ids);

  /// Emits when any item collection change may have occurred.
  Stream<void> watchLazy();

  /// Returns the item with CalDAV [uid], or null.
  Future<Todo?> getByCalDavUid(String uid);

  /// Returns items that still need a CalDAV push.
  Future<List<Todo>> getDirtyCalDav();

  /// Returns items that already have a CalDAV UID.
  Future<List<Todo>> getWithCalDavUid();

  /// Next free global index.
  Future<int> nextIndex();

  /// Unique non-empty tags across all items, sorted case-insensitively.
  Future<List<String>> collectUniqueTags();

  /// Deletes every item row.
  Future<void> clearAll();
}
