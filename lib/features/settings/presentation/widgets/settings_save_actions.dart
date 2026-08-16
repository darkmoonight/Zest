import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/bootstrap/notification_callback_wiring.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/core/settings/settings_writer.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/i18n/locale_utils.dart';
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
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) {
    SettingsWriter.writeOptimistic(
      settings: settings,
      revision: ref.read(settingsRevisionProvider.notifier),
      repository: ref.read(settingsRepositoryProvider),
      mutate: mutate,
      afterSave: afterSave,
      backgroundAfterSave: backgroundAfterSave,
    );
  }

  /// Updates app locale, persists the choice, refreshes UI, and re-registers
  /// Android notification channel names for the new language.
  Future<void> updateLanguage(Locale locale) async {
    await SettingsWriter.write(
      settings: settings,
      revision: ref.read(settingsRevisionProvider.notifier),
      repository: ref.read(settingsRepositoryProvider),
      mutate: (s) => s.language = '$locale',
    );
    await applyAppLocale(appLocaleFromFlutterLocale(locale));
    final plugin = NotificationPlugin.instance;
    if (plugin != null) {
      unawaited(registerAndroidNotificationChannels(plugin));
    }
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

  /// Saves the clock time format.
  Future<void> saveTimeFormat(String format) async {
    saveSettingsOptimistic(mutate: (s) => s.timeformat = format);
  }

  /// Saves the calendar first day of week.
  Future<void> saveFirstDayOfWeek(String day) async {
    saveSettingsOptimistic(mutate: (s) => s.firstDay = day);
  }

  /// Saves snooze duration, then [refreshActiveReminderLabels] (no plugin re-init).
  Future<void> saveSnoozeDuration(int minutes) async {
    saveSettingsOptimistic(
      mutate: (s) => s.snoozeDuration = minutes,
      afterSave: () => refreshActiveReminderLabels(
        todoRepo: ref.read(todoRepositoryProvider),
        notificationService: ref.read(notificationServiceProvider),
        settings: settings,
      ),
      backgroundAfterSave: true,
    );
  }

  /// Triggers an immediate auto-backup and returns whether it succeeded.
  Future<bool> createAutoBackupNow() async {
    return AutoBackupService.performManualAutoBackup(ref.read(isarProvider));
  }
}
