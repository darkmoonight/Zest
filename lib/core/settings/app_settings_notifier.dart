import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/settings/app_settings_state.dart';

/// UI-facing settings snapshot derived from [settingsProvider].
///
/// Prefer [settingsProvider] for domain fields; use this when you need
/// Flutter [Locale] or the non-null UI defaults in [AppSettingsState].
final appSettingsProvider = Provider<AppSettingsState>((ref) {
  return AppSettingsState.fromSettings(ref.watch(settingsProvider));
});

/// Provides the current UI [Locale] from [appSettingsProvider].
final localeProvider = Provider<Locale>(
  (ref) => ref.watch(appSettingsProvider.select((s) => s.locale)),
);
