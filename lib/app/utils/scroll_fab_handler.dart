import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:flutter/material.dart';

class ScrollFabHandler {
  static Timer? _throttleTimer;
  static const _throttleDuration = Duration(milliseconds: 100);

  static bool handleScrollFabVisibility({
    required ScrollNotification notification,
    required TabController tabController,
    required FabController fabController,
    int hideFabOnTabIndex = 1,
  }) {
    if (notification.depth > 0 || notification is! UserScrollNotification) {
      return false;
    }

    if (_throttleTimer?.isActive ?? false) {
      return false;
    }

    _throttleTimer = Timer(_throttleDuration, () {});

    final direction = notification.direction;
    final shouldHide = direction == ScrollDirection.reverse;
    final shouldShow = direction == ScrollDirection.forward;

    if (tabController.index == hideFabOnTabIndex) {
      if (shouldHide) fabController.hide();
    } else {
      if (shouldHide) {
        fabController.hide();
      } else if (shouldShow) {
        fabController.show();
      }
    }

    return true;
  }

  static void dispose() {
    _throttleTimer?.cancel();
  }
}
