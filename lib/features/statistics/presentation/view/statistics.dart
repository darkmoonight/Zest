import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/widgets/list_empty.dart';
import 'package:zest/features/statistics/application/statistics_provider.dart';
import 'package:zest/features/statistics/presentation/models/statistics_data.dart';
import 'package:zest/features/statistics/presentation/widgets/completion_heatmap.dart';
import 'package:zest/features/statistics/presentation/widgets/hourly_progress_chart.dart';
import 'package:zest/features/statistics/presentation/widgets/stats_card.dart';
import 'package:zest/features/statistics/presentation/widgets/streak_widget.dart';
import 'package:zest/features/statistics/presentation/widgets/weekly_progress_chart.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

/// Statistics tab showing completion metrics, charts, and heatmap.
class StatisticsPage extends ConsumerWidget {
  /// Creates a [StatisticsPage].
  const StatisticsPage({super.key});

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      body: SafeArea(
        child: statisticsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _buildErrorState(context, ref),
          data: (data) {
            if (data.totalTodos == 0) {
              return _buildEmptyState(context, ref);
            }
            return _buildContent(context, data);
          },
        ),
      ),
    );
  }

  /// Builds the empty state widget.
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final isImage = ref.watch(appSettingsProvider).isImage;

    return ListEmpty(
      img: AppConstants.emptyStateTaskImage,
      text: 'statistics'.tr,
      subtitle: 'statisticsEmptyHint'.tr,
      icon: !isImage ? IconsaxPlusBold.chart : null,
    );
  }

  /// Builds the error state widget.
  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    final isImage = ref.watch(appSettingsProvider).isImage;

    return ListEmpty(
      img: AppConstants.emptyStateTaskImage,
      text: 'errorLoadingStatistics'.tr,
      icon: !isImage ? IconsaxPlusBold.info_circle : null,
      iconColor: Theme.of(context).colorScheme.error,
    );
  }

  /// Builds the content widget.
  Widget _buildContent(BuildContext context, StatisticsData data) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? AppConstants.spacingS
                : AppConstants.spacingM,
            vertical: AppConstants.spacingXS,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildOverviewCards(context, data),
              const SizedBox(height: AppConstants.spacingM),
              StreakWidget(
                currentStreak: data.currentStreak,
                longestStreak: data.longestStreak,
              ),
              const SizedBox(height: AppConstants.spacingM),
              WeeklyProgressChart(weeklyData: data.weeklyProgress),
              const SizedBox(height: AppConstants.spacingM),
              HourlyProgressChart(hourlyData: data.hourlyProgress),
              const SizedBox(height: AppConstants.spacingL),
              CompletionHeatmap(heatmapData: data.completionHeatmap),
              const SizedBox(height: AppConstants.spacingXL),
            ]),
          ),
        ),
      ],
    );
  }

  /// Builds the overview cards widget.
  Widget _buildOverviewCards(BuildContext context, StatisticsData data) {
    final isMobile = ResponsiveUtils.isMobile(context);

    return isMobile
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: AppConstants.spacingXS,
                      ),
                      child: StatsCard(
                        title: 'todayCompleted'.tr,
                        value: data.todayCompleted.toString(),
                        icon: IconsaxPlusBold.tick_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppConstants.spacingXS,
                      ),
                      child: StatsCard(
                        title: 'weekCompleted'.tr,
                        value: data.weekCompleted.toString(),
                        icon: IconsaxPlusBold.calendar_tick,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingXS + 2),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: AppConstants.spacingXS,
                      ),
                      child: StatsCard(
                        title: 'totalTodos'.tr,
                        value: data.totalTodos.toString(),
                        icon: IconsaxPlusBold.task_square,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppConstants.spacingXS,
                      ),
                      child: StatsCard(
                        title: 'completionRate'.tr,
                        value: '${data.completionRate.toStringAsFixed(1)}%',
                        icon: IconsaxPlusBold.chart_success,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Expanded(
                child: StatsCard(
                  title: 'todayCompleted'.tr,
                  value: data.todayCompleted.toString(),
                  icon: IconsaxPlusBold.tick_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingXS + 2),
              Expanded(
                child: StatsCard(
                  title: 'weekCompleted'.tr,
                  value: data.weekCompleted.toString(),
                  icon: IconsaxPlusBold.calendar_tick,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingXS + 2),
              Expanded(
                child: StatsCard(
                  title: 'totalTodos'.tr,
                  value: data.totalTodos.toString(),
                  icon: IconsaxPlusBold.task_square,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingXS + 2),
              Expanded(
                child: StatsCard(
                  title: 'completionRate'.tr,
                  value: '${data.completionRate.toStringAsFixed(1)}%',
                  icon: IconsaxPlusBold.chart_success,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ],
          );
  }
}
