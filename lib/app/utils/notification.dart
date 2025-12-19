import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zest/main.dart';
import 'package:get/get.dart';

class NotificationShow {
  final String _channelId = 'Zest';
  final String _channelName = 'DARK NIGHT';

  static const String actionIdMarkDone = 'mark_done';

  Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime? date,
  ) async {
    await _requestNotificationPermission();
    final notificationDetails = _buildNotificationDetails();
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
    if (platform != null) {
      await platform.requestExactAlarmsPermission();
      await platform.requestNotificationsPermission();
    }
  }

  NotificationDetails _buildNotificationDetails() {
    final androidNotificationDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      priority: Priority.high,
      importance: Importance.max,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(actionIdMarkDone, 'markAsDone'.tr),
      ],
    );
    return NotificationDetails(android: androidNotificationDetails);
  }

  tz.TZDateTime _getScheduledTime(DateTime date) =>
      tz.TZDateTime.from(date, tz.local);
}
