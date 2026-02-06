import 'package:flutter/material.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return Card(
      elevation: AppConstants.elevationLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          isMobile ? AppConstants.spacingM : AppConstants.spacingL,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusMedium,
                ),
              ),
              child: Icon(icon, size: AppConstants.iconSizeLarge, color: color),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        24,
                      ),
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        13,
                      ),
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
