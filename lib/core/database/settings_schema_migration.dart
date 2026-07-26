import 'package:isar_community/isar.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/data/models/db.dart';

/// Re-saves [Settings] when the Isar property layout changes (Rain recipe).
///
/// Reads the in-memory [settings] values, clears the collection, then writes
/// them back so on-disk property ids match the current schema.
///
/// Returns `true` when migration ran and [settings] was persisted.
Future<bool> performSettingsSchemaMigrationIfNeeded(
  Isar isar,
  Settings settings,
) async {
  if (settings.settingsSchemaVersion >= AppConstants.settingsSchemaVersion) {
    return false;
  }

  settings.settingsSchemaVersion = AppConstants.settingsSchemaVersion;
  await persistSettings(isar, settings, clearFirst: true);
  return true;
}
