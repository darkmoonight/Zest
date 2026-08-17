import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/utils/calendar_date.dart';

void main() {
  group('CalendarDate.daysBetween', () {
    test('counts whole calendar days, not 24-hour periods', () {
      expect(
        CalendarDate.daysBetween(
          DateTime(2026, 6, 1, 23),
          DateTime(2026, 6, 2, 1),
        ),
        1,
      );
    });

    test('uses UTC date components so DST cannot zero a day', () {
      expect(
        CalendarDate.daysBetween(DateTime(2026, 3, 8), DateTime(2026, 3, 9)),
        1,
      );
    });
  });

  group('CalendarDate.addDays', () {
    test('shifts calendar dates and optionally keeps the clock', () {
      expect(
        CalendarDate.addDays(DateTime(2026, 1, 31, 9, 30), 1),
        DateTime(2026, 2, 1),
      );
      expect(
        CalendarDate.addDays(DateTime(2026, 1, 31, 9, 30), 1, keepTime: true),
        DateTime(2026, 2, 1, 9, 30),
      );
    });
  });
}
