import 'package:flutter/material.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/i18n/locale_utils.dart';
import 'package:zest/i18n/strings.g.dart';

/// In-memory snapshot of user-facing app settings for UI and services.
class AppSettingsState {
  /// Creates a settings snapshot with optional defaults from [AppConstants].
  const AppSettingsState({
    this.amoledTheme = false,
    this.materialColor = false,
    this.isImage = AppConstants.defaultIsImage,
    this.colorPalette = AppConstants.defaultColorPalette,
    this.appFont = AppConstants.defaultAppFont,
    this.timeformat = AppConstants.defaultTimeformat,
    this.firstDay = AppConstants.defaultFirstDay,
    this.locale = AppConstants.defaultLocale,
  });

  /// Whether AMOLED (pure black) theme is enabled.
  final bool amoledTheme;

  /// Whether Material You dynamic color is enabled.
  final bool materialColor;

  /// Whether the home background uses an image.
  final bool isImage;

  /// Accent palette id from [AppColorPalette].
  final String colorPalette;

  /// App font id from [AppFont].
  final String appFont;

  /// User-preferred time format string.
  final String timeformat;

  /// First day of the week setting key.
  final String firstDay;

  /// Active UI locale.
  final Locale locale;

  /// Returns a copy with selectively overridden fields.
  AppSettingsState copyWith({
    bool? amoledTheme,
    bool? materialColor,
    bool? isImage,
    String? colorPalette,
    String? appFont,
    String? timeformat,
    String? firstDay,
    Locale? locale,
  }) => AppSettingsState(
    amoledTheme: amoledTheme ?? this.amoledTheme,
    materialColor: materialColor ?? this.materialColor,
    isImage: isImage ?? this.isImage,
    colorPalette: colorPalette ?? this.colorPalette,
    appFont: appFont ?? this.appFont,
    timeformat: timeformat ?? this.timeformat,
    firstDay: firstDay ?? this.firstDay,
    locale: locale ?? this.locale,
  );

  /// Maps persisted [Settings] into an [AppSettingsState] snapshot.
  factory AppSettingsState.fromSettings(Settings settings) {
    final locale = appLocaleFromLanguageCode(settings.language).flutterLocale;
    return AppSettingsState(
      amoledTheme: settings.amoledTheme,
      materialColor: settings.materialColor,
      isImage: settings.isImage ?? AppConstants.defaultIsImage,
      colorPalette: settings.colorPalette,
      appFont: settings.appFont,
      timeformat: settings.timeformat,
      firstDay: settings.firstDay,
      locale: locale,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppSettingsState &&
        amoledTheme == other.amoledTheme &&
        materialColor == other.materialColor &&
        isImage == other.isImage &&
        colorPalette == other.colorPalette &&
        appFont == other.appFont &&
        timeformat == other.timeformat &&
        firstDay == other.firstDay &&
        locale == other.locale;
  }

  @override
  int get hashCode => Object.hash(
    amoledTheme,
    materialColor,
    isImage,
    colorPalette,
    appFont,
    timeformat,
    firstDay,
    locale,
  );
}
