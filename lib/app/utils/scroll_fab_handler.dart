import 'package:flutter/rendering.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

bool handleScrollFabVisibility({
  required ScrollNotification notification,
  required TabController tabController,
  required FabController fabController,
  required BuildContext context,
  int hideFabOnTabIndex = 1,
}) {
  if (notification.depth > 0) return false;

  if (!ResponsiveUtils.isMobile(context)) {
    if (!fabController.isVisible.value) {
      fabController.show();
    }
    return true;
  }

  if (notification is UserScrollNotification) {
    final direction = notification.direction;
    final currentIndex = tabController.index;

    if (direction == ScrollDirection.idle) {
      return true;
    }

    if (currentIndex == hideFabOnTabIndex) {
      if (direction == ScrollDirection.reverse &&
          fabController.isVisible.value) {
        fabController.hide();
      }
    } else {
      if (direction == ScrollDirection.reverse &&
          fabController.isVisible.value) {
        fabController.hide();
      } else if (direction == ScrollDirection.forward &&
          !fabController.isVisible.value) {
        fabController.show();
      }
    }
  } else if (notification is ScrollUpdateNotification) {
    if (notification.metrics.pixels <= notification.metrics.minScrollExtent &&
        !fabController.isVisible.value) {
      fabController.show();
    }
  }

  return true;
}
