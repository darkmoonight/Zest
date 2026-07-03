import 'package:flutter/material.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Styled metadata chip used on todo and task cards.
class MetadataChip extends StatelessWidget {
  /// Creates a chip with accent border and background tints.
  const MetadataChip({
    super.key,
    required this.accentColor,
    required this.child,
    this.backgroundColor,
    this.backgroundAlpha = 0.12,
    this.borderAlpha = 0.35,
    this.showBorder = true,
    this.padding,
  });

  /// Accent color for border and background tint when [backgroundColor] is null.
  final Color accentColor;

  /// Optional solid background; overrides [accentColor] tint when set.
  final Color? backgroundColor;

  /// Chip content, usually an icon and label row.
  final Widget child;

  /// Background fill alpha derived from [accentColor].
  final double backgroundAlpha;

  /// Border alpha derived from [accentColor].
  final double borderAlpha;

  /// Whether to draw a border from [accentColor].
  final bool showBorder;

  /// Overrides default chip padding when set.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppConstants.chipPaddingH,
            vertical: AppConstants.chipPaddingV,
          ),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? accentColor.withValues(alpha: backgroundAlpha),
        borderRadius: BorderRadius.circular(AppConstants.chipBorderRadius),
        border: showBorder
            ? Border.all(
                color: accentColor.withValues(alpha: borderAlpha),
                width: AppConstants.borderWidthThin,
              )
            : null,
      ),
      child: child,
    );
  }
}
