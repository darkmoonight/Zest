import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/main.dart';

class TaskRepository {
  final Isar _isar = isar;

  // ==================== CREATE ====================

  Future<Tasks> create({
    required String title,
    required String description,
    required Color color,
    required int index,
  }) async {
    final task = Tasks(
      title: title,
      description: description,
      taskColor: color.value32bit,
      index: index,
    );

    await _isar.writeTxn(() => _isar.tasks.put(task));
    return task;
  }

  // ==================== READ ====================

  List<Tasks> getAll() {
    return _isar.tasks.where().sortByIndex().findAllSync();
  }

  Tasks? getById(int id) {
    return _isar.tasks.getSync(id);
  }

  bool existsByTitle(String title) {
    final count = _isar.tasks.filter().titleEqualTo(title).countSync();
    return count > 0;
  }

  List<Tasks> getByArchiveStatus(bool archived) {
    return _isar.tasks
        .filter()
        .archiveEqualTo(archived)
        .sortByIndex()
        .findAllSync();
  }

  // ==================== UPDATE ====================

  Future<void> update(Tasks task) async {
    await _isar.writeTxn(() => _isar.tasks.put(task));
  }

  Future<void> updateFields({
    required Tasks task,
    required String title,
    required String description,
    required Color color,
  }) async {
    await _isar.writeTxn(() async {
      task.title = title;
      task.description = description;
      task.taskColor = color.value32bit;
      await _isar.tasks.put(task);
    });
  }

  Future<void> archive(Tasks task) async {
    await _isar.writeTxn(() async {
      task.archive = true;
      await _isar.tasks.put(task);
    });
  }

  Future<void> unarchive(Tasks task) async {
    await _isar.writeTxn(() async {
      task.archive = false;
      await _isar.tasks.put(task);
    });
  }

  Future<void> archiveBatch(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    await _isar.writeTxn(() async {
      for (final task in tasks) {
        task.archive = true;
      }
      await _isar.tasks.putAll(tasks);
    });
  }

  Future<void> unarchiveBatch(List<Tasks> tasks) async {
    if (tasks.isEmpty) return;

    await _isar.writeTxn(() async {
      for (final task in tasks) {
        task.archive = false;
      }
      await _isar.tasks.putAll(tasks);
    });
  }

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

  Future<void> delete(Tasks task) async {
    await _isar.writeTxn(() => _isar.tasks.delete(task.id));
  }

  Future<void> deleteByIds(List<int> ids) async {
    if (ids.isEmpty) return;

    await _isar.writeTxn(() async {
      await _isar.tasks.deleteAll(ids);
    });
  }

  // ==================== WATCH ====================

  Stream<void> watchLazy() {
    return _isar.tasks.watchLazy();
  }
}
