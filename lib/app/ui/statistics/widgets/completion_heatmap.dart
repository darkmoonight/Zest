import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:get/get.dart';
import 'package:zest/app/constants/app_constants.dart';

class CompletionHeatmap extends StatelessWidget {
  final Map<DateTime, int> heatmapData;

  const CompletionHeatmap({super.key, required this.heatmapData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: AppConstants.elevationLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: HeatMapCalendar(
          datasets: heatmapData,
          colorMode: ColorMode.color,
          defaultColor: colorScheme.surfaceContainerHighest,
          flexible: true,
          colorsets: {
            1: colorScheme.primary.withValues(alpha: 0.2),
            3: colorScheme.primary.withValues(alpha: 0.4),
            5: colorScheme.primary.withValues(alpha: 0.6),
            7: colorScheme.primary.withValues(alpha: 0.8),
            10: colorScheme.primary,
          },
          onClick: (value) {
            final count = heatmapData[value] ?? 0;
            if (count > 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${value.day}/${value.month}/${value.year}: $count ${'completed'.tr}',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: colorScheme.surface,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                  margin: const EdgeInsets.all(AppConstants.spacingL),
                  elevation: AppConstants.elevationMedium,
                ),
              );
            }
          },
          showColorTip: false,
          size: 30,
          fontSize: 10,
          monthFontSize: 12,
          weekFontSize: 10,
          textColor: colorScheme.onSurface,
          weekTextColor: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
