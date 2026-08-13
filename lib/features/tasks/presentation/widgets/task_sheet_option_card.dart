import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/i18n/tr.dart';

/// Shared bordered row used by color / default / recurrence controls on the
/// task sheet.
class TaskSheetOptionCard extends StatelessWidget {
  /// Creates a card with [leading], title/subtitle column, and [action].
  const TaskSheetOptionCard({
    super.key,
    required this.leading,
    required this.titleKey,
    required this.subtitle,
    required this.action,
  });

  /// 44×44 preview on the leading edge.
  final Widget leading;

  /// Translation key for the small caption above [subtitle].
  final String titleKey;

  /// Primary value shown under [titleKey] (status, hex, frequency, …).
  final String subtitle;

  /// Trailing control, typically a tonal "Change" button.
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: AppConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleKey.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS / 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          action,
        ],
      ),
    );
  }
}

/// 44×44 icon preview with accent border used by default / recurrence rows.
class TaskSheetOptionIconPreview extends StatelessWidget {
  /// Creates a preview using [active] colors and [icon] / [activeIcon].
  const TaskSheetOptionIconPreview({
    super.key,
    required this.active,
    required this.icon,
    required this.activeIcon,
  });

  /// Whether the option is enabled / non-default.
  final bool active;

  /// Icon when inactive.
  final IconData icon;

  /// Icon when [active].
  final IconData activeIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = active ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: AppConstants.iconBoxSize,
      height: AppConstants.iconBoxSize,
      decoration: BoxDecoration(
        color: active
            ? colorScheme.primary.withValues(alpha: 0.18)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCompact),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Icon(
        active ? activeIcon : icon,
        color: accent,
        size: AppConstants.iconSizeMedium,
      ),
    );
  }
}

/// Compact tonal "Change" control matching task-sheet option rows.
class TaskSheetOptionChangeButton extends StatelessWidget {
  /// Creates a change button with [icon] and optional [active] tint.
  const TaskSheetOptionChangeButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.active = false,
  });

  /// Tap handler.
  final VoidCallback onPressed;

  /// Leading icon inside the button.
  final IconData icon;

  /// When true, uses a primary-tinted background.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: AppConstants.iconSizeSmall),
      label: Text(
        'change'.tr,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        minimumSize: const Size(0, 36),
        backgroundColor: active
            ? colorScheme.primary.withValues(alpha: 0.15)
            : null,
        foregroundColor: active ? colorScheme.primary : null,
      ),
    );
  }
}
