import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:isar_community/isar.dart';
// Registers the native Isar core library for VM tests.
// ignore: unused_import
import 'package:isar_community_flutter_libs/isar_flutter_libs.dart';
import 'package:zest/data/mappers/settings_mapper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/category_repository.dart';
import 'package:zest/data/repositories/settings_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/entities/todo.dart';

bool _isarCoreInitialized = false;

/// True when the last [openTestIsar] call hit an Isar core version mismatch.
bool isarCoreUnavailable = false;

bool _isIsarCoreVersionMismatch(Object error) =>
    error.toString().contains('Incorrect Isar Core version');

/// Preferred native core from the resolved [isar_community_flutter_libs] package.
String? _bundledLinuxIsarCore() {
  if (!Platform.isLinux) return null;
  try {
    final uri = Isolate.resolvePackageUriSync(
      Uri.parse('package:isar_community_flutter_libs/isar_flutter_libs.dart'),
    );
    if (uri == null || !uri.isScheme('file')) return null;
    final packageRoot = Directory.fromUri(uri).parent.parent;
    final candidate = File('${packageRoot.path}/linux/libisar.so');
    return candidate.existsSync() ? candidate.path : null;
  } catch (_) {
    return null;
  }
}

Future<void> ensureIsarTestCore() async {
  if (_isarCoreInitialized) return;
  try {
    final bundled = _bundledLinuxIsarCore();
    if (bundled != null) {
      await Isar.initializeIsarCore(
        libraries: {Abi.linuxX64: bundled, Abi.linuxArm64: bundled},
      );
    } else {
      await Isar.initializeIsarCore(download: true);
    }
    _isarCoreInitialized = true;
    isarCoreUnavailable = false;
  } on IsarError catch (e) {
    if (_isIsarCoreVersionMismatch(e)) {
      isarCoreUnavailable = true;
      markTestSkipped(
        'Isar core version mismatch (package wants 3.4.1; env binary differs). '
        'Delete stale project-root libisar.so or align isar_community_flutter_libs.',
      );
    }
    rethrow;
  }
}

/// No-op when [isarCoreUnavailable]; otherwise runs [body].
///
/// Use in `tearDown` so skipped Isar setUps do not hit LateInitializationError.
Future<void> closeTestIsarIfReady(Future<void> Function() body) async {
  if (isarCoreUnavailable) return;
  await body();
}

/// Opens an isolated Isar database in a temporary directory for tests.
///
/// On Isar core version mismatch, marks the current test skipped and rethrows.
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
Future<void> closeTestIsar(Isar? isar) async {
  if (isar == null || isarCoreUnavailable) return;
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
  await repo.save(SettingsMapper.toDomain(value));
  return value;
}

/// Creates a domain [Category] (Isar [Tasks] row) for tests.
Future<Category> createTestTask(
  Isar isar, {
  String title = 'Test task',
  String description = '',
  Color color = Colors.blue,
  bool archive = false,
  int index = 0,
}) async {
  final repo = CategoryRepository(isar);
  final category = await repo.create(
    title: title,
    description: description,
    colorArgb: color.toARGB32(),
    index: index,
  );
  if (archive) {
    await repo.updateArchiveStatus(category, true);
    return category.copyWith(archive: true);
  }
  return category;
}

/// Creates a domain [Todo] under [task] for tests.
Future<Todo> createTestTodo(
  Isar isar, {
  required Category task,
  String name = 'Test todo',
  String description = '',
  DateTime? completedTime,
  TodoStatus status = TodoStatus.active,
  DateTime? completionTime,
  bool fix = false,
  Priority priority = Priority.none,
  List<String> tags = const [],
  int index = 0,
  Todo? parent,
}) async {
  final repo = TodoRepository(isar);
  var todo = await repo.create(
    name: name,
    description: description,
    completedTime: completedTime,
    fix: fix,
    priority: priority,
    tags: tags,
    index: index,
    categoryId: task.id,
    parentId: parent?.id,
  );
  if (status != TodoStatus.active || completionTime != null) {
    todo = todo.copyWith(
      status: status,
      completedAt: completionTime,
      clearCompletedAt: completionTime == null,
    );
    await repo.update(todo);
  }
  return todo;
}

/// Builds an in-memory domain [Todo] linked to [task] without persisting.
Todo buildTodo({
  required Category task,
  Todo? parent,
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
  return Todo(
    id: id,
    name: name,
    description: description,
    dueAt: todoCompletedTime,
    completedAt: todoCompletionTime,
    createdAt: DateTime.now(),
    fix: fix,
    priority: priority,
    status: status,
    tags: tags,
    index: index,
    categoryId: task.id,
    parentId: parent?.id,
  );
}
