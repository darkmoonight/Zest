import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/calendar_format_helper.dart';

void main() {
  group('calendarFormatFromString / calendarFormatToString', () {
    test('week round-trip', () {
      const stored = AppConstants.defaultCalendarFormat;
      expect(
        CalendarFormatHelper.calendarFormatToString(
          CalendarFormatHelper.calendarFormatFromString(stored),
        ),
        stored,
      );
    });

    test('two weeks round-trip', () {
      const stored = AppConstants.calendarFormatTwoWeeks;
      expect(
        CalendarFormatHelper.calendarFormatToString(
          CalendarFormatHelper.calendarFormatFromString(stored),
        ),
        stored,
      );
    });

    test('month round-trip', () {
      const stored = AppConstants.calendarFormatMonth;
      expect(
        CalendarFormatHelper.calendarFormatToString(
          CalendarFormatHelper.calendarFormatFromString(stored),
        ),
        stored,
      );
    });

    test('unknown value defaults to week', () {
      expect(
        CalendarFormatHelper.calendarFormatFromString('unknown'),
        CalendarFormat.week,
      );
    });
  });

  group('startingDayOfWeekFromString', () {
    test('maps monday', () {
      expect(
        CalendarFormatHelper.startingDayOfWeekFromString(
          AppConstants.defaultFirstDay,
        ),
        StartingDayOfWeek.monday,
      );
    });

    test('maps sunday', () {
      expect(
        CalendarFormatHelper.startingDayOfWeekFromString('sunday'),
        StartingDayOfWeek.sunday,
      );
    });

    test('unknown defaults to monday', () {
      expect(
        CalendarFormatHelper.startingDayOfWeekFromString('invalid'),
        StartingDayOfWeek.monday,
      );
    });
  });
}
