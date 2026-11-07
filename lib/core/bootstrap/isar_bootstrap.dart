import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/core/utils/app_log.dart';

/// Shared Isar open logic for app startup and background notification handlers.
class IsarBootstrap {
  IsarBootstrap._();

  /// App collection schemas.
  static const schemas = [TasksSchema, TodosSchema, SettingsSchema];

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
      return Isar.open(schemas, directory: path, inspector: inspector);
    }

    var isar = await openMain();

    try {
      final settings = await isar.settings.where().findFirst() ?? Settings();
      return (isar, settings);
    } catch (e, stackTrace) {
      AppLog.d('Settings unreadable, recovering preferences: $e\n$stackTrace');
      return _recoverSettings(
        isar: isar,
        directory: path,
        inspector: inspector,
      );
    }
  }

  /// Acquires Isar for notification actions; returns whether this call opened it.
  static Future<(Isar?, bool)> acquireIsarForBackgroundHandler() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationSupportDirectory();
      final isar = await Isar.open(schemas, directory: dir.path);
      return (isar, true);
    }
    return (Isar.getInstance(), false);
  }

  static Future<(Isar, Settings)> _recoverSettings({
    required Isar isar,
    required String directory,
    required bool inspector,
  }) async {
    await isar.close();

    final recovered = await SettingsJsonBackup.load(directory);

    final fresh = await Isar.open(
      schemas,
      directory: directory,
      inspector: inspector,
    );

    final settings = recovered ?? Settings();
    settings.settingsSchemaVersion = AppConstants.settingsSchemaVersion;
    await persistSettings(fresh, settings, clearFirst: true);

    if (recovered != null) {
      AppLog.d('Settings recovered from JSON sidecar and rewritten');
    } else {
      AppLog.d(
        'Settings recovery found no backup; using defaults (tasks preserved)',
      );
    }

    return (fresh, settings);
  }
}
