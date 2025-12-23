import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zest/app/ui/responsive_utils.dart';
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
  ) => Card(
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

  Widget _buildTabletLayout(
    BuildContext context,
    double margin,
    double padding,
  ) => Card(
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

  Widget _buildDesktopLayout(
    BuildContext context,
    double margin,
    double padding,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1200),
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
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: isDesktop
        ? MainAxisAlignment.center
        : MainAxisAlignment.start,
    children: [
      _buildTitle(context, isDesktop: isDesktop),
      SizedBox(height: compact ? 8 : (isDesktop ? 10 : 12)),
      _buildStatsRow(context, compact: compact, isDesktop: isDesktop),
      SizedBox(height: compact ? 6 : (isDesktop ? 8 : 10)),
      _buildDateRow(context, isDesktop: isDesktop),
    ],
  );

  Widget _buildTitle(BuildContext context, {bool isDesktop = false}) => Text(
    'todoCompleted'.tr,
    style: context.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: ResponsiveUtils.getResponsiveFontSize(
        context,
        isDesktop ? 22 : 20,
      ),
      letterSpacing: -0.5,
      color: context.theme.colorScheme.onSurface,
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );

  Widget _buildStatsRow(
    BuildContext context, {
    bool compact = false,
    bool isDesktop = false,
  }) => Row(
    children: [
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : (isDesktop ? 10 : 12),
          vertical: compact ? 4 : (isDesktop ? 5 : 6),
        ),
        decoration: BoxDecoration(
          color: context.theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusLinear.tick_square,
              size: ResponsiveUtils.getResponsiveFontSize(
                context,
                isDesktop ? 15 : 16,
              ),
              color: context.theme.colorScheme.onPrimaryContainer,
            ),
            SizedBox(width: 6),
            Text(
              '$completedTodos/$createdTodos',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  isDesktop ? 13 : 14,
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 8),
      Text(
        'completed'.tr,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.theme.colorScheme.onSurfaceVariant,
          fontSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            isDesktop ? 12 : 13,
          ),
        ),
      ),
    ],
  );

  Widget _buildDateRow(BuildContext context, {bool isDesktop = false}) => Row(
    children: [
      Icon(
        IconsaxPlusLinear.calendar_2,
        size: ResponsiveUtils.getResponsiveFontSize(
          context,
          isDesktop ? 13 : 14,
        ),
        color: context.theme.colorScheme.onSurfaceVariant,
      ),
      SizedBox(width: 6),
      Flexible(
        child: Text(
          DateFormat.MMMMEEEEd(locale.languageCode).format(DateTime.now()),
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              isDesktop ? 12 : 13,
            ),
            color: context.theme.colorScheme.onSurfaceVariant,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _buildCircularSlider(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    final size = isMobile ? 70.0 : (isDesktop ? 95.0 : 90.0);
    final progressBarWidth = isMobile ? 8.0 : (isDesktop ? 9.0 : 10.0);
    final containerPadding = isMobile ? 8.0 : (isDesktop ? 10.0 : 12.0);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: SleekCircularSlider(
        appearance: CircularSliderAppearance(
          animationEnabled: false,
          angleRange: 360,
          startAngle: 270,
          size: size,
          infoProperties: InfoProperties(
            modifier: (percentage) => createdTodos != 0 ? '$percent%' : '0%',
            mainLabelStyle: context.textTheme.labelLarge?.copyWith(
              fontSize: ResponsiveUtils.getResponsiveFontSize(
                context,
                isDesktop ? 18 : 20,
              ),
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: colorScheme.onSurface,
            ),
          ),
          customColors: CustomSliderColors(
            progressBarColors: [colorScheme.primary, colorScheme.tertiary],
            trackColor: colorScheme.surfaceContainerHighest,
          ),
          customWidths: CustomSliderWidths(
            progressBarWidth: progressBarWidth,
            trackWidth: 4,
            handlerSize: 0,
            shadowWidth: 0,
          ),
        ),
        min: 0,
        max: createdTodos != 0 ? createdTodos.toDouble() : 1,
        initialValue: completedTodos.toDouble(),
      ),
    );
  }
}
