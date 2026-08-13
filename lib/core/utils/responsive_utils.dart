import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Breakpoints and layout helpers for responsive UI.
///
/// Width bands:
/// - mobile: `< [mobileBreakpoint]` (600)
/// - tablet: `[mobileBreakpoint]` … `< [tabletBreakpoint]` (1024)
/// - desktop: `≥ [tabletBreakpoint]`
class ResponsiveUtils {
  /// Maximum width treated as mobile layout.
  static const double mobileBreakpoint = 600;

  /// Width at which tablet ends and desktop begins.
  static const double tabletBreakpoint = 1024;

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

  /// Whether create/edit forms should open as a centered dialog.
  static bool useDialogForForms(BuildContext context) => !isMobile(context);

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

  /// Empty-state top offset below the status/app bar area.
  static double getEmptyStateTopOffset(BuildContext context) =>
      isMobile(context)
      ? AppConstants.emptyStateTopOffsetMobile
      : AppConstants.emptyStateTopOffsetWide;

  /// Default circular progress diameter for task cards.
  static double getTaskCardCircularSliderSize(BuildContext context) {
    if (isMobile(context)) return AppConstants.circularProgressSizeMobile;
    if (isTablet(context)) return AppConstants.circularProgressSizeTablet;
    return AppConstants.circularProgressSizeDesktop;
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
