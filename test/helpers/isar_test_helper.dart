import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:isar_community/isar.dart';
// Registers the native Isar core library for VM tests.
// ignore: unused_import
import 'package:isar_community_flutter_libs/isar_flutter_libs.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/settings_repository.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';

bool _isarCoreInitialized = false;

Future<void> ensureIsarTestCore() async {
  if (_isarCoreInitialized) return;
  await Isar.initializeIsarCore(download: true);
  _isarCoreInitialized = true;
}

/// Opens an isolated Isar database in a temporary directory for tests.
Future<Isar> openTestIsar() async {
  await ensureIsarTestCore();
  final tempDir = await Directory.systemTemp.createTemp('zest_test_');
  return Isar.open(
    [TasksSchema, TodosSchema, SettingsSchema],
    directory: tempDir.path,
    name: 'test_${tempDir.path.hashCode}',
  );
}

/// Closes [isar] and removes its on-disk files.
Future<void> closeTestIsar(Isar isar) async {
  final path = isar.directory;
  await isar.close(deleteFromDisk: true);
  if (path != null) {
    final dir = Directory(path);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}

Future<Settings> seedSettings(Isar isar, {Settings? settings}) async {
  final repo = SettingsRepository(isar);
  final value = settings ?? Settings();
  await repo.save(value);
  return value;
}

Future<Tasks> createTestTask(
  Isar isar, {
  String title = 'Test task',
  String description = '',
  Color color = Colors.blue,
  bool archive = false,
  int index = 0,
}) async {
  final task = await TaskRepository(
    isar,
  ).create(title: title, description: description, color: color, index: index);
  if (archive) {
    await TaskRepository(isar).updateArchiveStatus(task, true);
  }
  return task;
}

Future<Todos> createTestTodo(
  Isar isar, {
  required Tasks task,
  String name = 'Test todo',
  String description = '',
  DateTime? completedTime,
  TodoStatus status = TodoStatus.active,
  DateTime? completionTime,
  bool fix = false,
  Priority priority = Priority.none,
  List<String> tags = const [],
  int index = 0,
  Todos? parent,
}) {
  return TodoRepository(isar)
      .create(
        name: name,
        description: description,
        completedTime: completedTime,
        fix: fix,
        priority: priority,
        tags: tags,
        index: index,
        task: task,
        parent: parent,
      )
      .then((todo) async {
        if (status != TodoStatus.active || completionTime != null) {
          todo.status = status;
          todo.todoCompletionTime = completionTime;
          await TodoRepository(isar).update(todo);
        }
        return todo;
      });
}

/// Builds an in-memory [Todos] linked to [task] without persisting.
Todos buildTodo({
  required Tasks task,
  Todos? parent,
  int id = 1,
  String name = 'Todo',
  String description = '',
  DateTime? todoCompletedTime,
  DateTime? todoCompletionTime,
  TodoStatus status = TodoStatus.active,
  bool fix = false,
  Priority priority = Priority.none,
  List<String> tags = const [],
  int? index,
}) {
  final todo = Todos(
    id: id,
    name: name,
    description: description,
    todoCompletedTime: todoCompletedTime,
    todoCompletionTime: todoCompletionTime,
    createdTime: DateTime.now(),
    fix: fix,
    priority: priority,
    status: status,
    tags: tags,
    index: index,
  )..task.value = task;

  if (parent != null) {
    todo.parent.value = parent;
  }

  return todo;
}
