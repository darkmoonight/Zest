import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/utils/calendar_date.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Deletes old completed items on a schedule (Settings → Data).
class AutoEraseCompletedService {
  AutoEraseCompletedService._();

  /// Inclusive cutoff date: items completed on or before this calendar day.
  static DateTime retentionCutoff(
    AutoEraseCompletedFrequency frequency,
    DateTime now,
  ) {
    final today = CalendarDate.day(now);
    return switch (frequency) {
      AutoEraseCompletedFrequency.weekly => CalendarDate.addDays(
        today,
        -CalendarDate.weeklyDays,
      ),
      AutoEraseCompletedFrequency.monthly => DateTime(
        today.year,
        today.month - 1,
        today.day,
      ),
    };
  }

  /// Whether an erase run should happen now.
  static bool shouldErase({
    required bool enabled,
    required AutoEraseCompletedFrequency frequency,
    required DateTime? lastEraseTime,
    DateTime? now,
  }) {
    if (!enabled) return false;
    final current = now ?? DateTime.now();
    final last = lastEraseTime;
    if (last == null) return true;
    return switch (frequency) {
      AutoEraseCompletedFrequency.weekly =>
        CalendarDate.daysBetween(last, current) >= CalendarDate.weeklyDays,
      AutoEraseCompletedFrequency.monthly => !CalendarDate.isSameMonth(
        last,
        current,
      ),
    };
  }

  /// Whether [item] is eligible for erase given [cutoff] (calendar day).
  static bool isEligible(Todos todo, DateTime cutoff) {
    if (todo.status != TodoStatus.done) return false;
    final completed = todo.todoCompletionTime ?? todo.createdTime;
    final completedDay = CalendarDate.day(completed);
    return !completedDay.isAfter(CalendarDate.day(cutoff));
  }

  /// Runs erase when due; updates [Settings.lastAutoEraseCompletedTime].
  ///
  /// Returns the number of items deleted (0 when skipped or nothing eligible).
  static Future<int> checkAndPerform({
    required Isar isar,
    required Settings settings,
    NotificationService? notificationService,
    DeviceCalendarSyncService? calendarSync,
  }) async {
    if (!shouldErase(
      enabled: settings.autoEraseCompletedEnabled,
      frequency: settings.autoEraseCompletedFrequency,
      lastEraseTime: settings.lastAutoEraseCompletedTime,
    )) {
      return 0;
    }

    final deleted = await perform(
      isar: isar,
      settings: settings,
      notificationService: notificationService,
      calendarSync: calendarSync,
    );
    return deleted;
  }

  /// Deletes eligible completed items and stamps last-run time.
  static Future<int> perform({
    required Isar isar,
    required Settings settings,
    NotificationService? notificationService,
    DeviceCalendarSyncService? calendarSync,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final cutoff = retentionCutoff(
      settings.autoEraseCompletedFrequency,
      current,
    );
    final todoRepo = TodoRepository(isar);
    final all = await todoRepo.getAll();
    final toDelete = all.where((t) => isEligible(t, cutoff)).toList();

    for (final todo in toDelete) {
      await calendarSync?.removeSynced(todo);
      await notificationService?.cancel(todo.id);
    }

    if (toDelete.isNotEmpty) {
      await todoRepo.deleteBatch(toDelete.map((t) => t.id).toSet());
    }

    settings.lastAutoEraseCompletedTime = current;
    await persistSettings(isar, settings);

    debugPrint('Auto-erased ${toDelete.length} completed todo(s)');
    return toDelete.length;
  }
}
