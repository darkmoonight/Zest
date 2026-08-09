import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/settings_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Deletes old completed todos on a schedule (Settings → Data).
class AutoEraseCompletedService {
  AutoEraseCompletedService._();

  static const _weeklyRetention = Duration(days: 7);
  static const _monthlyRetention = Duration(days: 30);

  /// Retention window for [frequency].
  static Duration retentionFor(AutoEraseCompletedFrequency frequency) =>
      switch (frequency) {
        AutoEraseCompletedFrequency.weekly => _weeklyRetention,
        AutoEraseCompletedFrequency.monthly => _monthlyRetention,
      };

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
    return current.difference(last) >= retentionFor(frequency);
  }

  /// Whether [todo] is eligible for erase at [now].
  static bool isEligible(Todos todo, Duration retention, DateTime now) {
    if (todo.status != TodoStatus.done) return false;
    final completed = todo.todoCompletionTime ?? todo.createdTime;
    return !completed.isAfter(now.subtract(retention));
  }

  /// Runs erase when due; updates [Settings.lastAutoEraseCompletedTime].
  ///
  /// Returns the number of todos deleted (0 when skipped or nothing eligible).
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

  /// Deletes eligible completed todos and stamps last-run time.
  static Future<int> perform({
    required Isar isar,
    required Settings settings,
    NotificationService? notificationService,
    DeviceCalendarSyncService? calendarSync,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final retention = retentionFor(settings.autoEraseCompletedFrequency);
    final todoRepo = TodoRepository(isar);
    final all = await todoRepo.getAll();
    final toDelete = all
        .where((t) => isEligible(t, retention, current))
        .toList();

    for (final todo in toDelete) {
      await calendarSync?.removeSynced(todo);
      await notificationService?.cancel(todo.id);
    }

    if (toDelete.isNotEmpty) {
      await todoRepo.deleteBatch(toDelete.map((t) => t.id).toSet());
    }

    settings.lastAutoEraseCompletedTime = current;
    await SettingsRepository(isar).save(settings);

    debugPrint('Auto-erased ${toDelete.length} completed todo(s)');
    return toDelete.length;
  }
}
