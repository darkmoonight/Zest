import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';

/// Isar-backed CRUD and queries for [Tasks].
class TaskRepository {
  /// Creates a repository backed by [isar].
  TaskRepository(this._isar);

  /// Isar database handle.
  final Isar _isar;

  // ==================== CREATE ====================

  /// Creates a task with [title], [description], [color], and [index].
  Future<Tasks> create({
    required String title,
    required String description,
    required Color color,
    required int index,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    final task = Tasks(
      title: title,
      description: description,
      taskColor: color.value32bit,
      index: index,
      recurrence: recurrence,
      recurrenceWeekdays: recurrenceWeekdays,
      recurrenceMode: recurrenceMode,
      recurrenceMinuteOfDay: recurrenceMinuteOfDay,
    );

    await _isar.writeTxn(() => _isar.tasks.put(task));
    return task;
  }

  // ==================== READ ====================

  /// Returns all tasks sorted by [Tasks.index].
  Future<List<Tasks>> getAll() async {
    return await _isar.tasks.where().sortByIndex().findAll();
  }

  /// Returns the task with [id], or null when missing.
  Future<Tasks?> getById(int id) async {
    return await _isar.tasks.get(id);
  }

  /// Whether a task with [title] already exists.
  Future<bool> existsByTitle(String title) async {
    final count = await _isar.tasks.filter().titleEqualTo(title).count();
    return count > 0;
  }

  // ==================== UPDATE ====================

  /// Persists changes on an existing [task].
  Future<void> update(Tasks task) async {
    await _isar.writeTxn(() => _isar.tasks.put(task));
  }

  /// Updates editable fields on [task].
  Future<void> updateFields({
    required Tasks task,
    required String title,
    required String description,
    required Color color,
    RecurrenceFrequency recurrence = RecurrenceFrequency.none,
    List<int> recurrenceWeekdays = const [],
    RecurrenceMode recurrenceMode = RecurrenceMode.reopen,
    int? recurrenceMinuteOfDay,
  }) async {
    await _isar.writeTxn(() async {
      task.title = title;
      task.description = description;
      task.taskColor = color.value32bit;
      task.recurrence = recurrence;
      task.recurrenceWeekdays = recurrenceWeekdays;
      task.recurrenceMode = recurrenceMode;
      task.recurrenceMinuteOfDay = recurrenceMinuteOfDay;
      await _isar.tasks.put(task);
    });
  }

  /// Sets [task] archive flag to [archived].
  Future<void> updateArchiveStatus(Tasks task, bool archived) async {
    await _isar.writeTxn(() async {
      task.archive = archived;
      await _isar.tasks.put(task);
    });
  }

  /// Sets archive flag to [archived] on all [tasks].
  Future<void> updateArchiveStatusBatch(
    List<Tasks> tasks,
    bool archived,
  ) async {
    if (tasks.isEmpty) return;

    await _isar.writeTxn(() async {
      for (final task in tasks) {
        task.archive = archived;
      }
      await _isar.tasks.putAll(tasks);
    });
  }

  /// Persists sequential [Tasks.index] values for [tasks].
  Future<void> updateIndexes(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    await _isar.writeTxn(() async {
      for (int i = 0; i < tasks.length; i++) {
        tasks[i].index = i;
      }
      await _isar.tasks.putAll(tasks);
    });
  }

  // ==================== DELETE ====================

  /// Deletes [task] from Isar.
  Future<void> delete(Tasks task) async {
    await _isar.writeTxn(() => _isar.tasks.delete(task.id));
  }

  // ==================== WATCH ====================

  /// Emits when any task collection change may have occurred.
  Stream<void> watchLazy() {
    return _isar.tasks.watchLazy();
  }
}
