import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zest/main.dart';
import 'package:get/get.dart';

class NotificationShow {
  final String _channelId = 'Zest';
  final String _channelName = 'DARK NIGHT';

  static const String actionIdMarkDone = 'mark_done';
  static const String actionIdSnooze = 'snooze';

  Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime? date, {
    bool requestPermission = true,
    String? markDoneActionText,
    String? snoozeActionText,
  }) async {
    if (flutterLocalNotificationsPlugin == null) {
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
      markDoneActionText: markDoneActionText,
      snoozeActionText: snoozeActionText,
    );
    final scheduledTime = _getScheduledTime(date);

    try {
      await flutterLocalNotificationsPlugin!.zonedSchedule(
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

  Future<void> _requestNotificationPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final platform = flutterLocalNotificationsPlugin!
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
      final platform = flutterLocalNotificationsPlugin!
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      await platform?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  NotificationDetails _buildNotificationDetails(
    String title,
    String body, {
    String? markDoneActionText,
    String? snoozeActionText,
  }) {
    final markText = markDoneActionText ?? 'markAsDone'.tr;
    final snoozeText =
        snoozeActionText ??
        '${'snooze'.tr} ${settings.snoozeDuration} ${'min'.tr}';

    final androidNotificationDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      priority: Priority.high,
      importance: Importance.max,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: null,
        htmlFormatBigText: true,
        htmlFormatContentTitle: true,
        htmlFormatSummaryText: true,
      ),
      actions: [
        AndroidNotificationAction(actionIdMarkDone, markText),
        AndroidNotificationAction(actionIdSnooze, snoozeText),
      ],
    );

    final darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'todoCategory',
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

  tz.TZDateTime _getScheduledTime(DateTime date) {
    try {
      return tz.TZDateTime.from(date, tz.local);
    } catch (e) {
      debugPrint('Error converting to TZDateTime: $e');
      return tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));
    }
  }

  Future<void> snoozeNotification(
    int id,
    String title,
    String body, {
    String? markDoneActionText,
    String? snoozeActionText,
  }) async {
    if (flutterLocalNotificationsPlugin == null) return;

    final snoozeMinutes = settings.snoozeDuration;
    final newDateTime = DateTime.now().add(Duration(minutes: snoozeMinutes));

    try {
      await flutterLocalNotificationsPlugin!.cancel(id: id);
      await showNotification(
        id,
        title,
        body,
        newDateTime,
        requestPermission: false,
        markDoneActionText: markDoneActionText,
        snoozeActionText: snoozeActionText,
      );
    } catch (e) {
      debugPrint('Error snoozing notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (flutterLocalNotificationsPlugin == null) return;

    try {
      await flutterLocalNotificationsPlugin!.cancel(id: id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (flutterLocalNotificationsPlugin == null) return;

    try {
      await flutterLocalNotificationsPlugin!.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
}
