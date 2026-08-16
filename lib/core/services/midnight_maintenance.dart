import 'package:isar_community/isar.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/recurrence_background_scheduler.dart';
import 'package:zest/core/services/recurrence_coordinator.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Midnight rollover + reminder reschedule for resume and Workmanager.
///
/// Use [firePastDueImmediately] `false` on foreground resume (avoid floods);
/// leave the default `true` for background Workmanager jobs. Set
/// [registerBackgroundJobs] when the midnight one-off should be re-armed.
Future<void> runMidnightMaintenance({
  required Isar isar,
  required Settings settings,
  required TodoRepository todoRepo,
  required NotificationService notificationService,
  DeviceCalendarSyncService? calendarSync,
  DateTime? now,
  bool firePastDueImmediately = true,
  bool registerBackgroundJobs = true,
}) async {
  await RecurrenceCoordinator(
    todoRepo: todoRepo,
    isar: isar,
    notificationService: notificationService,
    calendarSync: calendarSync,
  ).runMidnightRollover(now: now);

  final todos = await todoRepo.getAll();
  await notificationService.rescheduleActiveReminders(
    todos,
    settings: settings,
    firePastDueImmediately: firePastDueImmediately,
  );

  if (registerBackgroundJobs) {
    await RecurrenceBackgroundScheduler.registerJobs(now: now);
  }
}
