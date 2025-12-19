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
  }) async {
    if (requestPermission) {
      await _requestNotificationPermission();
    }

    final notificationDetails = _buildNotificationDetails(title, body);
    final scheduledTime = _getScheduledTime(date!);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '$id',
    );
  }

  Future<void> _requestNotificationPermission() async {
    final platform = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (platform == null) return;
    await platform.requestExactAlarmsPermission();
    await platform.requestNotificationsPermission();
  }

  NotificationDetails _buildNotificationDetails(String title, String body) {
    final actions = <AndroidNotificationAction>[
      AndroidNotificationAction(actionIdMarkDone, 'markAsDone'.tr),
      AndroidNotificationAction(
        actionIdSnooze,
        '${'snooze'.tr} ${snoozeDuration.value} ${'min'.tr}',
      ),
    ];

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
      actions: actions,
    );
    return NotificationDetails(android: androidNotificationDetails);
  }

  tz.TZDateTime _getScheduledTime(DateTime date) =>
      tz.TZDateTime.from(date, tz.local);

  Future<void> snoozeNotification(int id, String title, String body) async {
    final snoozeMinutes = snoozeDuration.value;
    final newDateTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
    await flutterLocalNotificationsPlugin.cancel(id);
    await showNotification(
      id,
      title,
      body,
      newDateTime,
      requestPermission: false,
    );
  }
}
