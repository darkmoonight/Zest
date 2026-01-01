import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class SelectionActionBar extends StatelessWidget {
  const SelectionActionBar({
    super.key,
    required this.onTransfer,
    required this.onDelete,
    required this.onSelectAll,
    required this.isAllSelected,
  });

  final VoidCallback onTransfer;
  final VoidCallback onDelete;
  final VoidCallback onSelectAll;
  final bool isAllSelected;

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
          shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
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
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
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
    final todoController = Get.find<TodoController>();

    return Obx(() {
      final selectedCount = todoController.selectedTodo.length;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(
            AppConstants.borderRadiusSmall + 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSelectionBadge(context, selectedCount),
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
      );
    });
  }

  Widget _buildSelectionBadge(BuildContext context, int count) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          IconsaxPlusBold.tick_square,
          size: AppConstants.iconSizeMedium,
          color: colorScheme.onPrimaryContainer,
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.spacingXS),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primaryContainer,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final todoController = Get.find<TodoController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: isAllSelected
              ? IconsaxPlusBold.tick_square
              : IconsaxPlusLinear.tick_square,
          onPressed: onSelectAll,
          tooltip: 'selectAll'.tr,
        ),
        _ActionButton(
          icon: IconsaxPlusLinear.repeat,
          color: colorScheme.tertiary,
          onPressed: onTransfer,
          tooltip: 'transfer'.tr,
        ),
        _ActionButton(
          icon: IconsaxPlusLinear.trash,
          color: colorScheme.error,
          onPressed: onDelete,
          tooltip: 'delete'.tr,
        ),
        SizedBox(width: AppConstants.spacingXS),
        FilledButton.tonal(
          onPressed: todoController.doMultiSelectionTodoClear,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final String? tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.color,
    this.tooltip,
  });

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
  final Widget child;

  const _AnimatedMultiSelectBar({required this.child});

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
