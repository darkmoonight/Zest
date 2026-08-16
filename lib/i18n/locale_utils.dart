import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/i18n/locale_format_helper.dart';
import 'package:zest/i18n/strings.g.dart';

/// Parses a stored language code (e.g. `en_US`) into an [AppLocale].
AppLocale appLocaleFromLanguageCode(String? language) {
  if (language == null || language.isEmpty) return AppLocale.enUs;
  return AppLocaleUtils.parse(language.replaceAll('_', '-'));
}

/// Primary language subtag from a stored settings value (`en_US` → `en`).
String languageCodeFromSettings(String? language) {
  if (language == null || language.isEmpty) {
    return AppConstants.defaultLanguageCode;
  }
  final sep = language.indexOf('_');
  if (sep <= 0) {
    final dash = language.indexOf('-');
    if (dash <= 0) return language;
    return language.substring(0, dash);
  }
  return language.substring(0, sep);
}

/// Converts a Flutter [Locale] into the closest supported [AppLocale].
AppLocale appLocaleFromFlutterLocale(Locale locale) {
  final country = locale.countryCode;
  if (country != null && country.isNotEmpty) {
    return AppLocaleUtils.parse('${locale.languageCode}-$country');
  }
  return AppLocaleUtils.parse(locale.languageCode);
}

/// Serializes [locale] to `language_COUNTRY`, or language code alone when no country is set.
String languageCodeFromAppLocale(AppLocale locale) {
  final c = locale.countryCode;
  if (c == null || c.isEmpty) return locale.languageCode;
  return '${locale.languageCode}_${c.toUpperCase()}';
}

/// Applies slang locale and loads intl date symbols.
///
/// Background isolates have no [MaterialApp] localizations; [onFormattingError]
/// is called before falling back to English date symbols.
Future<void> applyAppLocale(
  AppLocale appLocale, {
  void Function(Object error, StackTrace stackTrace)? onFormattingError,
}) async {
  await LocaleSettings.setLocale(appLocale);
  final languageCode = appLocale.flutterLocale.languageCode;
  try {
    await LocaleFormatHelper.ensureDateFormatting(languageCode);
  } catch (e, st) {
    onFormattingError?.call(e, st);
    await LocaleFormatHelper.ensureDateFormatting(
      AppConstants.defaultLanguageCode,
    );
  }
}
