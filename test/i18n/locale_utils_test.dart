import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zest/i18n/locale_utils.dart';
import 'package:zest/i18n/strings.g.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.enUs);
  });

  group('appLocaleFromLanguageCode', () {
    test('returns enUs for null or empty input', () {
      expect(appLocaleFromLanguageCode(null), AppLocale.enUs);
      expect(appLocaleFromLanguageCode(''), AppLocale.enUs);
    });

    test('parses stored language codes', () {
      expect(appLocaleFromLanguageCode('ru_RU'), AppLocale.ruRu);
      expect(appLocaleFromLanguageCode('de_DE'), AppLocale.deDe);
    });
  });

  group('appLocaleFromFlutterLocale', () {
    test('parses locale with country code', () {
      expect(
        appLocaleFromFlutterLocale(const Locale('fr', 'FR')),
        AppLocale.frFr,
      );
    });

    test('parses language-only locale', () {
      expect(appLocaleFromFlutterLocale(const Locale('ja')), AppLocale.jaJp);
    });
  });

  group('languageCodeFromAppLocale', () {
    test('serializes locale with country', () {
      expect(languageCodeFromAppLocale(AppLocale.enUs), 'en_US');
    });
  });

  group('applyAppLocale', () {
    test('loads date symbols for locale', () async {
      await applyAppLocale(AppLocale.enUs);

      expect(LocaleSettings.currentLocale, AppLocale.enUs);
    });

    test('falls back to English when formatting fails', () async {
      Object? capturedError;

      await applyAppLocale(
        AppLocale.enUs,
        onFormattingError: (error, _) => capturedError = error,
      );

      expect(capturedError, isNull);
    });
  });
}
