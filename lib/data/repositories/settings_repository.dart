import 'package:isar_community/isar.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/data/mappers/settings_mapper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/repositories/settings_repository.dart';

/// Reads and writes app settings from Isar.
///
/// Writes go to the live [Settings] from [liveSettingsProvider]; UI reads a
/// clone via [settingsProvider] after [settingsRevisionProvider] bumps (see
/// [SettingsWriter] / repository [onSaved]).
///
/// Cold-start recovery (JSON sidecar) lives in `IsarBootstrap`; this
/// repository only falls back to the JSON sidecar if a later read fails.
class SettingsRepository implements SettingsRepositoryPort {
  /// Creates a repository backed by [isar].
  SettingsRepository(this._isar, {this.onSaved});

  /// Isar database handle.
  final Isar _isar;

  /// Optional callback invoked after a successful [save].
  final void Function()? onSaved;

  @override
  /// Loads settings from Isar, or default [AppSettings] when none exist.
  ///
  /// On deserialize failure, restores from the JSON sidecar when available.
  Future<AppSettings> getSettings() async {
    try {
      final row = await _isar.settings.where().findFirst() ?? Settings();
      return SettingsMapper.toDomain(row);
    } catch (e) {
      final directory = _isar.directory;
      if (directory != null) {
        final backup = await SettingsJsonBackup.load(directory);
        if (backup != null) return SettingsMapper.toDomain(backup);
      }
      rethrow;
    }
  }

  @override
  /// Persists [settings] to Isar and the JSON sidecar, then invokes [onSaved].
  Future<void> save(AppSettings settings) async {
    final row = await _isar.settings.where().findFirst() ?? Settings();
    SettingsMapper.applyDomain(row, settings);
    await persistSettings(_isar, row);
    onSaved?.call();
  }
}
