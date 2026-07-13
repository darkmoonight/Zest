import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/notifications/notification_i18n.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/i18n/tr.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Initializes timezone data for scheduled notifications.
Future<void> initializeNotificationTimeZone() async {
  try {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  } catch (e) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    debugPrint('Error initializing timezone: $e');
  }
}

/// Builds Darwin init settings including localized notification action categories.
DarwinInitializationSettings buildDarwinInitializationSettings({
  int snoozeMinutes = AppConstants.defaultSnoozeDuration,
}) {
  final snoozeLabel = snoozeActionLabel(snoozeMinutes);

  return DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    notificationCategories: [
      DarwinNotificationCategory(
        NotificationShow.todoCategoryId,
        actions: [
          DarwinNotificationAction.plain(
            NotificationShow.actionIdMarkDone,
            'markAsDone'.tr,
          ),
          DarwinNotificationAction.plain(
            NotificationShow.actionIdSnooze,
            snoozeLabel,
          ),
        ],
      ),
    ],
  );
}

/// Initializes the local notifications plugin; safe to call from any isolate.
Future<void> initializeNotificationsPlugin({
  DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
  DidReceiveBackgroundNotificationResponseCallback?
  onDidReceiveBackgroundNotificationResponse,
  int snoozeMinutes = AppConstants.defaultSnoozeDuration,
}) async {
  if (!PlatformFeatures.supportsNotifications) return;

  final plugin = NotificationPlugin.getOrCreate();

  const androidSettings = AndroidInitializationSettings('ic_notification');
  final iosSettings = buildDarwinInitializationSettings(
    snoozeMinutes: snoozeMinutes,
  );
  final linuxSettings = LinuxInitializationSettings(
    defaultActionName: 'openNotification'.tr,
  );

  final initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
    macOS: iosSettings,
    linux: linuxSettings,
  );

  try {
    await plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }
}

/// Ensures timezone and plugin are ready in a background notification isolate.
Future<void> ensureNotificationEnvironmentForBackground({
  int snoozeMinutes = AppConstants.defaultSnoozeDuration,
}) async {
  if (NotificationPlugin.instance == null) {
    await initializeNotificationTimeZone();
    await initializeNotificationsPlugin(snoozeMinutes: snoozeMinutes);
  }
}
