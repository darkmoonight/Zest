import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/i18n/tr.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

/// Yearly completion activity heatmap with localized date tooltips.
class CompletionHeatmap extends ConsumerWidget {
  /// Creates a heatmap for [heatmapData] keyed by completion date.
  const CompletionHeatmap({super.key, required this.heatmapData});

  /// Daily completion counts for the past year.
  final Map<DateTime, int> heatmapData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final appSettings = ref.watch(appSettingsProvider);

    return Card(
      elevation: AppConstants.elevationLow,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'activityHeatmap'.tr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppConstants.spacingM),
            HeatMapCalendar(
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
                  final formattedDate = DateTimeFormatHelper.formatDateTime(
                    value,
                    timeformat: appSettings.timeformat,
                    languageCode: appSettings.locale.languageCode,
                  );
                  showSnackBar(
                    'heatmapTooltip'.trFormat({
                      'date': formattedDate,
                      'count': count,
                    }),
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
          ],
        ),
      ),
    );
  }
}
