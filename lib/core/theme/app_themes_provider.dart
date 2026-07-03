import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/theme/theme.dart';
import 'package:zest/core/utils/device_info.dart';

/// Inputs that determine resolved light/dark [ThemeData] instances.
@immutable
class AppThemeInputs {
  /// Creates theme resolution inputs.
  const AppThemeInputs({
    required this.materialColor,
    required this.amoledTheme,
    required this.colorPalette,
    required this.appFont,
    required this.lightDynamic,
    required this.darkDynamic,
  });

  /// Whether Material You dynamic color is enabled.
  final bool materialColor;

  /// Whether AMOLED (pure black) dark theme is enabled.
  final bool amoledTheme;

  /// Selected accent palette id.
  final String colorPalette;

  /// Selected app font id.
  final String appFont;

  /// System light dynamic scheme, when available.
  final ColorScheme? lightDynamic;

  /// System dark dynamic scheme, when available.
  final ColorScheme? darkDynamic;

  static int? _schemeKey(ColorScheme? scheme) {
    if (scheme == null) return null;
    return Object.hash(scheme.primary.toARGB32(), scheme.surface.toARGB32());
  }

  @override
  bool operator ==(Object other) {
    return other is AppThemeInputs &&
        materialColor == other.materialColor &&
        amoledTheme == other.amoledTheme &&
        colorPalette == other.colorPalette &&
        appFont == other.appFont &&
        _schemeKey(lightDynamic) == _schemeKey(other.lightDynamic) &&
        _schemeKey(darkDynamic) == _schemeKey(other.darkDynamic);
  }

  @override
  int get hashCode => Object.hash(
    materialColor,
    amoledTheme,
    colorPalette,
    appFont,
    _schemeKey(lightDynamic),
    _schemeKey(darkDynamic),
  );
}

/// Cached resolved themes; recomputes only when [AppThemeInputs] changes.
final appThemesProvider = Provider.family<AppThemes, AppThemeInputs>(
  (ref, inputs) => resolveAppThemes(
    materialColor: inputs.materialColor,
    amoledTheme: inputs.amoledTheme,
    colorPalette: inputs.colorPalette,
    lightDynamic: inputs.lightDynamic,
    darkDynamic: inputs.darkDynamic,
    edgeToEdgeAvailable: DeviceFeature().isEdgeToEdgeAvailable(),
    appFont: inputs.appFont,
  ),
);
