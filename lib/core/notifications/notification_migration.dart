import 'package:isar_community/isar.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Re-schedules active todo reminders onto priority-based Android channels once.
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

  for (final todo in toMigrate) {
    await service.reschedule(todo);
  }

  settings.notificationChannelsMigrated = true;
  await isar.writeTxn(() => isar.settings.put(settings));
}
