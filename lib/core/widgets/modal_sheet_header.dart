import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';

/// Title row for modal bottom sheets with optional hero icon and save action.
class ModalSheetHeader extends StatelessWidget {
  /// Creates a [ModalSheetHeader].
  const ModalSheetHeader({
    super.key,
    required this.padding,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.trailing,
  });

  /// Horizontal/vertical padding multiplier from [ResponsiveUtils].
  final double padding;

  /// Primary title text.
  final String title;

  /// Secondary hint text.
  final String subtitle;

  /// Leading icon widget (often [IconContainer] with optional [Hero]).
  final Widget leading;

  /// Trailing action (usually [ModalSheetSaveButton]).
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 1.5,
        vertical: padding,
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: padding * 1.2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: padding * 0.8),
          trailing,
        ],
      ),
    );
  }
}
