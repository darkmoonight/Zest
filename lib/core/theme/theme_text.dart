import 'package:material_ui/material_ui.dart';

/// Shared text-style helpers for cards and detail screens.
class ThemeText {
  ThemeText._();

  /// Returns the standard app bar title text style.
  static TextStyle? appBarTitle(ThemeData theme) => theme.textTheme.titleMedium
      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18);
}
