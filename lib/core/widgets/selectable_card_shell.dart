import 'package:flutter/material.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Animated card shell with selection border and elevation.
class SelectableCardShell extends StatelessWidget {
  /// Creates a [SelectableCardShell].
  const SelectableCardShell({
    super.key,
    required this.isSelected,
    required this.child,
  });

  /// Whether the card is in multi-select mode.
  final bool isSelected;

  /// Inner card content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderRadius = isSelected
        ? AppConstants.borderRadiusXLarge
        : AppConstants.borderRadiusLarge;

    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        border: isSelected
            ? Border.all(
                color: colorScheme.primary,
                width: AppConstants.borderWidthThick,
              )
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Card(
        elevation: isSelected
            ? AppConstants.elevationMedium
            : AppConstants.elevationLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}
