import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/main.dart';

class HourlyProgressChart extends StatelessWidget {
  final Map<int, int> hourlyData;

  const HourlyProgressChart({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final periodData = _groupByPeriod();
    final is12Hour = timeformat.value == '12';

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
                  IconsaxPlusBold.clock,
                  color: colorScheme.secondary,
                  size: 18,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  'hourlyProgress'.tr,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxY(periodData),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) =>
                          colorScheme.surfaceContainerHighest,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final periods = [
                          'Night',
                          'Morning',
                          'Afternoon',
                          'Evening',
                        ];
                        return BarTooltipItem(
                          '${periods[group.x.toInt()]}\n${rod.toY.toInt()}',
                          TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = is12Hour
                              ? ['12-6 AM', '6-12 AM', '12-6 PM', '6-12 PM']
                              : ['0-6', '6-12', '12-18', '18-24'];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                labels[value.toInt()],
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 32,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.end,
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  barGroups: _getBarGroups(periodData, colorScheme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, int> _groupByPeriod() {
    final periods = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};

    for (var entry in hourlyData.entries) {
      final hour = entry.key;
      final count = entry.value;

      if (hour >= 0 && hour < 6) {
        periods[0] = (periods[0] ?? 0) + count;
      } else if (hour >= 6 && hour < 12) {
        periods[1] = (periods[1] ?? 0) + count;
      } else if (hour >= 12 && hour < 18) {
        periods[2] = (periods[2] ?? 0) + count;
      } else {
        periods[3] = (periods[3] ?? 0) + count;
      }
    }

    return periods;
  }

  List<BarChartGroupData> _getBarGroups(
    Map<int, int> periodData,
    ColorScheme colorScheme,
  ) {
    final colors = [
      [colorScheme.primary.withValues(alpha: 0.7), colorScheme.primary],
      [colorScheme.secondary, colorScheme.primary],
      [colorScheme.tertiary, colorScheme.secondary],
      [colorScheme.secondary.withValues(alpha: 0.7), colorScheme.tertiary],
    ];

    return List.generate(4, (index) {
      final value = (periodData[index] ?? 0).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            gradient: LinearGradient(
              colors: colors[index],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 32,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    });
  }

  double _getMaxY(Map<int, int> periodData) {
    if (periodData.isEmpty) return 5;
    final maxValue = periodData.values.reduce((a, b) => a > b ? a : b);
    return (maxValue + 2).toDouble();
  }
}
