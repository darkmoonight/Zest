import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/settings/app_settings_state.dart';
import 'package:zest/i18n/locale_utils.dart';
import 'package:zest/i18n/strings.g.dart';

/// Provides the in-memory app settings notifier state.
final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettingsState>(
      AppSettingsNotifier.new,
    );

/// Provides the current UI [Locale] from [appSettingsProvider].
final localeProvider = Provider<Locale>(
  (ref) => ref.watch(appSettingsProvider).locale,
);

/// Syncs persisted [Settings] into [AppSettingsState] and applies UI updates.
class AppSettingsNotifier extends Notifier<AppSettingsState> {
  /// Builds state from persisted settings, refreshing on revision changes.
  @override
  AppSettingsState build() {
    ref.watch(settingsRevisionProvider);
    return AppSettingsState.fromSettings(ref.watch(settingsProvider));
  }

  /// Applies partial setting changes and updates [LocaleSettings] when needed.
  void update({
    bool? amoledTheme,
    bool? materialColor,
    bool? isImage,
    String? timeformat,
    String? firstDay,
    Locale? locale,
  }) {
    state = state.copyWith(
      amoledTheme: amoledTheme,
      materialColor: materialColor,
      isImage: isImage,
      timeformat: timeformat,
      firstDay: firstDay,
      locale: locale,
    );
    if (locale != null) {
      LocaleSettings.setLocale(appLocaleFromFlutterLocale(locale));
    }
  }
}
