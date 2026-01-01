import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/constants/app_constants.dart';

class NavigationHelper {
  static const _defaultDuration = AppConstants.animationDuration;

  static Future<T?>? slideUp<T>(Widget page) {
    return Get.to<T>(
      () => page,
      transition: Transition.downToUp,
      duration: _defaultDuration,
      preventDuplicates: true,
    );
  }

  static Future<T?>? fade<T>(Widget page) {
    return Get.to<T>(
      () => page,
      transition: Transition.fade,
      duration: _defaultDuration,
      preventDuplicates: true,
    );
  }

  static Future<T?>? slideLeft<T>(Widget page) {
    return Get.to<T>(
      () => page,
      transition: Transition.rightToLeft,
      duration: _defaultDuration,
      preventDuplicates: true,
    );
  }

  static void closeAll() {
    Get.until((route) => route.isFirst);
  }

  static void closeDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  static void closeBottomSheet() {
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }

  static Future<T?>? replace<T>(Widget page) {
    return Get.off<T>(
      () => page,
      transition: Transition.fadeIn,
      duration: AppConstants.animationDuration,
    );
  }

  static Future<T?> showModalSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (context) => child,
    );
  }

  static Future<T?> showAppDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => child,
    );
  }

  static void closeAllAndGoHome() {
    Get.until((route) => route.isFirst);
  }

  static void back<T>({T? result}) {
    Get.back<T>(result: result);
  }

  static bool canGoBack() {
    return Get.key.currentState?.canPop() ?? false;
  }

  static void popUntilRoute(String routeName) {
    Get.until((route) => route.settings.name == routeName);
  }

  static Future<T?>? offNamed<T>(String routeName, {dynamic arguments}) {
    return Get.offNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? offAllNamed<T>(String routeName, {dynamic arguments}) {
    return Get.offAllNamed<T>(routeName, arguments: arguments);
  }
}
