import 'package:isar_community/isar.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/data/models/db.dart';

/// Persists [settings] to Isar and the JSON sidecar next to the database.
///
/// When [clearFirst] is true, the Settings collection is cleared before put
/// (Rain-style rewrite / recovery).
Future<void> persistSettings(
  Isar isar,
  Settings settings, {
  bool clearFirst = false,
}) async {
  await isar.writeTxn(() async {
    if (clearFirst) {
      await isar.settings.clear();
    }
    await isar.settings.put(settings);
  });

  final directory = isar.directory;
  if (directory != null) {
    await SettingsJsonBackup.save(directory, settings);
  }
}
