import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/data/models/db.dart';

/// Shared Isar open logic for app startup and background notification handlers.
class IsarBootstrap {
  IsarBootstrap._();

  /// Isar collection schemas opened at app startup.
  static const _schemas = [TasksSchema, TodosSchema, SettingsSchema];

  /// Opens the app database and loads [Settings], recovering preferences when
  /// the Settings row cannot be deserialized (schema churn).
  ///
  /// Never wipes preferences without first trying the JSON sidecar backup.
  static Future<(Isar, Settings)> openAppIsarWithSettings({
    bool inspector = kDebugMode,
  }) async {
    final dir = await getApplicationSupportDirectory();
    final path = dir.path;

    Future<Isar> openMain() async {
      if (Isar.instanceNames.isNotEmpty) {
        return Isar.getInstance()!;
      }
      return Isar.open(_schemas, directory: path, inspector: inspector);
    }

    var isar = await openMain();
    await migrateToStatusField(isar);

    try {
      final settings = await isar.settings.where().findFirst() ?? Settings();
      return (isar, settings);
    } catch (e, stackTrace) {
      debugPrint(
        'Settings unreadable, recovering preferences: $e\n$stackTrace',
      );
      return _recoverSettings(
        isar: isar,
        directory: path,
        inspector: inspector,
      );
    }
  }

  /// Opens the app database, reusing an existing instance when present.
  static Future<Isar> openAppIsar({bool inspector = kDebugMode}) async {
    final (isar, _) = await openAppIsarWithSettings(inspector: inspector);
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

      if (!needsMigration) return;

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

  static Future<(Isar, Settings)> _recoverSettings({
    required Isar isar,
    required String directory,
    required bool inspector,
  }) async {
    await isar.close();

    final recovered = await SettingsJsonBackup.load(directory);

    final fresh = await Isar.open(
      _schemas,
      directory: directory,
      inspector: inspector,
    );
    await migrateToStatusField(fresh);

    final settings = recovered ?? Settings();
    settings.settingsSchemaVersion = AppConstants.settingsSchemaVersion;
    await persistSettings(fresh, settings, clearFirst: true);

    if (recovered != null) {
      debugPrint('Settings recovered from JSON sidecar and rewritten');
    } else {
      debugPrint(
        'Settings recovery found no backup; using defaults (tasks preserved)',
      );
    }

    return (fresh, settings);
  }
}
