import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:zest/main.dart';
import 'package:get/get.dart';
import 'package:zest/app/data/db.dart';

class NotificationShow {
  static const String channelIdHigh = 'zest_high_priority';
  static const String channelNameHigh = 'High Priority';
  
  static const String channelIdMedium = 'zest_medium_priority';
  static const String channelNameMedium = 'Medium Priority';
  
  static const String channelIdLow = 'zest_low_priority';
  static const String channelNameLow = 'Low Priority';
  
  static const String channelIdNone = 'zest_no_priority';
  static const String channelNameNone = 'No Priority';

  static const String actionIdMarkDone = 'mark_done';
  static const String actionIdSnooze = 'snooze';
  
  Map<String, String> _getChannelForPriority(db.Priority priority) {
    switch (priority) {
      case db.Priority.high:
        return {'channelId': channelIdHigh, 'channelName': channelNameHigh};
      case db.Priority.medium:
        return {'channelId': channelIdMedium, 'channelName': channelNameMedium};
      case db.Priority.low:
        return {'channelId': channelIdLow, 'channelName': channelNameLow};
      case db.Priority.none:
      default:
        return {'channelId': channelIdNone, 'channelName': channelNameNone};
    }
  }
  
  AndroidNotificationDetails _getAndroidNotificationDetails(
    db.Priority priority,
    String title,
    String body, {
    String? markDoneActionText,
    String? snoozeActionText,
  }) {
    final channelInfo = _getChannelForPriority(priority);
    final channelId = channelInfo['channelId']!;
    final channelName = channelInfo['channelName']!;
    
    android.Priority importance;
    android.Priority priorityLevel;
    bool playSound;
    bool enableVibration;
    Int64List? vibrationPattern;
    
    switch (priority) {
      case db.Priority.high:
        importance = android.Priority.max;
        priorityLevel = android.Priority.max;
        playSound = settings.highPrioritySound;
        enableVibration = settings.highPriorityVibration;
        vibrationPattern = settings.highPriorityVibration 
            ? Int64List.fromList([0, 250, 250, 250])
            : null;
        break;
      case db.Priority.medium:
        importance = android.Priority.high;
        priorityLevel = android.Priority.high;
        playSound = settings.mediumPrioritySound;
        enableVibration = settings.mediumPriorityVibration;
        vibrationPattern = settings.mediumPriorityVibration 
            ? Int64List.fromList([0, 100, 100, 100])
            : null;
        break;
      case db.Priority.low:
        importance = android.Priority.defaultPriority;
        priorityLevel = android.Priority.defaultPriority;
        playSound = settings.lowPrioritySound;
        enableVibration = settings.lowPriorityVibration;
        vibrationPattern = settings.lowPriorityVibration 
            ? Int64List.fromList([0, 50])
            : null;
        break;
      case db.Priority.none:
      default:
        importance = android.Priority.min;
        priorityLevel = android.Priority.min;
        playSound = settings.noPrioritySound;
        enableVibration = settings.noPriorityVibration;
        vibrationPattern = settings.noPriorityVibration 
            ? Int64List.fromList([0, 50])
            : null;
        break;
    }

    final markText = markDoneActionText ?? 'markAsDone'.tr;
    final snoozeText =
        snoozeActionText ??
        '${'snooze'.tr} ${settings.snoozeDuration} ${'min'.tr}';

    return AndroidNotificationDetails(
      channelId,
      channelName,
      priority: priorityLevel,
      importance: importance,
      playSound: playSound,
      enableVibration: enableVibration,
      vibrationPattern: vibrationPattern,
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
  }

  Future<void> showNotification(
    int id,
    String title,
    String body,
    DateTime? date, {
    bool requestPermission = true,
    String? markDoneActionText,
    String? snoozeActionText,
    db.Priority priority = db.Priority.none,
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
      priority,
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
    db.Priority priority,
    String title,
    String body, {
    String? markDoneActionText,
    String? snoozeActionText,
  }) {
    final androidNotificationDetails = _getAndroidNotificationDetails(
      priority,
      title,
      body,
      markDoneActionText: markDoneActionText,
      snoozeActionText: snoozeActionText,
    );

    final darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'todoCategory',
    );

    final linuxNotificationDetails = LinuxNotificationDetails(
      actions: [
        LinuxNotificationAction(key: actionIdMarkDone, label: markDoneActionText ?? 'markAsDone'.tr),
        LinuxNotificationAction(key: actionIdSnooze, label: snoozeActionText ?? '${'snooze'.tr} ${settings.snoozeDuration} ${'min'.tr}'),
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
    db.Priority priority = db.Priority.none,
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
        priority: priority,
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
