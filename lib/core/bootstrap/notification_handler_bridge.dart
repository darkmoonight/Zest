/// Callbacks invoked after notification actions handled in the main isolate.
class NotificationHandlerBridge {
  /// Reloads in-memory item/task state after a foreground notification action.
  static Future<void> Function()? onForegroundActionCompleted;

  /// Opens the item edit sheet when the user taps a notification body.
  static void Function(int todoId)? onTodoOpenRequested;

  /// Item id deferred until the widget tree can navigate (cold start / resume).
  static int? pendingTodoId;

  /// Notifies the app that a foreground notification action changed data.
  static Future<void> notifyForegroundActionCompleted() async {
    await onForegroundActionCompleted?.call();
  }

  /// Queues navigation to the item with [todoId].
  static void requestTodoOpen(int todoId) {
    pendingTodoId = todoId;
    onTodoOpenRequested?.call(todoId);
  }
}
