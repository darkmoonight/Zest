import 'package:flutter/material.dart';

class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final double iconSize;
  final BoxShape shape;
  final double borderRadius;

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
