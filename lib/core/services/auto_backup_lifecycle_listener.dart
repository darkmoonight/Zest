import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/list_reload.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/core/services/auto_erase_completed_service.dart';
import 'package:zest/core/services/recurrence_background_scheduler.dart';
import 'package:zest/core/services/recurrence_coordinator.dart';

/// Runs scheduled maintenance when the app returns to the foreground.
class AutoBackupLifecycleListener extends ConsumerStatefulWidget {
  /// Wraps [child] and triggers maintenance on lifecycle resume.
  const AutoBackupLifecycleListener({
    super.key,
    required this.child,
    @visibleForTesting this.onResumed,
  });

  /// Widget subtree to render beneath the lifecycle observer.
  final Widget child;

  /// Optional hook for tests; defaults to backup + habit reset + auto-erase.
  @visibleForTesting
  final Future<void> Function()? onResumed;

  /// Creates state that observes app lifecycle changes.
  @override
  ConsumerState<AutoBackupLifecycleListener> createState() =>
      _AutoBackupLifecycleListenerState();
}

/// Observes lifecycle events and runs maintenance when the app resumes.
class _AutoBackupLifecycleListenerState
    extends ConsumerState<AutoBackupLifecycleListener>
    with WidgetsBindingObserver {
  /// Registers this observer with [WidgetsBinding].
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_runMaintenance());
    });
  }

  /// Unregisters this observer from [WidgetsBinding].
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Triggers maintenance when the app enters the resumed state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_runMaintenance());
    }
  }

  /// Runs auto-backup, rollover, reschedule, auto-erase; then reloads lists.
  Future<void> _runMaintenance() async {
    final onResumed = widget.onResumed;
    if (onResumed != null) {
      await onResumed();
      return;
    }

    final isar = ref.read(isarProvider);
    final settings = ref.read(liveSettingsProvider);
    final notifications = ref.read(notificationServiceProvider);
    final calendar = ref.read(deviceCalendarSyncServiceProvider);

    await AutoBackupService.checkAndPerformAutoBackup(isar);

    final coordinator = RecurrenceCoordinator(
      todoRepo: ref.read(todoRepositoryProvider),
      isar: isar,
      notificationService: notifications,
      calendarSync: calendar,
    );
    await coordinator.runMidnightRollover();

    final todos = await ref.read(todoRepositoryProvider).getAll();
    await notifications.rescheduleActiveReminders(
      todos,
      settings: settings,
      firePastDueImmediately: false,
    );

    await RecurrenceBackgroundScheduler.registerJobs();

    await AutoEraseCompletedService.checkAndPerform(
      isar: isar,
      settings: settings,
      notificationService: notifications,
      calendarSync: calendar,
    );

    if (!mounted) return;
    await reloadTodosAndTasks(ref);
  }

  /// Passes through the wrapped [child] widget.
  @override
  Widget build(BuildContext context) => widget.child;
}
