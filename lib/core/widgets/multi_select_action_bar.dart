import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/i18n/tr.dart';

/// Icon action shown on the multi-select floating bar.
class MultiSelectAction {
  /// Creates a [MultiSelectAction].
  const MultiSelectAction({
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  /// Action icon.
  final IconData icon;

  /// Invoked when the action is pressed.
  final VoidCallback onPressed;

  /// Optional icon tint.
  final Color? color;

  /// Accessibility tooltip.
  final String? tooltip;
}

/// Floating bar for bulk selection with configurable actions.
class MultiSelectActionBar extends StatelessWidget {
  /// Creates a [MultiSelectActionBar].
  const MultiSelectActionBar({
    super.key,
    required this.selectedCount,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.actions,
    required this.onClose,
  });

  /// Number of currently selected items.
  final int selectedCount;

  /// Whether all visible items are selected.
  final bool isAllSelected;

  /// Toggles select-all for the current list.
  final VoidCallback onSelectAll;

  /// Secondary actions (transfer, archive, delete, etc.).
  final List<MultiSelectAction> actions;

  /// Clears multi-select mode.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Positioned(
      bottom: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
      left: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
      right: isMobile ? AppConstants.spacingL : AppConstants.spacingXXL,
      child: _AnimatedMultiSelectBar(
        child: Material(
          elevation: AppConstants.elevationMedium,
          shadowColor: colorScheme.shadow.withValues(
            alpha: AppConstants.chipBorderAlpha,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile
                  ? AppConstants.spacingM
                  : AppConstants.spacingL,
              vertical: AppConstants.spacingM,
            ),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(
                  alpha: AppConstants.opacityMedium,
                ),
                width: AppConstants.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Expanded(child: _buildSelectionCounter(context)),
                SizedBox(width: AppConstants.spacingS),
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCounter(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onSelectAll,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusCompact),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusCompact),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAllSelected
                  ? IconsaxPlusBold.tick_square
                  : IconsaxPlusLinear.tick_square,
              size: AppConstants.iconSizeMedium,
              color: colorScheme.onPrimaryContainer,
            ),
            SizedBox(width: AppConstants.spacingS + 2),
            Flexible(
              child: Text(
                selectedCount == 1
                    ? '1 ${'item'.tr}'
                    : '$selectedCount ${'items'.tr}',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final action in actions)
          _MultiSelectIconButton(
            icon: action.icon,
            color: action.color,
            onPressed: action.onPressed,
            tooltip: action.tooltip,
          ),
        SizedBox(width: AppConstants.spacingXS),
        FilledButton.tonal(
          onPressed: onClose,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppConstants.spacingL,
              vertical: AppConstants.spacingS + 2,
            ),
            minimumSize: const Size(0, 40),
          ),
          child: Icon(
            IconsaxPlusLinear.close_circle,
            size: AppConstants.iconSizeSmall,
          ),
        ),
      ],
    );
  }
}

class _MultiSelectIconButton extends StatelessWidget {
  const _MultiSelectIconButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: AppConstants.iconSizeMedium + 2, color: color),
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
      ),
      tooltip: tooltip,
    );
  }
}

class _AnimatedMultiSelectBar extends StatelessWidget {
  const _AnimatedMultiSelectBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppConstants.animationDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}
