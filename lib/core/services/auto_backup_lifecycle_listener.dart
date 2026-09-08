import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/services/app_lifecycle_coordinator.dart';

/// Runs [AppLifecycleCoordinator] maintenance on first frame and resume.
class AutoBackupLifecycleListener extends ConsumerStatefulWidget {
  /// Wraps [child] and observes app lifecycle.
  const AutoBackupLifecycleListener({
    super.key,
    required this.child,
    @visibleForTesting this.onResumed,
  });

  /// Widget subtree beneath the lifecycle observer.
  final Widget child;

  /// Test hook; defaults to [AppLifecycleCoordinator.runMaintenance].
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
  Timer? _startupMaintenanceTimer;

  /// Registers this observer and defers startup maintenance past first paint.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // First paint + IndexedStack tabs complete before backup/CalDAV.
      _startupMaintenanceTimer?.cancel();
      _startupMaintenanceTimer = Timer(
        AppConstants.startupMaintenanceDelay,
        () {
          if (!mounted) return;
          unawaited(_runMaintenance());
        },
      );
    });
  }

  /// Unregisters this observer from [WidgetsBinding].
  @override
  void dispose() {
    _startupMaintenanceTimer?.cancel();
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

  /// Delegates to [AppLifecycleCoordinator.runMaintenance].
  Future<void> _runMaintenance() async {
    final onResumed = widget.onResumed;
    if (onResumed != null) {
      await onResumed();
      return;
    }

    await AppLifecycleCoordinator.runMaintenance(ref);
  }

  /// Passes through the wrapped [child] widget.
  @override
  Widget build(BuildContext context) => widget.child;
}
