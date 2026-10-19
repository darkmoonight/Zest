import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/enums/enums.dart';

/// Port for category persistence and queries (domain [Category]).
abstract interface class CategoryRepositoryPort {
  /// Creates a category with [title], [description], [colorArgb], and [index].
  Future<Category> create({
    required String title,
    required String description,
    required int colorArgb,
    required int index,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  });

  /// Returns all categories sorted by index.
  Future<List<Category>> getAll();

  /// Returns the category with [id], or null when missing.
  Future<Category?> getById(int id);

  /// Whether a category with [title] already exists.
  Future<bool> existsByTitle(String title);

  /// Persists changes on an existing [category].
  Future<void> update(Category category);

  /// Updates editable fields on [category].
  Future<void> updateFields({
    required Category category,
    required String title,
    required String description,
    required int colorArgb,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  });

  /// Sets [category] archive flag to [archived].
  Future<void> updateArchiveStatus(Category category, bool archived);

  /// Sets archive flag to [archived] on all [categories].
  Future<void> updateArchiveStatusBatch(
    List<Category> categories,
    bool archived,
  );

  /// Persists sequential index values for [categories] (order in the list).
  Future<void> updateIndexes(List<Category> categories);

  /// Deletes [category].
  Future<void> delete(Category category);

  /// Emits when any category collection change may have occurred.
  Stream<void> watchLazy();

  /// Deletes every category row.
  Future<void> clearAll();

  /// Active (non-archived) categories sorted by index.
  Future<List<Category>> getActiveSorted();
}
