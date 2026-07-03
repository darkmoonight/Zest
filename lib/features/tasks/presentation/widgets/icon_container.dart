import 'package:flutter/material.dart';

/// Widget that icon container.
class IconContainer extends StatelessWidget {
  /// The icon.
  final IconData icon;

  /// The background color.
  final Color? backgroundColor;

  /// The icon color.
  final Color? iconColor;

  /// The size.
  final double size;

  /// The icon size.
  final double iconSize;

  /// The shape.
  final BoxShape shape;

  /// The border radius.
  final double borderRadius;

  /// Creates a [IconContainer].
  const IconContainer({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
    this.iconSize = 24,
    this.shape = BoxShape.rectangle,
    this.borderRadius = 12,
  });

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? colorScheme.onPrimaryContainer,
      ),
    );
  }
}
