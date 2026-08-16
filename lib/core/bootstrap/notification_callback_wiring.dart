import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/bootstrap/notification_handlers.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Foreground + background callbacks used when initializing the plugin.
({
  DidReceiveNotificationResponseCallback onForeground,
  DidReceiveBackgroundNotificationResponseCallback? onBackground,
})
notificationPluginResponseCallbacks() {
  return (
    onForeground: (response) async {
      await handleNotificationResponse(response);
      await NotificationHandlerBridge.notifyForegroundActionCompleted();
    },
    onBackground: kIsWeb ? null : notificationTapBackground,
  );
}

/// Rebuilds pending reminders so action labels (e.g. snooze) match [settings].
///
/// Does **not** re-initialize the notification plugin — Android/Linux pick up
/// labels on the next [NotificationService.scheduleForTodo]. Darwin category
/// action titles refresh on the next cold start.
Future<void> refreshActiveReminderLabels({
  required TodoRepository todoRepo,
  required NotificationService notificationService,
  required Settings settings,
}) async {
  final items = await todoRepo.getAll();
  await notificationService.rescheduleActiveReminders(
    items,
    settings: settings,
  );
}
