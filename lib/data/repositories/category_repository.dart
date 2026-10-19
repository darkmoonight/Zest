import 'package:isar_community/isar.dart';
import 'package:zest/data/mappers/category_mapper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/repositories/category_repository.dart';

/// Isar-backed CRUD and queries for categories ([Tasks] collection).
class CategoryRepository implements CategoryRepositoryPort {
  /// Creates a repository backed by [isar].
  CategoryRepository(this._isar);

  /// Isar database handle.
  final Isar _isar;

  // ==================== CREATE ====================

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
  }) async {
    final task = Tasks(
      title: title,
      description: description,
      taskColor: colorArgb,
      index: index,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    await _isar.writeTxn(() => _isar.tasks.put(task));
    return CategoryMapper.toDomain(task);
  }

  // ==================== READ ====================

  @override
  Future<List<Category>> getAll() async {
    final rows = await _isar.tasks.where().sortByIndex().findAll();
    return CategoryMapper.toDomainList(rows);
  }

  @override
  Future<Category?> getById(int id) async {
    final row = await _isar.tasks.get(id);
    return row == null ? null : CategoryMapper.toDomain(row);
  }

  @override
  Future<bool> existsByTitle(String title) async {
    final count = await _isar.tasks.filter().titleEqualTo(title).count();
    return count > 0;
  }

  // ==================== UPDATE ====================

  @override
  Future<void> update(Category category) async {
    final row = await _isar.tasks.get(category.id);
    if (row == null) return;
    CategoryMapper.applyDomain(row, category);
    await _isar.writeTxn(() => _isar.tasks.put(row));
  }

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
  }) async {
    final row = await _isar.tasks.get(category.id);
    if (row == null) return;

    await _isar.writeTxn(() async {
      row.title = title;
      row.description = description;
      row.taskColor = colorArgb;
      row.recurrence = recurrence;
      row.recurrenceWeekdays = recurrenceWeekdays;
      row.recurrenceMode = recurrenceMode;
      row.recurrenceMinuteOfDay = recurrenceMinuteOfDay;
      await _isar.tasks.put(row);
    });
  }

  @override
  Future<void> updateArchiveStatus(Category category, bool archived) async {
    final row = await _isar.tasks.get(category.id);
    if (row == null) return;
    await _isar.writeTxn(() async {
      row.archive = archived;
      await _isar.tasks.put(row);
    });
  }

  @override
  Future<void> updateArchiveStatusBatch(
    List<Category> categories,
    bool archived,
  ) async {
    if (categories.isEmpty) return;

    await _isar.writeTxn(() async {
      final rows = <Tasks>[];
      for (final category in categories) {
        final row = await _isar.tasks.get(category.id);
        if (row == null) continue;
        row.archive = archived;
        rows.add(row);
      }
      if (rows.isNotEmpty) {
        await _isar.tasks.putAll(rows);
      }
    });
  }

  @override
  Future<void> updateIndexes(List<Category> categories) async {
    if (categories.isEmpty) return;

    await _isar.writeTxn(() async {
      final rows = <Tasks>[];
      for (var i = 0; i < categories.length; i++) {
        final row = await _isar.tasks.get(categories[i].id);
        if (row == null) continue;
        row.index = i;
        rows.add(row);
      }
      if (rows.isNotEmpty) {
        await _isar.tasks.putAll(rows);
      }
    });
  }

  // ==================== DELETE ====================

  @override
  Future<void> delete(Category category) async {
    await _isar.writeTxn(() => _isar.tasks.delete(category.id));
  }

  // ==================== WATCH ====================

  @override
  Stream<void> watchLazy() {
    return _isar.tasks.watchLazy();
  }

  @override
  Future<void> clearAll() async {
    await _isar.writeTxn(() => _isar.tasks.clear());
  }

  @override
  Future<List<Category>> getActiveSorted() async {
    final tasks = await _isar.tasks.filter().archiveEqualTo(false).findAll();
    tasks.sort((a, b) {
      final aIndex = a.index ?? double.maxFinite.toInt();
      final bIndex = b.index ?? double.maxFinite.toInt();
      return aIndex.compareTo(bIndex);
    });
    return CategoryMapper.toDomainList(tasks);
  }
}
