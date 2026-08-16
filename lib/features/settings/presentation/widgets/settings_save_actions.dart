import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/app.dart';
import 'package:zest/core/bootstrap/notification_bootstrap.dart';
import 'package:zest/core/bootstrap/notification_callback_wiring.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Shared save and side-effect helpers for settings sections.
class SettingsSaveActions {
  /// Creates helpers bound to the settings [ref].
  SettingsSaveActions(this.ref);

  /// Riverpod ref used to read settings and repositories.
  final WidgetRef ref;

  /// Live mutable [Settings] from [liveSettingsProvider] (writes go here).
  Settings get settings => ref.read(liveSettingsProvider);

  /// Applies [mutate] immediately and persists in the background.
  void saveSettingsOptimistic({
    required void Function(Settings settings) mutate,
    VoidCallback? onOptimistic,
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) {
    final rollback = _SettingsRollback.capture(settings);
    mutate(settings);
    ref.read(settingsRevisionProvider.notifier).bump();
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
    ref.read(settingsRevisionProvider.notifier).bump();
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

  /// Enables or disables screen privacy via [PlatformFeatures] and persists.
  Future<void> saveScreenPrivacy(bool enabled) async {
    try {
      await PlatformFeatures.setScreenPrivacy(enabled);
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

  /// Saves snooze duration and refreshes pending notification action labels.
  Future<void> saveSnoozeDuration(int minutes) async {
    saveSettingsOptimistic(
      mutate: (s) => s.snoozeDuration = minutes,
      afterSave: _refreshNotificationActionLabels,
      backgroundAfterSave: true,
    );
  }

  /// Triggers an immediate auto-backup and returns whether it succeeded.
  Future<bool> createAutoBackupNow() async {
    return AutoBackupService.performManualAutoBackup(ref.read(isarProvider));
  }

  /// Re-inits categories and reschedules reminders with current snooze labels.
  Future<void> _refreshNotificationActionLabels() async {
    final settings = this.settings;
    final callbacks = notificationPluginResponseCallbacks();
    await initializeNotificationsPlugin(
      onDidReceiveNotificationResponse: callbacks.onForeground,
      onDidReceiveBackgroundNotificationResponse: callbacks.onBackground,
      snoozeMinutes: settings.snoozeDuration,
    );

    final items = await ref.read(todoRepositoryProvider).getAll();
    await ref
        .read(notificationServiceProvider)
        .rescheduleActiveReminders(items, settings: settings);
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
  _SettingsRollback._(this._snapshot);

  final Settings _snapshot;

  /// Snapshots all mutable fields from [settings].
  static _SettingsRollback capture(Settings settings) =>
      _SettingsRollback._(settings.clone());

  /// Restores the captured snapshot onto [settings].
  void restore(Settings settings) => settings.copyValuesFrom(_snapshot);
}
