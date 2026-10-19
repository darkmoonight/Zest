import 'package:zest/domain/entities/app_settings.dart';

/// Port for reading and writing app [AppSettings].
abstract interface class SettingsRepositoryPort {
  /// Loads settings, or default [AppSettings] when none exist.
  Future<AppSettings> getSettings();

  /// Persists [settings], then invokes any registered save hook.
  Future<void> save(AppSettings settings);
}
