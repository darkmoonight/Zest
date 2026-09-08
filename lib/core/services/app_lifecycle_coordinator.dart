import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/list_reload.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/core/services/auto_erase_completed_service.dart';
import 'package:zest/core/services/midnight_maintenance.dart';

/// Owns startup/resume maintenance: backup → midnight → erase → CalDAV → reload.
///
/// Concurrent callers share one in-flight future. Bumps settings revision when
/// auto-erase updates [Settings.lastAutoEraseCompletedTime].
///
/// Startup callers should delay past first paint (see
/// [AutoBackupLifecycleListener] + [AppConstants.startupMaintenanceDelay]).
abstract final class AppLifecycleCoordinator {
  static Future<void>? _inFlight;

  /// Runs the full maintenance chain; concurrent callers share one future.
  static Future<void> runMaintenance(WidgetRef ref) {
    final existing = _inFlight;
    if (existing != null) return existing;

    late final Future<void> future;
    future = _run(ref).whenComplete(() {
      if (identical(_inFlight, future)) {
        _inFlight = null;
      }
    });
    _inFlight = future;
    return future;
  }

  /// Backup → midnight → auto-erase → reload lists.
  static Future<void> _run(WidgetRef ref) async {
    final isar = ref.read(isarProvider);
    final settings = ref.read(liveSettingsProvider);
    final notifications = ref.read(notificationServiceProvider);
    final calendar = ref.read(deviceCalendarSyncServiceProvider);
    final todoRepo = ref.read(todoRepositoryProvider);

    await AutoBackupService.checkAndPerformAutoBackup(isar);

    await runMidnightMaintenance(
      isar: isar,
      settings: settings,
      todoRepo: todoRepo,
      notificationService: notifications,
      calendarSync: calendar,
      caldavSync: ref.read(calDavSyncServiceProvider),
      firePastDueImmediately: false,
    );

    final lastEraseBefore = settings.lastAutoEraseCompletedTime;
    await AutoEraseCompletedService.checkAndPerform(
      isar: isar,
      settings: settings,
      notificationService: notifications,
      calendarSync: calendar,
      caldavSync: ref.read(calDavSyncServiceProvider),
    );
    if (settings.lastAutoEraseCompletedTime != lastEraseBefore) {
      ref.read(settingsRevisionProvider.notifier).bump();
    }

    await ref.read(calDavSyncServiceProvider).syncNow();

    await reloadTodosAndTasks(ref);
  }
}
