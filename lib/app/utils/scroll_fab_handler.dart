import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:flutter/material.dart';

class ScrollFabHandler {
  static Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 150);
  static ScrollDirection? _lastDirection;

  static bool handleScrollFabVisibility({
    required ScrollNotification notification,
    required TabController tabController,
    required FabController fabController,
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
    _debounceTimer = Timer(_debounceDuration, () {
      _updateFabVisibility(
        direction: direction,
        tabController: tabController,
        fabController: fabController,
        hideFabOnTabIndex: hideFabOnTabIndex,
      );
    });

    return true;
  }

  static void _updateFabVisibility({
    required ScrollDirection direction,
    required TabController tabController,
    required FabController fabController,
    required int hideFabOnTabIndex,
  }) {
    if (tabController.index == hideFabOnTabIndex) {
      fabController.setVisibility(false);
      return;
    }

    if (direction == ScrollDirection.reverse) {
      fabController.setVisibility(false);
    } else if (direction == ScrollDirection.forward) {
      fabController.setVisibility(true);
    }
  }

  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _lastDirection = null;
  }
}
