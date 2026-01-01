import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart' show IconsaxPlusBold;
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zest/app/utils/progress_calculator.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class CircularProgressWidget extends StatelessWidget {
  final int total;
  final int completed;
  final Color progressColor;
  final double? size;
  final bool showCompletedIcon;
  final Widget? completedWidget;

  const CircularProgressWidget({
    super.key,
    required this.total,
    required this.completed,
    required this.progressColor,
    this.size,
    this.showCompletedIcon = false,
    this.completedWidget,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    final calculatedSize =
        size ?? (isMobile ? 54.0 : (isDesktop ? 70.0 : 62.0));
    final progress = ProgressCalculator(total: total, completed: completed);

    if (progress.isComplete && showCompletedIcon) {
      return completedWidget ??
          _buildCompletedIcon(calculatedSize, colorScheme);
    }

    return _buildCircularSlider(
      context,
      calculatedSize,
      progress,
      colorScheme,
      isMobile,
      isDesktop,
    );
  }

  Widget _buildCompletedIcon(double size, ColorScheme colorScheme) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: progressColor.withValues(alpha: 0.15),
        border: Border.all(
          color: progressColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Icon(
        IconsaxPlusBold.tick_circle,
        size: size * 0.45,
        color: progressColor,
      ),
    );
  }

  Widget _buildCircularSlider(
    BuildContext context,
    double size,
    ProgressCalculator progress,
    ColorScheme colorScheme,
    bool isMobile,
    bool isDesktop,
  ) {
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        animationEnabled: false,
        angleRange: 360,
        startAngle: 270,
        size: size,
        infoProperties: InfoProperties(
          modifier: (value) => '${progress.percentage}%',
          mainLabelStyle: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: ResponsiveUtils.getResponsiveFontSize(
              context,
              isMobile ? 12 : (isDesktop ? 15 : 13),
            ),
            letterSpacing: -0.3,
            color: colorScheme.onSurface,
          ),
        ),
        customColors: CustomSliderColors(
          progressBarColor: progressColor,
          trackColor: colorScheme.surfaceContainerHighest,
          gradientStartAngle: 270,
          gradientEndAngle: 270 + 360,
          shadowColor: progressColor.withValues(alpha: 0.3),
          shadowMaxOpacity: 0.1,
        ),
        customWidths: CustomSliderWidths(
          progressBarWidth: isMobile ? 5 : (isDesktop ? 7 : 6),
          trackWidth: isMobile ? 5 : (isDesktop ? 7 : 6),
          handlerSize: 0,
          shadowWidth: 3,
        ),
      ),
      min: 0,
      max: total != 0 ? total.toDouble() : 1,
      initialValue: completed.toDouble(),
    );
  }
}
