import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Hides or shows the FAB based on scroll direction and active tab.
class ScrollFabHandler {
  /// Debounce timer for coalescing rapid scroll direction changes.
  static Timer? _debounceTimer;

  /// Last processed scroll direction, used to ignore duplicates.
  static ScrollDirection? _lastDirection;

  /// Debounces scroll events and toggles FAB visibility for [tabController].
  static bool handleScrollFabVisibility({
    required ScrollNotification notification,
    required TabController tabController,
    required void Function(bool visible) setFabVisibility,
    int hideFabOnTabIndex = 1,
  }) {
    if (notification.depth > 0 || notification is! UserScrollNotification) {
      return false;
    }

    final direction = notification.direction;

    if (direction == ScrollDirection.idle) {
      return false;
    }

    if (_lastDirection == direction) {
      return false;
    }

    _lastDirection = direction;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(AppConstants.debounceDelay, () {
      _updateFabVisibility(
        direction: direction,
        tabController: tabController,
        setFabVisibility: setFabVisibility,
        hideFabOnTabIndex: hideFabOnTabIndex,
      );
    });

    return true;
  }

  /// Applies scroll direction to FAB visibility for the active tab.
  static void _updateFabVisibility({
    required ScrollDirection direction,
    required TabController tabController,
    required void Function(bool visible) setFabVisibility,
    required int hideFabOnTabIndex,
  }) {
    if (tabController.index == hideFabOnTabIndex) {
      setFabVisibility(false);
      return;
    }

    if (direction == ScrollDirection.reverse) {
      setFabVisibility(false);
    } else if (direction == ScrollDirection.forward) {
      setFabVisibility(true);
    }
  }

  /// Cancels pending debounce and clears scroll direction state.
  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastDirection = null;
  }
}
