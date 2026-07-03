/// Callbacks invoked after notification actions handled in the main isolate.
class NotificationHandlerBridge {
  /// Reloads in-memory todo/task state after a foreground notification action.
  static Future<void> Function()? onForegroundActionCompleted;

  /// Notifies the app that a foreground notification action changed data.
  static Future<void> notifyForegroundActionCompleted() async {
    await onForegroundActionCompleted?.call();
  }
}
