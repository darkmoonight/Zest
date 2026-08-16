import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zest/core/bootstrap/background_isar_context.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';

/// Background isolate entry point for notification taps and actions.
///
/// The plugin invokes this as a synchronous `void` callback and does not await
/// Futures. An open [ReceivePort] keeps the isolate alive until
/// [handleNotificationResponse] finishes Isar writes / reschedule.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  final keepAlive = ReceivePort();
  handleNotificationResponse(response).whenComplete(keepAlive.close);
}

/// Handles notification taps: body opens the entry; actions mutate the database.
///
/// When [NotificationResponse.actionId] is null, queues navigation via
/// [NotificationHandlerBridge.requestTodoOpen]. Mark Done and Snooze run in
/// a background-capable Isar context with locale applied.
Future<void> handleNotificationResponse(NotificationResponse response) async {
  try {
    final payload = response.payload;
    final actionId = response.actionId;
    if (payload == null) return;

    final itemId = int.tryParse(payload);
    if (itemId == null) return;

    if (actionId == null) {
      NotificationHandlerBridge.requestTodoOpen(itemId);
      return;
    }

    await withBackgroundIsar((ctx) async {
      switch (actionId) {
        case NotificationShow.actionIdMarkDone:
          await _markItemDone(ctx, itemId);
          break;
        case NotificationShow.actionIdSnooze:
          await _snoozeItem(ctx, itemId);
          break;
        default:
          break;
      }
    });
  } catch (e, stackTrace) {
    debugPrint('Error handling notification: $e');
    debugPrint('$stackTrace');
  }
}

/// Marks the list item with [itemId] done from a notification action.
Future<void> markTodoAsDone(int itemId) async {
  try {
    await withBackgroundIsar((ctx) => _markItemDone(ctx, itemId));
  } catch (e, stackTrace) {
    debugPrint('Error marking item as done: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> _snoozeItem(BackgroundIsarContext ctx, int itemId) async {
  final item = await ctx.isar.todos.get(itemId);
  if (item == null) return;
  await ctx.todoService().snoozeTodo(item, ctx.settings);
}

Future<void> _markItemDone(BackgroundIsarContext ctx, int itemId) async {
  final item = await ctx.isar.todos.get(itemId);
  if (item == null) return;
  await ctx.todoService().markTodoAsDone(item);
}
