import 'package:isar_community/isar.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/data/models/db.dart';

/// Reads and writes app settings from Isar.
///
/// The UI mutates the same [Settings] instance exposed by [settingsProvider];
/// [save] persists that object back to the database.
///
/// Cold-start recovery (JSON sidecar) lives in `IsarBootstrap`; this
/// repository only falls back to the JSON sidecar if a later read fails.
class SettingsRepository {
  /// Creates a repository backed by [isar].
  SettingsRepository(this._isar, {this.onSaved});

  /// Isar database handle.
  final Isar _isar;

  /// Optional callback invoked after a successful [save].
  final void Function()? onSaved;

  /// Loads settings from Isar, or default [Settings] when none exist.
  ///
  /// On deserialize failure, restores from the JSON sidecar when available.
  Future<Settings> getSettings() async {
    try {
      return await _isar.settings.where().findFirst() ?? Settings();
    } catch (e) {
      final directory = _isar.directory;
      if (directory != null) {
        final backup = await SettingsJsonBackup.load(directory);
        if (backup != null) return backup;
      }
      rethrow;
    }
  }

  /// Persists [settings] to Isar and the JSON sidecar, then invokes [onSaved].
  Future<void> save(Settings settings) async {
    await persistSettings(_isar, settings);
    onSaved?.call();
  }
}
