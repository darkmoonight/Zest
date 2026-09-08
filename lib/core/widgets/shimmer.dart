import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:shimmer/shimmer.dart';

/// Full-width shimmer placeholder with theme-aware gradient colors.
class MyShimmer extends StatelessWidget {
  /// Creates a shimmer block with the given [height] and optional [margin].
  const MyShimmer({super.key, required this.height, this.margin});

  /// Height of the shimmer placeholder.
  final double height;

  /// Optional outer margin around the placeholder.
  final EdgeInsets? margin;

  /// Returns the mask color used by shimmer child widgets.
  static Color shimmerMaskColor(BuildContext context) => Colors.white;

  /// Blends surface tones for shimmer base and highlight colors.
  static Color _surfaceTone(
    BuildContext context, {
    required double onSurfaceAlpha,
    double primaryAlpha = 0,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final background = Theme.of(context).cardColor;
    var tone = Color.alphaBlend(
      scheme.onSurface.withValues(alpha: onSurfaceAlpha),
      background,
    );
    if (primaryAlpha > 0) {
      tone = Color.alphaBlend(
        scheme.primary.withValues(alpha: primaryAlpha),
        tone,
      );
    }
    return tone;
  }

  /// Returns base and highlight colors for the shimmer gradient.
  static (Color base, Color highlight) shimmerGradientColors(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return (
        _surfaceTone(context, onSurfaceAlpha: 0.05),
        _surfaceTone(context, onSurfaceAlpha: 0.10, primaryAlpha: 0.06),
      );
    }
    return (
      _surfaceTone(context, onSurfaceAlpha: 0.04),
      _surfaceTone(context, onSurfaceAlpha: 0.08, primaryAlpha: 0.05),
    );
  }

  /// Wraps [child] in a [Shimmer] with theme-appropriate colors.
  static Widget wrap(BuildContext context, Widget child) {
    final (base, highlight) = shimmerGradientColors(context);
    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: child,
    );
  }

  @override
  /// Builds the shimmer-wrapped placeholder block.
  Widget build(BuildContext context) =>
      wrap(context, _buildPlaceholder(context));

  /// Builds the rounded rectangle placeholder masked by shimmer.
  Widget _buildPlaceholder(BuildContext context) => Container(
    margin: margin,
    height: height,
    width: double.infinity,
    decoration: BoxDecoration(
      color: shimmerMaskColor(context),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
    ),
  );
}
