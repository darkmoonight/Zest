import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/bootstrap/isar_bootstrap.dart';
import 'package:zest/core/bootstrap/notification_bootstrap.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/todo_service.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Background isolate entry point for notification taps.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) =>
    handleNotificationResponse(response);

/// Routes notification tap actions to shared todo/notification services.
Future<void> handleNotificationResponse(NotificationResponse response) async {
  try {
    await ensureNotificationEnvironmentForBackground();

    final payload = response.payload;
    final actionId = response.actionId;
    if (payload == null) return;

    final todoId = int.tryParse(payload);
    if (todoId == null) return;

    switch (actionId) {
      case NotificationShow.actionIdMarkDone:
        await markTodoAsDone(todoId);
        break;
      case NotificationShow.actionIdSnooze:
        await snoozeTodo(todoId);
        break;
      default:
        break;
    }
  } catch (e, stackTrace) {
    debugPrint('Error handling notification: $e');
    debugPrint('$stackTrace');
  }
}

/// Snoozes the todo reminder with [todoId] from a notification action.
Future<void> snoozeTodo(int todoId) async {
  try {
    await ensureNotificationEnvironmentForBackground();
    await _withIsar((isar) async {
      final settings = await isar.settings.where().findFirst() ?? Settings();
      final todo = await isar.todos.get(todoId);
      if (todo == null) return;

      final todoService = _todoServiceFor(isar, settings);
      await todoService.snoozeTodo(todo, settings);
    });
  } catch (e) {
    debugPrint('Error snoozing todo: $e');
  }
}

/// Marks the todo with [todoId] done from a notification action.
Future<void> markTodoAsDone(int todoId) async {
  try {
    await ensureNotificationEnvironmentForBackground();
    await _withIsar((isar) async {
      final settings = await isar.settings.where().findFirst() ?? Settings();
      final todo = await isar.todos.get(todoId);
      if (todo == null) return;

      final todoService = _todoServiceFor(isar, settings);
      await todoService.markTodoAsDone(todo);
    });
  } catch (e, stackTrace) {
    debugPrint('Error marking todo as done: $e');
    debugPrint('$stackTrace');
  }
}

/// Builds a [TodoService] for background notification handlers.
TodoService _todoServiceFor(Isar isar, Settings settings) {
  return TodoService(
    todoRepo: TodoRepository(isar),
    notificationService: NotificationService(),
    timeformat: settings.timeformat,
    languageCode:
        settings.language?.split('_').first ?? AppConstants.defaultLanguageCode,
  );
}

/// Opens or reuses Isar, runs [action], and closes when opened here.
Future<void> _withIsar(Future<void> Function(Isar isar) action) async {
  final (isarInstance, openedHere) =
      await IsarBootstrap.acquireIsarForBackgroundHandler();
  if (isarInstance == null) return;

  try {
    await action(isarInstance);
  } finally {
    if (openedHere) {
      await isarInstance.close();
    }
  }
}
