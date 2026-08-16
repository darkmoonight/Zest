import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/bootstrap/notification_handlers.dart';

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
