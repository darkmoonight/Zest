import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/bootstrap/notification_handler_bridge.dart';
import 'package:zest/core/bootstrap/notification_handlers.dart';
import 'package:zest/core/utils/notification.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Isar isar;

  setUp(() async {
    await ensureIsarTestCore();
    tempDir = await Directory.systemTemp.createTemp('zest_handler_');
    for (final name in Isar.instanceNames) {
      await Isar.getInstance(name)?.close(deleteFromDisk: true);
    }
    isar = await Isar.open([
      TasksSchema,
      TodosSchema,
      SettingsSchema,
    ], directory: tempDir.path);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('handleNotificationResponse', () {
    test('ignores null payload', () async {
      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
        ),
      );
    });

    test('ignores invalid payload', () async {
      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: 'not-a-number',
        ),
      );
    });

    test('ignores unknown action id', () async {
      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotificationAction,
          payload: '1',
          actionId: 'unknown',
        ),
      );
    });

    test('requests todo open for body tap', () async {
      NotificationHandlerBridge.pendingTodoId = null;
      int? openedId;
      NotificationHandlerBridge.onTodoOpenRequested = (id) => openedId = id;

      await handleNotificationResponse(
        const NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          payload: '42',
        ),
      );

      expect(openedId, 42);
      expect(NotificationHandlerBridge.pendingTodoId, 42);
      NotificationHandlerBridge.onTodoOpenRequested = null;
      NotificationHandlerBridge.pendingTodoId = null;
    });
  });

  test('markTodoAsDone marks todo done in database', () async {
    final task = await createTestTask(isar);
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'From notification',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );

    await markTodoAsDone(todo.id);

    final reloaded = await isar.todos.get(todo.id);
    expect(reloaded?.status, TodoStatus.done);
    expect(reloaded?.todoCompletionTime, isNotNull);
  });

  test('handleNotificationResponse marks todo done for action', () async {
    final task = await createTestTask(isar);
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Action',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );

    await handleNotificationResponse(
      NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        payload: '${todo.id}',
        actionId: NotificationShow.actionIdMarkDone,
      ),
    );

    final reloaded = await isar.todos.get(todo.id);
    expect(reloaded?.status, TodoStatus.done);
  });

  test('handleNotificationResponse snoozes todo for action', () async {
    final settings = Settings()..snoozeDuration = 20;
    await isar.writeTxn(() => isar.settings.put(settings));

    final task = await createTestTask(isar);
    final due = DateTime.now().subtract(const Duration(minutes: 5));
    final todo = await createTestTodo(
      isar,
      task: task,
      name: 'Snooze action',
      completedTime: due,
    );

    final before = DateTime.now();
    await handleNotificationResponse(
      NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        payload: '${todo.id}',
        actionId: NotificationShow.actionIdSnooze,
      ),
    );

    final reloaded = await isar.todos.get(todo.id);
    expect(reloaded?.todoCompletedTime, isNotNull);
    final expected = before.add(const Duration(minutes: 20));
    expect(
      reloaded!.todoCompletedTime!.difference(expected).inSeconds.abs(),
      lessThan(5),
    );
  });
}
