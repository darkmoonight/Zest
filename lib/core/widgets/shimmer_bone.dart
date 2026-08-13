import 'package:material_ui/material_ui.dart';

/// Rectangular placeholder block used inside shimmer loading layouts.
class ShimmerBone extends StatelessWidget {
  /// Creates a shimmer bone with the given dimensions and color.
  const ShimmerBone({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    this.borderRadius = 4,
  });

  /// Width of the placeholder block.
  final double width;

  /// Height of the placeholder block.
  final double height;

  /// Fill color of the placeholder block.
  final Color color;

  /// Corner radius of the placeholder block.
  final double borderRadius;

  /// Returns the mask color used by shimmer placeholders.
  static Color placeholderColor(BuildContext context) => Colors.white;

  @override
  /// Builds the rounded placeholder container.
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
    ),
  );
}
