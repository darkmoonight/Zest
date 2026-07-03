import 'package:flutter/material.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/features/statistics/presentation/widgets/statistics_section_card.dart';
import 'package:zest/features/tasks/presentation/widgets/stat_chip.dart';

/// Widget that streak widget.
class StreakWidget extends StatelessWidget {
  /// The current streak.
  final int currentStreak;

  /// The longest streak.
  final int longestStreak;

  /// Creates a [StreakWidget].
  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StatisticsSectionCard(
      icon: IconsaxPlusBold.flash,
      iconColor: colorScheme.primary,
      title: 'streak'.tr,
      child: Row(
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
    );
  }
}
