import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zest/app/ui/tasks/widgets/common_container.dart';
import 'package:zest/app/ui/tasks/widgets/stat_chip.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/progress_calculator.dart';
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

  ProgressCalculator get _progress =>
      ProgressCalculator(total: createdTodos, completed: completedTodos);

  String get _motivationalText {
    if (_progress.isComplete) return 'perfectWork'.tr;
    if (_progress.percentage >= 75) return 'almostDone'.tr;
    if (_progress.percentage >= 50) return 'keepGoing'.tr;
    if (_progress.percentage > 25) return 'goodStart'.tr;
    return 'letsStart'.tr;
  }

  IconData get _achievementIcon {
    if (_progress.isComplete) return IconsaxPlusBold.cup;
    if (_progress.percentage >= 75) return IconsaxPlusBold.medal_star;
    if (_progress.percentage >= 50) return IconsaxPlusBold.crown;
    if (_progress.percentage >= 25) return IconsaxPlusBold.star;
    return IconsaxPlusBold.flag;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(context),
      tablet: _buildTabletLayout(context),
      desktop: _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final margin = ResponsiveUtils.getResponsiveCardMargin(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: margin,
        vertical: AppConstants.spacingXS + 1,
      ),
      elevation: AppConstants.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding * 1.2),
        child: Column(
          children: [
            _buildMobileHeader(context, colorScheme),
            SizedBox(height: AppConstants.spacingM),
            _buildMobileStatsRow(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: AppConstants.animationDuration,
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: IconContainer(
            icon: _achievementIcon,
            size: 60,
            iconSize: 28,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: AppConstants.spacingM + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _motivationalText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppConstants.spacingXS),
              Text(
                'todosProgress'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppConstants.spacingS),
              _buildProgressBar(context, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: _progress.progress),
      duration: AppConstants.longAnimation,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.spacingXS),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: AppConstants.spacingS,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                ),
              ),
            ),
            SizedBox(width: AppConstants.spacingS),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w900,
                color: colorScheme.primary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileStatsRow(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: StatChip(
            icon: IconsaxPlusBold.tick_square,
            value: '$completedTodos',
            label: 'completed'.tr,
            color: colorScheme.primary.withValues(alpha: 0.15),
            textColor: colorScheme.primary,
            compact: true,
          ),
        ),
        SizedBox(width: AppConstants.spacingS),
        Expanded(
          child: StatChip(
            icon: IconsaxPlusBold.task_square,
            value: '${_progress.remaining}',
            label: 'remaining'.tr,
            color: colorScheme.tertiary.withValues(alpha: 0.15),
            textColor: colorScheme.tertiary,
            compact: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final margin = ResponsiveUtils.getResponsiveCardMargin(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: margin,
        vertical: AppConstants.spacingXS + 1,
      ),
      elevation: AppConstants.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
      ),
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

  Widget _buildDesktopLayout(BuildContext context) {
    final margin = ResponsiveUtils.getResponsiveCardMargin(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: AppConstants.maxDesktopWidth),
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: margin,
          vertical: AppConstants.spacingXS,
        ),
        elevation: AppConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
        ),
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
        IconContainer(
          icon: _achievementIcon,
          size: 44,
          iconSize: ResponsiveUtils.getResponsiveFontSize(
            context,
            isDesktop ? 20 : 18,
          ),
        ),
        SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _motivationalText,
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
              SizedBox(height: AppConstants.spacingXS),
              Text(
                'todosProgress'.tr,
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
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingS,
      children: [
        StatChip(
          icon: IconsaxPlusBold.tick_circle,
          label: 'completed'.tr,
          value: '$completedTodos',
          color: colorScheme.primaryContainer,
          textColor: colorScheme.onPrimaryContainer,
          compact: compact,
        ),
        StatChip(
          icon: IconsaxPlusBold.clock,
          label: 'remaining'.tr,
          value: '${_progress.remaining}',
          color: colorScheme.secondaryContainer,
          textColor: colorScheme.onSecondaryContainer,
          compact: compact,
        ),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context, {bool isDesktop = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS + 2,
        vertical: AppConstants.spacingXS + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppConstants.spacingS),
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
          SizedBox(width: AppConstants.spacingXS + 2),
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

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: completedTodos.toDouble()),
      duration: AppConstants.longAnimation,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SleekCircularSlider(
          appearance: CircularSliderAppearance(
            animationEnabled: false,
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
          initialValue: value,
        );
      },
    );
  }
}
