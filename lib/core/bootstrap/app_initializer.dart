import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/bootstrap/isar_bootstrap.dart';
import 'package:zest/core/bootstrap/app_bootstrap.dart';
import 'package:zest/core/bootstrap/notification_bootstrap.dart';
import 'package:zest/core/bootstrap/notification_callback_wiring.dart';
import 'package:zest/core/bootstrap/notification_handlers.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/core/database/settings_schema_migration.dart';
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/core/notifications/notification_migration.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/core/services/recurrence_background_scheduler.dart';
import 'package:zest/core/utils/device_info.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/i18n/locale_utils.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// One-time startup: platform hooks, DB, locale, and notifications.
class AppInitializer {
  /// Runs bootstrap in order: device/platform → timezone → Isar/locale →
  /// notifications plugin → cold-start tap → Android channels → migration.
  static Future<AppBootstrap> initialize() async {
    await DeviceFeature().init();
    await PlatformFeatures.initialize();

    if (kDebugMode) {
      PlatformFeatures.logPlatformInfo();
    }

    await initializeNotificationTimeZone();
    final bootstrap = await _initializeIsar();
    final callbacks = notificationPluginResponseCallbacks();
    await initializeNotificationsPlugin(
      onDidReceiveNotificationResponse: callbacks.onForeground,
      onDidReceiveBackgroundNotificationResponse: callbacks.onBackground,
      snoozeMinutes: bootstrap.settings.snoozeDuration,
    );

    final plugin = NotificationPlugin.instance;
    if (plugin != null) {
      await registerAndroidNotificationChannels(plugin);
      final launchDetails = await plugin.getNotificationAppLaunchDetails();
      final launchResponse = launchDetails?.notificationResponse;
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchResponse != null) {
        await handleNotificationResponse(launchResponse);
      }
    }
    await migrateNotificationChannelsIfNeeded(isar: bootstrap.isar);

    await PlatformFeatures.setScreenPrivacy(
      bootstrap.settings.screenPrivacy ?? false,
    );

    if (PlatformFeatures.isMobile) {
      await PlatformFeatures.setSystemUIMode(edgeToEdge: true);
    }

    await RecurrenceBackgroundScheduler.initializeAndRegister();

    return bootstrap;
  }

  /// Opens Isar, seeds default settings, runs migrations, and applies locale.
  static Future<AppBootstrap> _initializeIsar() async {
    final (isar, settings) = await IsarBootstrap.openAppIsarWithSettings();

    final seeded = _seedDefaultSettings(
      settings,
      PlatformDispatcher.instance.locale,
    );
    final migrated = await performSettingsSchemaMigrationIfNeeded(
      isar,
      settings,
    );
    if (seeded && !migrated) {
      await persistSettings(isar, settings);
    } else if (!migrated) {
      final directory = isar.directory;
      if (directory != null) {
        await SettingsJsonBackup.save(directory, settings);
      }
    }

    final appLocale = appLocaleFromLanguageCode(settings.language);
    await applyAppLocale(appLocale);

    return AppBootstrap(isar: isar, settings: settings);
  }
}

/// Seeds missing defaults on [settings].
///
/// Returns `true` when [settings] was modified and should be persisted.
bool _seedDefaultSettings(Settings settings, Locale deviceLocale) {
  var changed = false;

  if (settings.language == null) {
    settings.language =
        '${deviceLocale.languageCode}_${deviceLocale.countryCode}';
    changed = true;
  }

  if (settings.theme == null) {
    settings.theme = AppConstants.defaultTheme;
    changed = true;
  }

  if (settings.isImage == null) {
    settings.isImage = AppConstants.defaultIsImage;
    changed = true;
  }

  if (settings.screenPrivacy == null) {
    settings.screenPrivacy = false;
    changed = true;
  }

  if (settings.snoozeDuration <= 0) {
    settings.snoozeDuration = AppConstants.defaultSnoozeDuration;
    changed = true;
  }

  if (settings.maxAutoBackups <= 0) {
    settings.maxAutoBackups = AppConstants.defaultMaxAutoBackups;
    changed = true;
  }

  return changed;
}
