import 'package:flutter/material.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Breakpoints and layout helpers for responsive UI.
class ResponsiveUtils {
  /// Maximum width treated as mobile layout.
  static const double mobileBreakpoint = 600;

  /// Maximum width treated as tablet layout.
  static const double tabletBreakpoint = 1024;

  /// Minimum width treated as desktop layout.
  static const double desktopBreakpoint = 1440;

  /// Whether [context] width is below [mobileBreakpoint].
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Whether [context] width is between mobile and tablet breakpoints.
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Whether [context] width is at or above [tabletBreakpoint].
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Returns screen-edge padding for the current form factor.
  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return 10;
    if (isTablet(context)) return 16;
    return 24;
  }

  /// Returns outer card margin for the current form factor.
  static double getResponsiveCardMargin(BuildContext context) {
    if (isMobile(context)) return 10;
    if (isTablet(context)) return 12;
    return 16;
  }

  /// Scales [baseFontSize] up on larger form factors.
  static double getResponsiveFontSize(
    BuildContext context,
    double baseFontSize,
  ) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  /// Returns grid column count for the current form factor.
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  /// Returns max content width, or infinity on smaller screens.
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return AppConstants.maxDesktopWidth;
    return double.infinity;
  }

  /// Returns uniform edge insets from [getResponsivePadding].
  static EdgeInsets getResponsiveEdgeInsets(BuildContext context) {
    final padding = getResponsivePadding(context);
    return EdgeInsets.all(padding);
  }

  /// Returns circular progress indicator diameter for the current form factor.
  static double getCircularSliderSize(BuildContext context) {
    if (isMobile(context)) return 70;
    if (isTablet(context)) return 90;
    return 110;
  }

  /// Returns task-card circular progress size for the current form factor.
  static double getTaskCardCircularSliderSize(BuildContext context) {
    if (isMobile(context)) return 60;
    if (isTablet(context)) return 70;
    return 80;
  }
}

/// Picks [mobile], [tablet], or [desktop] child by max width.
class ResponsiveLayout extends StatelessWidget {
  /// Creates a layout that switches children by breakpoint.
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Widget shown below [mobileBreakpoint].
  final Widget mobile;

  /// Widget shown on tablet widths; falls back to [mobile].
  final Widget? tablet;

  /// Widget shown on desktop widths; falls back to [tablet] then [mobile].
  final Widget? desktop;

  /// Builds the child matching the current max width breakpoint.
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveUtils.tabletBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveUtils.mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Centers [child] and constrains width on desktop layouts.
class ResponsiveCenter extends StatelessWidget {
  /// Creates a centered, width-constrained wrapper around [child].
  const ResponsiveCenter({super.key, required this.child});

  /// Content to center and optionally constrain.
  final Widget child;

  /// Builds [child] inside a max-width constraint on desktop.
  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);

    if (maxWidth == double.infinity) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
