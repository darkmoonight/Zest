import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/bootstrap/isar_bootstrap.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/bootstrap/notification_bootstrap.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/todo_service.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/i18n/locale_utils.dart';

/// Background isolate entry point for notification taps and actions.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) =>
    handleNotificationResponse(response);

/// Handles notification taps: body tap opens the todo; actions mutate the database.
///
/// When [NotificationResponse.actionId] is null, queues navigation via
/// [NotificationHandlerBridge.requestTodoOpen]. Mark Done and Snooze run in
/// a background-capable Isar context with locale applied.
Future<void> handleNotificationResponse(NotificationResponse response) async {
  try {
    final payload = response.payload;
    final actionId = response.actionId;
    if (payload == null) return;

    final todoId = int.tryParse(payload);
    if (todoId == null) return;

    if (actionId == null) {
      NotificationHandlerBridge.requestTodoOpen(todoId);
      return;
    }

    await _withIsar((isar) async {
      final settings = await isar.settings.where().findFirst() ?? Settings();
      await applyAppLocale(appLocaleFromLanguageCode(settings.language));
      await ensureNotificationEnvironmentForBackground(
        snoozeMinutes: settings.snoozeDuration,
      );

      switch (actionId) {
        case NotificationShow.actionIdMarkDone:
          await _markTodoAsDone(isar, settings, todoId);
          break;
        case NotificationShow.actionIdSnooze:
          await _snoozeTodo(isar, settings, todoId);
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

/// Marks the todo with [todoId] done from a notification action.
Future<void> markTodoAsDone(int todoId) async {
  try {
    await _withIsar((isar) async {
      final settings = await isar.settings.where().findFirst() ?? Settings();
      await applyAppLocale(appLocaleFromLanguageCode(settings.language));
      await ensureNotificationEnvironmentForBackground(
        snoozeMinutes: settings.snoozeDuration,
      );
      await _markTodoAsDone(isar, settings, todoId);
    });
  } catch (e, stackTrace) {
    debugPrint('Error marking todo as done: $e');
    debugPrint('$stackTrace');
  }
}

Future<void> _snoozeTodo(Isar isar, Settings settings, int todoId) async {
  final todo = await isar.todos.get(todoId);
  if (todo == null) return;

  final todoService = _todoServiceFor(isar, settings);
  await todoService.snoozeTodo(todo, settings);
}

Future<void> _markTodoAsDone(Isar isar, Settings settings, int todoId) async {
  final todo = await isar.todos.get(todoId);
  if (todo == null) return;

  final todoService = _todoServiceFor(isar, settings);
  await todoService.markTodoAsDone(todo);
}

/// Builds a [TodoService] for background notification handlers.
TodoService _todoServiceFor(Isar isar, Settings settings) {
  final todoRepo = TodoRepository(isar);
  return TodoService(
    todoRepo: todoRepo,
    notificationService: NotificationService(settings: settings),
    calendarSync: DeviceCalendarSyncService(
      getSettings: () => settings,
      todoRepo: todoRepo,
      saveSettings: (updated) async {
        await isar.writeTxn(() async {
          await isar.settings.put(updated);
        });
      },
    ),
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
