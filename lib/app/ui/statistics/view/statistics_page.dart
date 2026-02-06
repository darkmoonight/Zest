import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/statistics/models/statistics_data.dart';
import 'package:zest/app/ui/statistics/services/statistics_service.dart';
import 'package:zest/app/ui/statistics/widgets/completion_heatmap.dart';
import 'package:zest/app/ui/statistics/widgets/stats_card.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final TodoController _todoController = Get.find<TodoController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          _todoController.todos.length;
          _todoController.tasks.length;

          return FutureBuilder<StatisticsData>(
            future: StatisticsService.calculateStatistics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _buildErrorState();
              }

              if (!snapshot.hasData) {
                return _buildEmptyState();
              }

              return _buildContent(snapshot.data!);
            },
          );
        }),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconsaxPlusLinear.info_circle,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'errorLoadingStatistics'.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconsaxPlusLinear.chart,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'noStatisticsAvailable'.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(StatisticsData data) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = isMobile ? AppConstants.spacingL : AppConstants.spacingXXL;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(padding),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildPageTitle(),
              const SizedBox(height: AppConstants.spacingL),
              _buildOverviewCards(data),
              const SizedBox(height: AppConstants.spacingXL),
              _buildHeatmapSection(data),
              const SizedBox(height: AppConstants.spacingXXL),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildPageTitle() {
    return Text(
      'statistics'.tr,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildOverviewCards(StatisticsData data) {
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

  Widget _buildHeatmapSection(StatisticsData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
          child: Text(
            'activityHeatmap'.tr,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        CompletionHeatmap(heatmapData: data.completionHeatmap),
      ],
    );
  }
}
