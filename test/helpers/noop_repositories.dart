import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/domain/repositories/todo_repository.dart';

/// Stub [TodoRepositoryPort] for pure unit tests that never touch persistence.
class NoopTodoRepository implements TodoRepositoryPort {
  Never _unused() => throw UnsupportedError('NoopTodoRepository');

  @override
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
  }) => _unused();

  @override
  Future<List<Todo>> getAll() => _unused();

  @override
  Future<Todo?> getById(int id) => _unused();

  @override
  Future<List<Todo>> getByCategoryId(int categoryId) => _unused();

  @override
  Future<List<Todo>> getChildren(int parentId) => _unused();

  @override
  Future<void> update(Todo todo) => _unused();

  @override
  Future<void> updateStatusWithSubtasks({
    required int parentId,
    required TodoStatus status,
  }) => _unused();

  @override
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
  }) => _unused();

  @override
  Future<void> moveToCategory({
    required Set<int> todoIds,
    required int categoryId,
  }) => _unused();

  @override
  Future<void> moveToParent({
    required Set<int> rootIds,
    required Set<int> subtreeIds,
    int? newParentId,
    int? newCategoryId,
  }) => _unused();

  @override
  Future<void> updateIndexes(List<Todo> todos) => _unused();

  @override
  Future<void> delete(int id) => _unused();

  @override
  Future<void> deleteBatch(Set<int> ids) => _unused();

  @override
  Stream<void> watchLazy() => _unused();

  @override
  Future<Todo?> getByCalDavUid(String uid) => _unused();

  @override
  Future<List<Todo>> getDirtyCalDav() => _unused();

  @override
  Future<List<Todo>> getWithCalDavUid() => _unused();

  @override
  Future<int> nextIndex() => _unused();

  @override
  Future<List<String>> collectUniqueTags() => _unused();

  @override
  Future<void> clearAll() => _unused();
}

/// Stub [CategoryRepositoryPort] for pure unit tests that never touch persistence.
class NoopCategoryRepository implements CategoryRepositoryPort {
  Never _unused() => throw UnsupportedError('NoopCategoryRepository');

  @override
  Future<Category> create({
    required String title,
    required String description,
    required int colorArgb,
    required int index,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) => _unused();

  @override
  Future<List<Category>> getAll() => _unused();

  @override
  Future<Category?> getById(int id) => _unused();

  @override
  Future<bool> existsByTitle(String title) => _unused();

  @override
  Future<void> update(Category category) => _unused();

  @override
  Future<void> updateFields({
    required Category category,
    required String title,
    required String description,
    required int colorArgb,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) => _unused();

  @override
  Future<void> updateArchiveStatus(Category category, bool archived) =>
      _unused();

  @override
  Future<void> updateArchiveStatusBatch(
    List<Category> categories,
    bool archived,
  ) => _unused();

  @override
  Future<void> updateIndexes(List<Category> categories) => _unused();

  @override
  Future<void> delete(Category category) => _unused();

  @override
  Stream<void> watchLazy() => _unused();

  @override
  Future<void> clearAll() => _unused();

  @override
  Future<List<Category>> getActiveSorted() => _unused();
}
