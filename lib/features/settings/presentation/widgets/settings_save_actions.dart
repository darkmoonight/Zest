import 'dart:async';

import 'package:flag_secure/flag_secure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/app.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/data/models/db.dart';

/// Shared save and side-effect helpers for settings sections.
class SettingsSaveActions {
  SettingsSaveActions(this.ref);

  /// Riverpod ref used to read settings and repositories.
  final WidgetRef ref;

  Settings get settings => ref.read(settingsProvider);

  /// Persists the current [settings] snapshot to Isar.
  Future<void> saveSettings({
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) async {
    await _persistSettings(
      afterSave: afterSave,
      backgroundAfterSave: backgroundAfterSave,
    );
  }

  /// Applies [mutate] immediately and persists in the background.
  void saveSettingsOptimistic({
    required void Function(Settings settings) mutate,
    VoidCallback? onOptimistic,
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) {
    final rollback = _SettingsRollback.capture(settings);
    mutate(settings);
    onOptimistic?.call();
    unawaited(
      _persistSettings(
        afterSave: afterSave,
        backgroundAfterSave: backgroundAfterSave,
        rollback: rollback,
      ),
    );
  }

  /// Updates app locale, persists the choice, refreshes UI, and re-registers
  /// Android notification channel names for the new language.
  Future<void> updateLanguage(Locale locale) async {
    settings.language = '$locale';
    ZestApp.updateAppState(ref, newLocale: locale);

    final plugin = NotificationPlugin.instance;
    if (plugin != null) {
      unawaited(registerAndroidNotificationChannels(plugin));
    }

    unawaited(_persistSettings());
  }

  /// Saves the default home screen preference optimistically.
  Future<void> updateDefaultScreen(String defaultScreen) async {
    saveSettingsOptimistic(mutate: (s) => s.defaultScreen = defaultScreen);
  }

  /// Enables or disables screen privacy via [FlagSecure] and persists the flag.
  Future<void> saveScreenPrivacy(bool enabled) async {
    try {
      if (enabled) {
        await FlagSecure.set();
      } else {
        await FlagSecure.unset();
      }
      saveSettingsOptimistic(mutate: (s) => s.screenPrivacy = enabled);
    } on PlatformException {
      // Platform may not support FLAG_SECURE.
    }
  }

  /// Saves the clock time format and updates app-wide formatting.
  Future<void> saveTimeFormat(String format) async {
    saveSettingsOptimistic(
      mutate: (s) => s.timeformat = format,
      onOptimistic: () => ZestApp.updateAppState(ref, newTimeformat: format),
    );
  }

  /// Saves the calendar first day of week and updates app state.
  Future<void> saveFirstDayOfWeek(String day) async {
    saveSettingsOptimistic(
      mutate: (s) => s.firstDay = day,
      onOptimistic: () => ZestApp.updateAppState(ref, newFirstDay: day),
    );
  }

  /// Triggers an immediate auto-backup and returns whether it succeeded.
  Future<bool> createAutoBackupNow() async {
    return AutoBackupService.performManualAutoBackup(ref.read(isarProvider));
  }

  /// Run in background.
  void runInBackground(Future<void> Function()? action) {
    if (action != null) unawaited(action());
  }

  Future<void> _persistSettings({
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
    _SettingsRollback? rollback,
  }) async {
    try {
      await ref.read(settingsRepositoryProvider).save(settings);
      if (afterSave != null) {
        if (backgroundAfterSave) {
          unawaited(afterSave());
        } else {
          await afterSave();
        }
      }
    } catch (e, stackTrace) {
      rollback?.restore(settings);
      ref.read(settingsRevisionProvider.notifier).bump();
      debugPrint('Failed to save settings: $e\n$stackTrace');
    }
  }
}

/// Captures mutable [Settings] fields for rollback on failed persist.
class _SettingsRollback {
  _SettingsRollback({
    required this.language,
    required this.defaultScreen,
    required this.screenPrivacy,
    required this.timeformat,
    required this.firstDay,
    required this.isImage,
    required this.autoBackupEnabled,
    required this.autoBackupPath,
    required this.autoBackupFrequency,
    required this.maxAutoBackups,
    required this.snoozeDuration,
    required this.colorPalette,
    required this.appFont,
  });

  final String? language;
  final String defaultScreen;
  final bool? screenPrivacy;
  final String timeformat;
  final String firstDay;
  final bool? isImage;
  final bool autoBackupEnabled;
  final String? autoBackupPath;
  final AutoBackupFrequency autoBackupFrequency;
  final int maxAutoBackups;
  final int snoozeDuration;
  final String colorPalette;
  final String appFont;

  static _SettingsRollback capture(Settings settings) {
    return _SettingsRollback(
      language: settings.language,
      defaultScreen: settings.defaultScreen,
      screenPrivacy: settings.screenPrivacy,
      timeformat: settings.timeformat,
      firstDay: settings.firstDay,
      isImage: settings.isImage,
      autoBackupEnabled: settings.autoBackupEnabled,
      autoBackupPath: settings.autoBackupPath,
      autoBackupFrequency: settings.autoBackupFrequency,
      maxAutoBackups: settings.maxAutoBackups,
      snoozeDuration: settings.snoozeDuration,
      colorPalette: settings.colorPalette,
      appFont: settings.appFont,
    );
  }

  void restore(Settings settings) {
    settings.language = language;
    settings.defaultScreen = defaultScreen;
    settings.screenPrivacy = screenPrivacy;
    settings.timeformat = timeformat;
    settings.firstDay = firstDay;
    settings.isImage = isImage;
    settings.autoBackupEnabled = autoBackupEnabled;
    settings.autoBackupPath = autoBackupPath;
    settings.autoBackupFrequency = autoBackupFrequency;
    settings.maxAutoBackups = maxAutoBackups;
    settings.snoozeDuration = snoozeDuration;
    settings.colorPalette = colorPalette;
    settings.appFont = appFont;
  }
}
