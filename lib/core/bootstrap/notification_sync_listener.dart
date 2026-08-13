import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/features/tasks/application/tasks_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Reloads todo/task state after notification actions and on app resume.
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
    extends ConsumerState<NotificationSyncListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_reloadFromDatabase());
    }
  }

  Future<void> _reloadFromDatabase() async {
    await ref.read(todosNotifierProvider.notifier).reloadTodos();
    await ref.read(tasksNotifierProvider.notifier).reloadTasks();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
