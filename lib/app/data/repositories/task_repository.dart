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

  Future<List<Tasks>> getAll() async {
    return await _isar.tasks.where().sortByIndex().findAll();
  }

  Future<Tasks?> getById(int id) async {
    return await _isar.tasks.get(id);
  }

  Future<bool> existsByTitle(String title) async {
    final count = await _isar.tasks.filter().titleEqualTo(title).count();
    return count > 0;
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

  Future<void> updateArchiveStatus(Tasks task, bool archived) async {
    await _isar.writeTxn(() async {
      task.archive = archived;
      await _isar.tasks.put(task);
    });
  }

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

  // ==================== WATCH ====================

  Stream<void> watchLazy() {
    return _isar.tasks.watchLazy();
  }
}
