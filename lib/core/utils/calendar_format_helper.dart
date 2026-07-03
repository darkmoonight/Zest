import 'package:table_calendar/table_calendar.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Maps persisted calendar settings strings to [table_calendar] enums.
class CalendarFormatHelper {
  /// Private constructor; use static methods only.
  CalendarFormatHelper._();

  /// Converts a stored calendar format string to [CalendarFormat].
  static CalendarFormat calendarFormatFromString(String value) {
    switch (value) {
      case AppConstants.calendarFormatTwoWeeks:
        return CalendarFormat.twoWeeks;
      case AppConstants.calendarFormatMonth:
        return CalendarFormat.month;
      case AppConstants.defaultCalendarFormat:
      default:
        return CalendarFormat.week;
    }
  }

  /// Converts [CalendarFormat] to the persisted string value.
  static String calendarFormatToString(CalendarFormat format) {
    switch (format) {
      case CalendarFormat.twoWeeks:
        return AppConstants.calendarFormatTwoWeeks;
      case CalendarFormat.month:
        return AppConstants.calendarFormatMonth;
      case CalendarFormat.week:
        return AppConstants.defaultCalendarFormat;
    }
  }

  /// Converts a stored weekday key to [StartingDayOfWeek].
  static StartingDayOfWeek startingDayOfWeekFromString(String value) {
    switch (value) {
      case 'tuesday':
        return StartingDayOfWeek.tuesday;
      case 'wednesday':
        return StartingDayOfWeek.wednesday;
      case 'thursday':
        return StartingDayOfWeek.thursday;
      case 'friday':
        return StartingDayOfWeek.friday;
      case 'saturday':
        return StartingDayOfWeek.saturday;
      case 'sunday':
        return StartingDayOfWeek.sunday;
      case AppConstants.defaultFirstDay:
      default:
        return StartingDayOfWeek.monday;
    }
  }
}
