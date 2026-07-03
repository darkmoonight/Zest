import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zest/data/models/db.dart';

/// Shared Isar open logic for app startup and background notification handlers.
class IsarBootstrap {
  IsarBootstrap._();

  /// Isar collection schemas opened at app startup.
  static const _schemas = [TasksSchema, TodosSchema, SettingsSchema];

  /// Opens the app database, reusing an existing instance when present.
  static Future<Isar> openAppIsar({bool inspector = kDebugMode}) async {
    if (Isar.instanceNames.isNotEmpty) {
      return Isar.getInstance()!;
    }

    final dir = await getApplicationSupportDirectory();
    final isar = await Isar.open(
      _schemas,
      directory: dir.path,
      inspector: inspector,
    );

    await migrateToStatusField(isar);
    return isar;
  }

  /// Acquires Isar for notification actions; returns whether this call opened it.
  static Future<(Isar?, bool)> acquireIsarForBackgroundHandler() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationSupportDirectory();
      final isar = await Isar.open(_schemas, directory: dir.path);
      return (isar, true);
    }
    return (Isar.getInstance(), false);
  }

  /// Migrates legacy `done` flag to [TodoStatus.done].
  static Future<void> migrateToStatusField(Isar isar) async {
    try {
      final todos = await isar.todos.where().findAll();
      final needsMigration = todos.any(
        (todo) => todo.done == true && todo.status == TodoStatus.active,
      );

      if (!needsMigration) {
        debugPrint('Migration: No migration needed');
        return;
      }

      var migratedCount = 0;
      await isar.writeTxn(() async {
        for (final todo in todos) {
          if (todo.done == true && todo.status == TodoStatus.active) {
            todo.status = TodoStatus.done;
            todo.todoCompletionTime ??= todo.createdTime;
            await isar.todos.put(todo);
            migratedCount++;
          }
        }
      });

      debugPrint(
        'Migration completed: Updated $migratedCount of ${todos.length} todos from done field to status field',
      );
    } catch (e) {
      debugPrint('Migration error: $e');
    }
  }
}
