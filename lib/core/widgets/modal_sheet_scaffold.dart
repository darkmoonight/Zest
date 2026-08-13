import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/widgets/modal_sheet_drag_handle.dart';

/// Standard shell for modal bottom sheets with drag handle and animated body.
class ModalSheetScaffold extends StatelessWidget {
  /// Creates a [ModalSheetScaffold].
  const ModalSheetScaffold({
    super.key,
    required this.isMobile,
    required this.maxHeightFractionMobile,
    required this.maxHeightFractionDesktop,
    required this.onPopInvokedWithResult,
    required this.header,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.body,
  });

  /// Whether the layout is mobile width.
  final bool isMobile;

  /// Max height fraction on mobile.
  final double maxHeightFractionMobile;

  /// Max height fraction on desktop.
  final double maxHeightFractionDesktop;

  /// Back navigation handler with unsaved-changes guard.
  final PopInvokedWithResultCallback<dynamic> onPopInvokedWithResult;

  /// Header row below the drag handle.
  final Widget header;

  /// Fade animation for the body.
  final Animation<double> fadeAnimation;

  /// Slide animation for the body.
  final Animation<Offset> slideAnimation;

  /// Scrollable form content.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : AppConstants.maxModalWidth,
          maxHeight:
              MediaQuery.of(context).size.height *
              (isMobile ? maxHeightFractionMobile : maxHeightFractionDesktop),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ModalSheetDragHandle(isMobile: isMobile),
            header,
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(
                alpha: AppConstants.opacityMedium,
              ),
            ),
            Flexible(
              child: FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(position: slideAnimation, child: body),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
