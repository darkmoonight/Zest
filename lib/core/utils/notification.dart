import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zest/core/notifications/notification_channels.dart';
import 'package:zest/core/notifications/notification_i18n.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/data/models/db.dart' as db;
import 'package:zest/i18n/tr.dart';

/// Schedules, snoozes, and cancels local todo reminder notifications.
class NotificationShow {
  /// Action id for the mark-done notification button.
  static const String actionIdMarkDone = 'mark_done';

  /// Action id for the snooze notification button.
  static const String actionIdSnooze = 'snooze';

  /// iOS/macOS category id for todo reminder actions.
  static const String todoCategoryId = 'todoCategory';

  /// Returns the shared notifications plugin, or null when unsupported.
  FlutterLocalNotificationsPlugin? get _plugin => NotificationPlugin.instance;

  /// Schedules a notification at [date] with optional action labels.
  Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime? date, {
    bool requestPermission = true,
    String? markDoneActionText,
    String? snoozeActionText,
    db.Settings? settings,
    db.Priority priority = db.Priority.none,
  }) async {
    if (_plugin == null) {
      debugPrint('Notifications not supported on this platform');
      return;
    }

    if (date == null) return;

    if (requestPermission) {
      await _requestNotificationPermission();
    }

    final notificationDetails = _buildNotificationDetails(
      title,
      body,
      priority: priority,
      markDoneActionText: markDoneActionText,
      snoozeActionText: snoozeActionText,
      settings: settings,
    );
    final scheduledTime = _getScheduledTime(date);

    try {
      await _plugin!.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledTime,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: '$id',
      );
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  /// Requests notification permissions on the current platform.
  Future<void> _requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final platform = _plugin!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (platform == null) return;

      try {
        await platform.requestExactAlarmsPermission();
        await platform.requestNotificationsPermission();
      } catch (e) {
        debugPrint('Error requesting permissions: $e');
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final platform = _plugin!
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await platform?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  /// Builds platform-specific notification details with action buttons.
  NotificationDetails _buildNotificationDetails(
    String title,
    String body, {
    required db.Priority priority,
    String? markDoneActionText,
    String? snoozeActionText,
    db.Settings? settings,
  }) {
    final markText = markDoneActionText ?? 'markAsDone'.tr;
    final snoozeMinutes = settings?.snoozeDuration ?? 10;
    final snoozeText = snoozeActionText ?? snoozeActionLabel(snoozeMinutes);
    final channel = notificationChannelForPriority(priority);

    final androidNotificationDetails = AndroidNotificationDetails(
      channel.id,
      channel.localizedName,
      icon: 'ic_notification',
      importance: channel.importance,
      priority: _androidPriority(channel.importance),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: null,
        htmlFormatBigText: true,
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(
          actionIdMarkDone,
          markText,
          showsUserInterface: false,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          actionIdSnooze,
          snoozeText,
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    final darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: channel.playSound,
      categoryIdentifier: NotificationShow.todoCategoryId,
    );

    final linuxNotificationDetails = LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(key: actionIdMarkDone, label: markText),
        LinuxNotificationAction(key: actionIdSnooze, label: snoozeText),
      ],
    );

    return NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
      linux: linuxNotificationDetails,
    );
  }

  Priority _androidPriority(Importance importance) {
    return switch (importance) {
      Importance.max => Priority.max,
      Importance.high => Priority.high,
      Importance.defaultImportance => Priority.defaultPriority,
      Importance.low => Priority.low,
      Importance.min => Priority.min,
      Importance.none => Priority.min,
      _ => Priority.defaultPriority,
    };
  }

  /// Converts [date] to a timezone-aware scheduled time.
  tz.TZDateTime _getScheduledTime(DateTime date) {
    try {
      return tz.TZDateTime.from(date, tz.local);
    } catch (e) {
      debugPrint('Error converting to TZDateTime: $e');
      return tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    }
  }

  /// Reschedules notification [id] after the configured snooze interval.
  Future<void> snoozeNotification(
    int id,
    String title,
    String body, {
    String? markDoneActionText,
    String? snoozeActionText,
    int? snoozeMinutes,
    db.Settings? settings,
    db.Priority priority = db.Priority.none,
  }) async {
    if (_plugin == null) return;

    final minutes = snoozeMinutes ?? settings?.snoozeDuration ?? 10;
    final newDateTime = DateTime.now().add(Duration(minutes: minutes));

    try {
      await _plugin!.cancel(id: id);
      await showNotification(
        id,
        title,
        body,
        newDateTime,
        requestPermission: false,
        markDoneActionText: markDoneActionText,
        snoozeActionText: snoozeActionText,
        settings: settings,
        priority: priority,
      );
    } catch (e) {
      debugPrint('Error snoozing notification: $e');
    }
  }

  /// Cancels the scheduled notification with [id].
  Future<void> cancelNotification(int id) async {
    if (_plugin == null) return;

    try {
      await _plugin!.cancel(id: id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  /// Cancels all scheduled notifications.
  Future<void> cancelAllNotifications() async {
    if (_plugin == null) return;

    try {
      await _plugin!.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
}
