import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zest/core/config/settings_catalog.dart';

typedef _TextThemeBuilder = TextTheme Function(TextTheme);

/// One row in the app font picker ([id] is stored in Isar settings).
class _FontEntry {
  const _FontEntry(this.id, this.textTheme);

  final String id;
  final _TextThemeBuilder textTheme;
}

/// Built-in app font choices (Google Fonts or platform default).
class AppFont {
  /// Private constructor; use static methods only.
  AppFont._();

  /// Ubuntu font id.
  static const String ubuntu = 'ubuntu';

  /// Platform system font id.
  static const String system = 'system';

  /// Default font id when none is stored.
  static const String defaultId = ubuntu;

  static const String _labelPrefix = 'font';

  static final List<_FontEntry> _catalog = [
    _FontEntry(ubuntu, GoogleFonts.ubuntuTextTheme),
    _FontEntry(system, _systemTextTheme),
    _FontEntry('barlowCondensed', GoogleFonts.barlowCondensedTextTheme),
    _FontEntry('comfortaa', GoogleFonts.comfortaaTextTheme),
    _FontEntry('dmSans', GoogleFonts.dmSansTextTheme),
    _FontEntry('figtree', GoogleFonts.figtreeTextTheme),
    _FontEntry('firaSans', GoogleFonts.firaSansTextTheme),
    _FontEntry('ibmPlexSans', GoogleFonts.ibmPlexSansTextTheme),
    _FontEntry('inter', GoogleFonts.interTextTheme),
    _FontEntry('josefinSans', GoogleFonts.josefinSansTextTheme),
    _FontEntry('kanit', GoogleFonts.kanitTextTheme),
    _FontEntry('lato', GoogleFonts.latoTextTheme),
    _FontEntry('lexend', GoogleFonts.lexendTextTheme),
    _FontEntry('manrope', GoogleFonts.manropeTextTheme),
    _FontEntry('montserrat', GoogleFonts.montserratTextTheme),
    _FontEntry('notoSans', GoogleFonts.notoSansTextTheme),
    _FontEntry('nunito', GoogleFonts.nunitoTextTheme),
    _FontEntry('openSans', GoogleFonts.openSansTextTheme),
    _FontEntry('oswald', GoogleFonts.oswaldTextTheme),
    _FontEntry('outfit', GoogleFonts.outfitTextTheme),
    _FontEntry('playfairDisplay', GoogleFonts.playfairDisplayTextTheme),
    _FontEntry('poppins', GoogleFonts.poppinsTextTheme),
    _FontEntry('ptSans', GoogleFonts.ptSansTextTheme),
    _FontEntry('quicksand', GoogleFonts.quicksandTextTheme),
    _FontEntry('raleway', GoogleFonts.ralewayTextTheme),
    _FontEntry('roboto', GoogleFonts.robotoTextTheme),
    _FontEntry('rubik', GoogleFonts.rubikTextTheme),
    _FontEntry('sourceSans3', GoogleFonts.sourceSans3TextTheme),
    _FontEntry('spaceGrotesk', GoogleFonts.spaceGroteskTextTheme),
    _FontEntry('workSans', GoogleFonts.workSansTextTheme),
  ];

  static final Map<String, _FontEntry> _byId = {
    for (final entry in _catalog) entry.id: entry,
  };

  /// Persisted font ids shown in settings.
  static List<String> get choices => _catalog.map((entry) => entry.id).toList();

  /// Normalizes unknown stored values to [defaultId].
  static String resolve(String? id) =>
      SettingsCatalog.resolve(id, choices, defaultId);

  /// Localized label for settings UI.
  static String label(String id) =>
      SettingsCatalog.label(id, choices, defaultId, _labelPrefix);

  /// Applies the selected font to [baseTheme].
  static TextTheme textTheme(String? id, TextTheme baseTheme) =>
      _byId[resolve(id)]!.textTheme(baseTheme);

  /// Platform system font from the engine, with OS-specific fallbacks.
  @visibleForTesting
  static String platformFontFamily({String? engineFamily}) {
    final resolved = engineFamily ?? _engineSystemFontFamily;
    if (resolved != null && resolved.isNotEmpty) return resolved;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'sans-serif',
      TargetPlatform.iOS => '.AppleSystemUIFont',
      TargetPlatform.macOS => '.AppleSystemUIFont',
      TargetPlatform.windows => 'Segoe UI',
      TargetPlatform.linux => 'Roboto',
      _ => 'Roboto',
    };
  }

  /// Engine-reported system font family, when available.
  static String? get _engineSystemFontFamily =>
      WidgetsBinding.instance.platformDispatcher.systemFontFamily;

  /// Applies the platform font family to [base].
  static TextTheme _systemTextTheme(TextTheme base) =>
      base.apply(fontFamily: platformFontFamily());
}
