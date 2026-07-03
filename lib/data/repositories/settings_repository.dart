import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';

/// Reads and writes app settings from Isar.
///
/// The UI mutates the same [Settings] instance exposed by [settingsProvider];
/// [save] persists that object back to the database.
class SettingsRepository {
  /// Creates a repository backed by [isar].
  SettingsRepository(this._isar, {this.onSaved});

  /// Isar database handle.
  final Isar _isar;

  /// Optional callback invoked after a successful [save].
  final void Function()? onSaved;

  /// Loads settings from Isar, or default [Settings] when none exist.
  Future<Settings> getSettings() async =>
      await _isar.settings.where().findFirst() ?? Settings();

  /// Persists [settings] and invokes [onSaved] when set.
  Future<void> save(Settings settings) async {
    await _isar.writeTxn(() => _isar.settings.put(settings));
    onSaved?.call();
  }
}
