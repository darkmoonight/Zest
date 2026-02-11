import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/ui/tasks/widgets/stat_chip.dart';

class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: AppConstants.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  IconsaxPlusBold.flash,
                  color: colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  'streak'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: StatChip(
                    icon: IconsaxPlusBold.flash,
                    label: 'currentStreak'.tr,
                    value: currentStreak.toString(),
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    textColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Expanded(
                  child: StatChip(
                    icon: IconsaxPlusBold.medal_star,
                    label: 'longestStreak'.tr,
                    value: longestStreak.toString(),
                    color: colorScheme.tertiary.withValues(alpha: 0.15),
                    textColor: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
