import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/settings/settings_writer.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/i18n/tr.dart';

/// Provides the persisted theme mode preference as [ThemeMode].
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// User-visible label for a persisted theme preference.
String themePreferenceLabel(String? themeKey) =>
    (themeKey ?? AppConstants.defaultTheme).tr;

/// Persists and exposes theme mode; also saves AMOLED and Material You toggles.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  /// Initializes theme mode from persisted [Settings].
  @override
  ThemeMode build() => _fromSettings(ref.watch(settingsProvider));

  /// Maps stored theme string to [ThemeMode].
  ThemeMode _fromSettings(Settings settings) {
    switch (settings.theme) {
      case AppConstants.themeDark:
        return ThemeMode.dark;
      case AppConstants.themeLight:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _write(void Function(Settings) mutate) {
    return SettingsWriter.write(
      settings: ref.read(liveSettingsProvider),
      revision: ref.read(settingsRevisionProvider.notifier),
      repository: ref.read(settingsRepositoryProvider),
      mutate: mutate,
    );
  }

  /// Persists the selected theme mode string and refreshes state.
  Future<void> setTheme(String themeMode) async {
    await _write((s) => s.theme = themeMode);
    state = _fromSettings(ref.read(liveSettingsProvider));
  }

  /// Persists the AMOLED (pure black) theme toggle.
  Future<void> saveOledTheme(bool isOled) async {
    await _write((s) => s.amoledTheme = isOled);
  }

  /// Persists the Material You dynamic color toggle.
  Future<void> saveMaterialTheme(bool isMaterial) async {
    await _write((s) => s.materialColor = isMaterial);
  }
}
