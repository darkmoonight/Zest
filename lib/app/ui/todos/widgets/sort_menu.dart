import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class SortMenu extends StatelessWidget {
  const SortMenu({
    super.key,
    required this.currentSortOption,
    required this.onSortChanged,
  });

  final SortOption currentSortOption;
  final ValueChanged<SortOption> onSortChanged;

  @override
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
      ],
    );
  }

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
