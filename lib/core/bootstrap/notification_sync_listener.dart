import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/di/list_reload.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Reloads list state after foreground notification actions.
///
/// App-resume reload is owned by [AutoBackupLifecycleListener] after
/// maintenance so lists are not refreshed before midnight rollover.
class NotificationSyncListener extends ConsumerStatefulWidget {
  /// Wraps [child] and keeps lists in sync with notification-side DB writes.
  const NotificationSyncListener({super.key, required this.child});

  /// Widget subtree below this listener.
  final Widget child;

  @override
  ConsumerState<NotificationSyncListener> createState() =>
      _NotificationSyncListenerState();
}

class _NotificationSyncListenerState
    extends ConsumerState<NotificationSyncListener> {
  @override
  void initState() {
    super.initState();
    NotificationHandlerBridge.onForegroundActionCompleted = _reloadFromDatabase;
    // Android permission APIs need MainActivity; schedule after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!PlatformFeatures.supportsNotifications) return;
      unawaited(NotificationShow().requestPermissions());
    });
  }

  @override
  void dispose() {
    if (identical(
      NotificationHandlerBridge.onForegroundActionCompleted,
      _reloadFromDatabase,
    )) {
      NotificationHandlerBridge.onForegroundActionCompleted = null;
    }
    super.dispose();
  }

  Future<void> _reloadFromDatabase() => reloadTodosAndTasks(ref);

  @override
  Widget build(BuildContext context) => widget.child;
}
