import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Defers rendering [child] until the current route transition completes.
class DeferUntilRouteTransition extends StatefulWidget {
  /// Creates a widget that shows [placeholder] until the route is ready.
  const DeferUntilRouteTransition({
    super.key,
    required this.child,
    required this.placeholder,
  });

  /// Content shown after the route transition finishes.
  final Widget child;

  /// Content shown while waiting for the route transition.
  final Widget placeholder;

  @override
  /// Creates the state for this widget.
  State<DeferUntilRouteTransition> createState() =>
      _DeferUntilRouteTransitionState();
}

/// State that waits for route animation completion before showing [child].
class _DeferUntilRouteTransitionState extends State<DeferUntilRouteTransition> {
  /// Whether the route transition has finished and [child] may be shown.
  bool _ready = false;

  @override
  /// Schedules waiting for the route transition after the first frame.
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _waitForTransition());
  }

  /// Waits for the modal route animation or a fallback delay before marking ready.
  Future<void> _waitForTransition() async {
    if (!mounted) return;

    final animation = ModalRoute.of(context)?.animation;
    if (animation != null && animation.status != AnimationStatus.completed) {
      final completer = Completer<void>();
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          animation.removeStatusListener(listener);
          if (!completer.isCompleted) completer.complete();
        }
      }

      animation.addStatusListener(listener);
      if (animation.status == AnimationStatus.completed &&
          !completer.isCompleted) {
        animation.removeStatusListener(listener);
        completer.complete();
      }
      await completer.future;
    } else if (animation == null) {
      await Future<void>.delayed(AppConstants.animationDuration);
    }

    if (mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  /// Builds [placeholder] until ready, then [child].
  Widget build(BuildContext context) {
    if (!_ready) return widget.placeholder;

    return widget.child;
  }
}
