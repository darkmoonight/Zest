import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Formats and parses item due dates using the user's 12/24-hour preference.
class DateTimeFormatHelper {
  /// Private constructor; use static methods only.
  DateTimeFormatHelper._();

  /// Whether [timeformat] selects 12-hour clock display.
  static bool is12HourFormat(String timeformat) =>
      timeformat == AppConstants.timeformat12;

  /// Returns the [DateFormat] for full date-time display in [languageCode].
  static DateFormat appDateTimeFormat(String timeformat, String languageCode) {
    if (is12HourFormat(timeformat)) {
      return DateFormat.yMMMEd(languageCode).add_jm();
    }
    return DateFormat.yMMMEd(languageCode).add_Hm();
  }

  /// Formats [dateTime] with date and time per user preferences.
  static String formatDateTime(
    DateTime dateTime, {
    required String timeformat,
    required String languageCode,
  }) => appDateTimeFormat(timeformat, languageCode).format(dateTime);

  /// Parses a formatted date-time string; returns null on empty input or failure.
  static DateTime? parseDateTime(
    String timeString, {
    required String timeformat,
    required String languageCode,
  }) {
    if (timeString.isEmpty) return null;

    try {
      return appDateTimeFormat(timeformat, languageCode).parse(timeString);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  /// Formats [dateTime] as time only (hour and minute).
  static String formatTime(
    DateTime dateTime, {
    required String timeformat,
    required String languageCode,
  }) {
    if (is12HourFormat(timeformat)) {
      return DateFormat.jm(languageCode).format(dateTime);
    }
    return DateFormat.Hm(languageCode).format(dateTime);
  }
}
