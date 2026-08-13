import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Shared fade/slide animations for modal bottom sheets.
mixin ModalSheetAnimationMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  /// Drives sheet content entrance.
  late AnimationController modalSheetAnimationController;

  /// Opacity animation for sheet body.
  late Animation<double> modalSheetFadeAnimation;

  /// Slide animation for sheet body.
  late Animation<Offset> modalSheetSlideAnimation;

  /// Initializes and starts the entrance animation.
  void initModalSheetAnimations({
    Duration duration = AppConstants.shortAnimation,
  }) {
    modalSheetAnimationController = AnimationController(
      duration: duration,
      vsync: this,
    );

    modalSheetFadeAnimation = CurvedAnimation(
      parent: modalSheetAnimationController,
      curve: Curves.easeInOut,
    );

    modalSheetSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: modalSheetAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );

    modalSheetAnimationController.forward();
  }

  /// Disposes the animation controller.
  void disposeModalSheetAnimations() {
    modalSheetAnimationController.dispose();
  }
}
