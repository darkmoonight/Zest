import 'package:flutter/material.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Mixin providing tap-scale animation for selectable cards.
mixin CardTapScaleMixin<T extends StatefulWidget>
    on State<T>, SingleTickerProviderStateMixin<T> {
  /// Drives press scale animation.
  late AnimationController cardTapAnimationController;

  /// Scale applied while the card is pressed.
  late Animation<double> cardTapScaleAnimation;

  /// Initializes the tap-scale animation controller.
  void initCardTapScaleAnimation() {
    cardTapAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );

    cardTapScaleAnimation =
        Tween<double>(begin: 1.0, end: AppConstants.cardTapScale).animate(
          CurvedAnimation(
            parent: cardTapAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  /// Disposes the animation controller.
  void disposeCardTapScaleAnimation() {
    cardTapAnimationController.dispose();
  }

  /// Starts the press animation.
  void handleCardTapDown(TapDownDetails details) {
    cardTapAnimationController.forward();
  }

  /// Reverses the press animation.
  void handleCardTapUp(TapUpDetails details) {
    cardTapAnimationController.reverse();
  }

  /// Reverses the press animation on cancel.
  void handleCardTapCancel() {
    cardTapAnimationController.reverse();
  }
}
