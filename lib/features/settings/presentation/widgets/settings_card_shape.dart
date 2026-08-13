import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Shared card shape and divider styling for settings sections.
abstract final class SettingsCardShape {
  /// Returns the card border shape for AMOLED theme, or null otherwise.
  static ShapeBorder? cardShape({
    required bool amoledTheme,
    required ColorScheme colorScheme,
  }) {
    if (!amoledTheme) return null;

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusXLarge),
      side: BorderSide(
        color: settingsDividerColor(colorScheme),
        width: AppConstants.borderWidthThin,
      ),
    );
  }

  /// Returns the divider color used by settings cards.
  static Color settingsDividerColor(ColorScheme colorScheme) =>
      colorScheme.outlineVariant.withValues(alpha: 0.3);
}
