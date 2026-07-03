import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/i18n/locale_format_helper.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';

void main() {
  setUpAll(() async {
    await LocaleFormatHelper.ensureDateFormatting(
      AppConstants.defaultLanguageCode,
    );
  });
  group('is12HourFormat', () {
    test('returns true for 12-hour format', () {
      expect(
        DateTimeFormatHelper.is12HourFormat(AppConstants.timeformat12),
        isTrue,
      );
    });

    test('returns false for 24-hour format', () {
      expect(
        DateTimeFormatHelper.is12HourFormat(AppConstants.defaultTimeformat),
        isFalse,
      );
    });
  });

  group('formatDateTime / parseDateTime round-trip', () {
    final sample = DateTime(2026, 6, 23, 14, 30);

    test('24-hour format', () {
      final formatted = DateTimeFormatHelper.formatDateTime(
        sample,
        timeformat: AppConstants.defaultTimeformat,
        languageCode: AppConstants.defaultLanguageCode,
      );
      final parsed = DateTimeFormatHelper.parseDateTime(
        formatted,
        timeformat: AppConstants.defaultTimeformat,
        languageCode: AppConstants.defaultLanguageCode,
      );
      expect(parsed, isNotNull);
      expect(parsed!.year, sample.year);
      expect(parsed.month, sample.month);
      expect(parsed.day, sample.day);
      expect(parsed.hour, sample.hour);
      expect(parsed.minute, sample.minute);
    });

    test('12-hour format', () {
      final formatted = DateTimeFormatHelper.formatDateTime(
        sample,
        timeformat: AppConstants.timeformat12,
        languageCode: AppConstants.defaultLanguageCode,
      );
      final parsed = DateTimeFormatHelper.parseDateTime(
        formatted,
        timeformat: AppConstants.timeformat12,
        languageCode: AppConstants.defaultLanguageCode,
      );
      expect(parsed, isNotNull);
      expect(parsed!.hour, sample.hour);
      expect(parsed.minute, sample.minute);
    });
  });

  group('formatTime', () {
    test('formats time only in 24-hour mode', () {
      final result = DateTimeFormatHelper.formatTime(
        DateTime(2026, 1, 1, 9, 5),
        timeformat: AppConstants.defaultTimeformat,
        languageCode: AppConstants.defaultLanguageCode,
      );
      expect(result, contains('9'));
      expect(result, contains('05'));
    });
  });

  test('parseDateTime returns null for empty string', () {
    expect(
      DateTimeFormatHelper.parseDateTime(
        '',
        timeformat: AppConstants.defaultTimeformat,
        languageCode: AppConstants.defaultLanguageCode,
      ),
      isNull,
    );
  });
}
