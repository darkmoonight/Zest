import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/main.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    super.key,
    required this.createdTodos,
    required this.completedTodos,
    required this.percent,
  });

  final int createdTodos;
  final int completedTodos;
  final String percent;

  String _getMotivationalText() {
    final progress = createdTodos > 0
        ? (completedTodos / createdTodos * 100).round()
        : 0;

    if (progress == 100) return 'perfectWork'.tr;
    if (progress >= 80) return 'almostDone'.tr;
    if (progress >= 50) return 'keepGoing'.tr;
    if (progress > 0) return 'goodStart'.tr;
    return 'letsStart'.tr;
  }

  @override
  Widget build(BuildContext context) {
    final margin = ResponsiveUtils.getResponsiveCardMargin(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return ResponsiveLayout(
      mobile: _buildMobileLayout(context, margin, padding),
      tablet: _buildTabletLayout(context, margin, padding),
      desktop: _buildDesktopLayout(context, margin, padding),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    double margin,
    double padding,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: margin, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(padding * 1.5),
        child: Row(
          children: [
            Expanded(child: _buildTextColumn(context, compact: true)),
            SizedBox(width: padding * 1.5),
            _buildCircularSlider(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    double margin,
    double padding,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: margin, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(padding * 2),
        child: Row(
          children: [
            Expanded(child: _buildTextColumn(context)),
            SizedBox(width: padding * 2),
            _buildCircularSlider(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    double margin,
    double padding,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: margin, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: padding * 2,
            vertical: padding * 1.5,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextColumn(context, isDesktop: true),
                ),
                SizedBox(width: padding * 2),
                _buildCircularSlider(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextColumn(
    BuildContext context, {
    bool compact = false,
    bool isDesktop = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isDesktop
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        _buildTitle(context, isDesktop: isDesktop),
        SizedBox(height: compact ? 10 : (isDesktop ? 12 : 14)),
        _buildStatsRow(context, compact: compact, isDesktop: isDesktop),
        SizedBox(height: compact ? 8 : (isDesktop ? 10 : 12)),
        _buildDateRow(context, isDesktop: isDesktop),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, {bool isDesktop = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            IconsaxPlusBold.chart_success,
            size: ResponsiveUtils.getResponsiveFontSize(
              context,
              isDesktop ? 20 : 18,
            ),
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getMotivationalText(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(
                    context,
                    isDesktop ? 20 : 18,
                  ),
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'tasksProgress'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(
    BuildContext context, {
    bool compact = false,
    bool isDesktop = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildStatChip(
          context,
          icon: IconsaxPlusBold.tick_circle,
          label: 'completed'.tr,
          value: '$completedTodos',
          color: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimaryContainer,
          compact: compact,
          isDesktop: isDesktop,
        ),
        _buildStatChip(
          context,
          icon: IconsaxPlusBold.clock,
          label: 'remaining'.tr,
          value: '${createdTodos - completedTodos}',
          color: colorScheme.secondaryContainer,
          textColor: colorScheme.onSecondaryContainer,
          compact: compact,
          isDesktop: isDesktop,
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color textColor,
    bool compact = false,
    bool isDesktop = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : (isDesktop ? 12 : 14),
        vertical: compact ? 6 : (isDesktop ? 7 : 8),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.getResponsiveFontSize(
              context,
              isDesktop ? 14 : 15,
            ),
            color: textColor,
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                isDesktop ? 14 : 15,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor.withValues(alpha: 0.8),
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                isDesktop ? 11 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, {bool isDesktop = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.calendar_2,
            size: ResponsiveUtils.getResponsiveFontSize(
              context,
              isDesktop ? 13 : 14,
            ),
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              DateFormat.MMMMEEEEd(locale.languageCode).format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  isDesktop ? 12 : 13,
                ),
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularSlider(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    final size = isMobile ? 85.0 : (isDesktop ? 110.0 : 105.0);
    final progressBarWidth = isMobile ? 9.0 : (isDesktop ? 11.0 : 10.0);

    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        animationEnabled: true,
        animDurationMultiplier: 1.5,
        angleRange: 360,
        startAngle: 270,
        size: size,
        infoProperties: InfoProperties(
          modifier: (percentage) => createdTodos != 0 ? '$percent%' : '0%',
          mainLabelStyle: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              isDesktop ? 20 : 18,
            ),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        customColors: CustomSliderColors(
          progressBarColor: colorScheme.primary,
          trackColor: colorScheme.surfaceContainerHighest,
        ),
        customWidths: CustomSliderWidths(
          progressBarWidth: progressBarWidth,
          trackWidth: progressBarWidth,
          handlerSize: 0,
          shadowWidth: 0,
        ),
      ),
      min: 0,
      max: createdTodos != 0 ? createdTodos.toDouble() : 1,
      initialValue: completedTodos.toDouble(),
    );
  }
}
