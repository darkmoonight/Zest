import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Drag handle shown at the top of modal bottom sheets on mobile.
class ModalSheetDragHandle extends StatelessWidget {
  /// Creates a drag handle hidden on non-mobile layouts when [isMobile] is false.
  const ModalSheetDragHandle({super.key, required this.isMobile});

  /// Whether the current layout is mobile width.
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    if (!isMobile) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(
        top: AppConstants.spacingM,
        bottom: AppConstants.spacingS,
      ),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
