import 'package:material_ui/material_ui.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';

class SortMenu extends StatelessWidget {
  /// Creates a [SortMenu].
  const SortMenu({
    super.key,
    required this.currentSortOption,
    required this.onSortChanged,
    this.showArchived,
    this.onShowArchivedChanged,
  });

  /// The current sort option.
  final SortOption currentSortOption;

  /// The on sort changed.
  final ValueChanged<SortOption> onSortChanged;

  /// Whether archived categories are visible (All Items only).
  final bool? showArchived;

  /// Called when the archived-categories toggle changes.
  final ValueChanged<bool>? onShowArchivedChanged;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<SortOption>(
      icon: Icon(
        IconsaxPlusLinear.sort,
        color: colorScheme.onSurface,
        size: AppConstants.iconSizeMedium,
      ),
      tooltip: 'sort'.tr,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      elevation: AppConstants.elevationMedium,
      offset: const Offset(0, 8),
      onSelected: onSortChanged,
      itemBuilder: (context) => [
        _buildMenuItem(
          context,
          SortOption.none,
          'sortByIndex'.tr,
          IconsaxPlusLinear.minus,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          SortOption.alphaAsc,
          'sortByNameAsc'.tr,
          IconsaxPlusLinear.sort,
        ),
        _buildMenuItem(
          context,
          SortOption.alphaDesc,
          'sortByNameDesc'.tr,
          IconsaxPlusLinear.sort,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          SortOption.dateAsc,
          'sortByDateAsc'.tr,
          IconsaxPlusLinear.calendar,
        ),
        _buildMenuItem(
          context,
          SortOption.dateDesc,
          'sortByDateDesc'.tr,
          IconsaxPlusLinear.calendar,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          SortOption.dateNotifAsc,
          'sortByDateNotifAsc'.tr,
          IconsaxPlusLinear.notification,
        ),
        _buildMenuItem(
          context,
          SortOption.dateNotifDesc,
          'sortByDateNotifDesc'.tr,
          IconsaxPlusLinear.notification,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          SortOption.priorityAsc,
          'sortByPriorityAsc'.tr,
          IconsaxPlusLinear.flag,
        ),
        _buildMenuItem(
          context,
          SortOption.priorityDesc,
          'sortByPriorityDesc'.tr,
          IconsaxPlusLinear.flag,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context,
          SortOption.random,
          'sortByRandom'.tr,
          IconsaxPlusLinear.shuffle,
        ),
        if (showArchived != null && onShowArchivedChanged != null) ...[
          const PopupMenuDivider(),
          _buildShowArchivedItem(context),
        ],
      ],
    );
  }

  /// Checkbox-style menu item for toggling archived categories in All Items.
  PopupMenuItem<SortOption> _buildShowArchivedItem(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isChecked = showArchived!;

    return PopupMenuItem<SortOption>(
      onTap: () => onShowArchivedChanged!(!isChecked),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.archive,
            size: AppConstants.iconSizeSmall + 2,
            color: isChecked
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              'showArchived'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: isChecked ? FontWeight.w600 : FontWeight.w500,
                color: isChecked ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
          if (isChecked)
            Icon(
              IconsaxPlusBold.tick_circle,
              size: AppConstants.iconSizeSmall,
              color: colorScheme.primary,
            ),
        ],
      ),
    );
  }

  /// Sort option.
  PopupMenuItem<SortOption> _buildMenuItem(
    BuildContext context,
    SortOption option,
    String label,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = currentSortOption == option;

    return PopupMenuItem<SortOption>(
      value: option,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingS,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: AppConstants.iconSizeSmall + 2,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              IconsaxPlusBold.tick_circle,
              size: AppConstants.iconSizeSmall,
              color: colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
