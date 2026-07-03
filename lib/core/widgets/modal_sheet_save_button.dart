import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Animated save button for modal bottom sheets.
class ModalSheetSaveButton extends StatelessWidget {
  /// Creates a save button that enables when [canCompose] is true.
  const ModalSheetSaveButton({
    super.key,
    required this.canComposeListenable,
    required this.onSave,
    required this.accentColor,
    required this.onAccentColor,
    required this.label,
  });

  /// Notifier that drives enabled/disabled styling.
  final ValueListenable<bool> canComposeListenable;

  /// Called when save is pressed while enabled.
  final VoidCallback onSave;

  /// Background color when the form can be saved.
  final Color accentColor;

  /// Icon and label color when the form can be saved.
  final Color onAccentColor;

  /// Button label, usually `'ready'.tr`.
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: canComposeListenable,
      builder: (context, canCompose, _) {
        return AnimatedScale(
          scale: canCompose ? 1.0 : 0.92,
          duration: AppConstants.longAnimation,
          curve: Curves.easeOutCubic,
          child: Material(
            color: canCompose ? accentColor : colorScheme.surfaceContainerHigh,
            elevation: canCompose ? AppConstants.elevationLow : 0,
            shadowColor: accentColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusXLarge,
            ),
            child: InkWell(
              onTap: canCompose ? onSave : null,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusXLarge,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppConstants.spacingS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusBold.tick_circle,
                      size: AppConstants.iconSizeSmall,
                      color: canCompose
                          ? onAccentColor
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      label,
                      style: TextStyle(
                        color: canCompose
                            ? onAccentColor
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
