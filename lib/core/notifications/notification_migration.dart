import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Re-schedules active item reminders onto priority-based Android channels once.
Future<void> migrateNotificationChannelsIfNeeded({
  required Isar isar,
  NotificationService? notificationService,
}) async {
  final settings = await isar.settings.where().findFirst() ?? Settings();
  if (settings.notificationChannelsMigrated) return;

  final service = notificationService ?? NotificationService();
  final todos = await TodoRepository(isar).getAll();
  final toMigrate = todos.where(
    (todo) =>
        todo.todoCompletedTime != null && todo.status == TodoStatus.active,
  );

  var failed = false;
  for (final todo in toMigrate) {
    final ok = await service.reschedule(todo, firePastDueImmediately: false);
    if (!ok) failed = true;
  }

  if (failed) {
    debugPrint(
      'Notification channel migration incomplete; will retry on next launch',
    );
    return;
  }

  settings.notificationChannelsMigrated = true;
  await persistSettings(isar, settings);
}
