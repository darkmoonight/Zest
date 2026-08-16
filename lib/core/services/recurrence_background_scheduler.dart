import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:zest/core/bootstrap/background_isar_context.dart';
import 'package:zest/core/services/recurrence_coordinator.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Unique Workmanager ids for midnight recurrence jobs.
abstract final class RecurrenceBackgroundTasks {
  /// One-off task aimed at the next local midnight.
  static const midnightOneOff = 'zest.recurrence.midnight.oneoff';

  /// Periodic catch-up (Android minimum ~15 minutes).
  static const midnightPeriodic = 'zest.recurrence.midnight.periodic';

  /// Shared task name received by [callbackDispatcher].
  static const taskName = 'zest.recurrence.midnight';
}

/// Registers and runs background midnight recurrence via Workmanager.
///
/// Android: one-off to next local midnight + periodic catch-up (~30 min).
/// iOS: best-effort via background fetch; reliable midnight only on open/resume.
class RecurrenceBackgroundScheduler {
  RecurrenceBackgroundScheduler._();

  static const _periodicFrequency = Duration(minutes: 30);
  static const _minPositiveDelay = Duration(seconds: 1);
  static final _offlineConstraints = Constraints(
    networkType: NetworkType.notRequired,
  );

  /// Initializes Workmanager and schedules midnight + periodic jobs.
  ///
  /// No-op on web / unsupported platforms. Safe to call on every app start
  /// (replaces existing work).
  static Future<void> initializeAndRegister() async {
    if (!_supportsBackgroundWork) return;

    try {
      await Workmanager().initialize(callbackDispatcher);
      await registerJobs();
    } catch (e, stackTrace) {
      debugPrint('RecurrenceBackgroundScheduler init failed: $e');
      debugPrint('$stackTrace');
    }
  }

  /// (Re)registers one-off midnight and periodic catch-up tasks.
  static Future<void> registerJobs({DateTime? now}) async {
    if (!_supportsBackgroundWork) return;

    final delay = delayUntilNextLocalMidnight(now);
    try {
      await Workmanager().registerOneOffTask(
        RecurrenceBackgroundTasks.midnightOneOff,
        RecurrenceBackgroundTasks.taskName,
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: _offlineConstraints,
      );

      if (PlatformFeatures.isAndroid) {
        await Workmanager().registerPeriodicTask(
          RecurrenceBackgroundTasks.midnightPeriodic,
          RecurrenceBackgroundTasks.taskName,
          frequency: _periodicFrequency,
          existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
          constraints: _offlineConstraints,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('RecurrenceBackgroundScheduler register failed: $e');
      debugPrint('$stackTrace');
    }
  }

  /// Duration from [now] until the next local midnight.
  static Duration delayUntilNextLocalMidnight([DateTime? now]) {
    final n = now ?? DateTime.now();
    final nextMidnight = RecurrenceService.calendarDay(n)
        .add(const Duration(days: 1));
    final delay = nextMidnight.difference(n);
    // Workmanager rejects zero/negative delays; keep a tiny positive delay.
    if (delay <= Duration.zero) return _minPositiveDelay;
    return delay;
  }

  /// Runs midnight rollover and reschedules active due notifications.
  static Future<void> runBackgroundRollover() async {
    await withBackgroundIsar((ctx) async {
      await RecurrenceCoordinator(
        todoRepo: ctx.todoRepo,
        isar: ctx.isar,
        notificationService: ctx.notifications,
        calendarSync: ctx.calendarSync,
      ).runMidnightRollover();

      final items = await ctx.todoRepo.getAll();
      await ctx.notifications.rescheduleActiveReminders(
        items,
        settings: ctx.settings,
      );

      await registerJobs();
    });
  }

  static bool get _supportsBackgroundWork =>
      !kIsWeb && PlatformFeatures.isMobile;
}

/// Workmanager entry point for recurrence midnight jobs.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == RecurrenceBackgroundTasks.taskName ||
          task == Workmanager.iOSBackgroundTask) {
        await RecurrenceBackgroundScheduler.runBackgroundRollover();
      }
      return true;
    } catch (e, stackTrace) {
      debugPrint('Recurrence background task failed: $e');
      debugPrint('$stackTrace');
      return false;
    }
  });
}
