import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/di/list_reload.dart';

/// Reloads list state after foreground notification actions.
///
/// Other lifecycle-driven refresh paths are handled elsewhere to avoid
/// duplicate reloads during app transitions.
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
