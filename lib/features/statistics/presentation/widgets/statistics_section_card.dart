import 'package:flutter/material.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Card shell for statistics chart sections.
class StatisticsSectionCard extends StatelessWidget {
  /// Creates a titled statistics card wrapping [child].
  const StatisticsSectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  /// Leading section icon.
  final IconData icon;

  /// Tint color for [icon].
  final Color iconColor;

  /// Section title shown beside [icon].
  final String title;

  /// Chart or metric content below the header row.
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            child,
          ],
        ),
      ),
    );
  }
}
