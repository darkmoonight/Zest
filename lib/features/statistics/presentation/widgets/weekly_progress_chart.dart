import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/utils/chart_labels.dart';
import 'package:zest/features/statistics/presentation/widgets/statistics_section_card.dart';

/// Widget that weekly progress chart.
class WeeklyProgressChart extends StatelessWidget {
  /// The weekly data keyed by weekday (1 = Monday … 7 = Sunday).
  final Map<int, int> weeklyData;

  /// Creates a [WeeklyProgressChart].
  const WeeklyProgressChart({super.key, required this.weeklyData});

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekdayLabels = ChartLabels.weekdayShort();

    return StatisticsSectionCard(
      icon: IconsaxPlusBold.chart_1,
      iconColor: colorScheme.tertiary,
      title: 'weeklyProgress'.tr,
      child: SizedBox(
        height: 140,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => colorScheme.surfaceContainerHighest,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    rod.toY.toInt().toString(),
                    TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
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
                    if (value.toInt() >= 0 &&
                        value.toInt() < weekdayLabels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          weekdayLabels[value.toInt()],
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                  reservedSize: 22,
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
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: _getBarGroups(colorScheme),
          ),
        ),
      ),
    );
  }

  /// Bar chart group data.
  List<BarChartGroupData> _getBarGroups(ColorScheme colorScheme) {
    return List.generate(7, (index) {
      final weekday = index + 1;
      final value = (weeklyData[weekday] ?? 0).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            gradient: LinearGradient(
              colors: [colorScheme.tertiary, colorScheme.primary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ],
      );
    });
  }

  /// Get max y.
  double _getMaxY() {
    if (weeklyData.isEmpty) return 5;
    final maxValue = weeklyData.values.reduce((a, b) => a > b ? a : b);
    return (maxValue + 2).toDouble();
  }
}
