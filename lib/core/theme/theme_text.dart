import 'package:flutter/material.dart';

/// Shared text-style helpers for cards and detail screens.
class ThemeText {
  ThemeText._();

  /// Returns [base] with muted on-surface-variant color.
  static TextStyle? muted(
    ThemeData theme,
    TextStyle? base, {
    double height = 1.25,
  }) =>
      base?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: height);

  /// Returns the standard app bar title text style.
  static TextStyle? appBarTitle(ThemeData theme) => theme.textTheme.titleMedium
      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 18);
}
