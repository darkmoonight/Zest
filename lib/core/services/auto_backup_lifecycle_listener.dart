import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/auto_backup_service.dart';

/// Runs scheduled auto-backup checks when the app returns to the foreground.
class AutoBackupLifecycleListener extends ConsumerStatefulWidget {
  /// Wraps [child] and triggers auto-backup on lifecycle resume.
  const AutoBackupLifecycleListener({
    super.key,
    required this.child,
    @visibleForTesting this.onResumed,
  });

  /// Widget subtree to render beneath the lifecycle observer.
  final Widget child;

  /// Optional hook for tests; defaults to [AutoBackupService.checkAndPerformAutoBackup].
  @visibleForTesting
  final Future<void> Function()? onResumed;

  /// Creates state that observes app lifecycle changes.
  @override
  ConsumerState<AutoBackupLifecycleListener> createState() =>
      _AutoBackupLifecycleListenerState();
}

/// Observes lifecycle events and runs auto-backup when the app resumes.
class _AutoBackupLifecycleListenerState
    extends ConsumerState<AutoBackupLifecycleListener>
    with WidgetsBindingObserver {
  /// Registers this observer with [WidgetsBinding].
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Unregisters this observer from [WidgetsBinding].
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Triggers auto-backup when the app enters the resumed state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final onResumed = widget.onResumed;
      if (onResumed != null) {
        unawaited(onResumed());
        return;
      }
      unawaited(
        AutoBackupService.checkAndPerformAutoBackup(ref.read(isarProvider)),
      );
    }
  }

  /// Passes through the wrapped [child] widget.
  @override
  Widget build(BuildContext context) => widget.child;
}
