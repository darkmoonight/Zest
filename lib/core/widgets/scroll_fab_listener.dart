import 'package:material_ui/material_ui.dart';
import 'package:zest/core/utils/scroll_fab_handler.dart';

/// Listens to scroll events and toggles FAB visibility via [ScrollFabHandler].
class ScrollFabListener extends StatefulWidget {
  /// Creates a scroll listener that controls FAB visibility.
  const ScrollFabListener({
    super.key,
    required this.child,
    required this.tabController,
    required this.setFabVisibility,
    this.disabled = false,
  });

  /// The scrollable content wrapped by this listener.
  final Widget child;

  /// Tab controller used to scope scroll handling to the active tab.
  final TabController tabController;

  /// Callback invoked when FAB visibility should change.
  final void Function(bool visible) setFabVisibility;

  /// When true, scroll notifications are ignored.
  final bool disabled;

  @override
  State<ScrollFabListener> createState() => _ScrollFabListenerState();
}

class _ScrollFabListenerState extends State<ScrollFabListener> {
  @override
  void dispose() {
    ScrollFabHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (widget.disabled) {
          return true;
        }

        return ScrollFabHandler.handleScrollFabVisibility(
          notification: notification,
          tabController: widget.tabController,
          setFabVisibility: widget.setFabVisibility,
        );
      },
      child: widget.child,
    );
  }
}
