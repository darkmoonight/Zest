import 'package:flutter/rendering.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:flutter/material.dart';

bool handleScrollFabVisibility({
  required ScrollNotification notification,
  required TabController tabController,
  required FabController fabController,
  int hideFabOnTabIndex = 1,
}) {
  if (notification.depth > 0) return false;

  if (notification is UserScrollNotification) {
    final direction = notification.direction;

    if (tabController.index == hideFabOnTabIndex) {
      if (direction == ScrollDirection.reverse) {
        fabController.hide();
      }
    } else {
      if (direction == ScrollDirection.reverse) {
        fabController.hide();
      } else if (direction == ScrollDirection.forward) {
        fabController.show();
      }
    }
  }
  return true;
}
