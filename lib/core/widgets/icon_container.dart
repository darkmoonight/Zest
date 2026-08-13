import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Rounded icon box used in modal headers and statistics cards.
class IconContainer extends StatelessWidget {
  /// Creates an [IconContainer].
  const IconContainer({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.size = AppConstants.iconBoxSize,
    this.iconSize = AppConstants.iconSizeLarge,
    this.shape = BoxShape.rectangle,
    this.borderRadius = AppConstants.borderRadiusMedium,
  });

  /// Icon displayed inside the container.
  final IconData icon;

  /// Background fill; defaults to [ColorScheme.primaryContainer].
  final Color? backgroundColor;

  /// Icon tint; defaults to [ColorScheme.onPrimaryContainer].
  final Color? iconColor;

  /// Outer width and height.
  final double size;

  /// Icon glyph size.
  final double iconSize;

  /// Box or circle shape.
  final BoxShape shape;

  /// Corner radius when [shape] is [BoxShape.rectangle].
  final double borderRadius;

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
