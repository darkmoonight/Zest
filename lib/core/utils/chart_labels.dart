import 'package:zest/i18n/tr.dart';

/// Localized labels for statistics charts.
class ChartLabels {
  ChartLabels._();

  /// Short weekday labels indexed Monday (0) through Sunday (6).
  static List<String> weekdayShort() => [
    'dayMon'.tr,
    'dayTue'.tr,
    'dayWed'.tr,
    'dayThu'.tr,
    'dayFri'.tr,
    'daySat'.tr,
    'daySun'.tr,
  ];

  /// Time-of-day period names for hourly chart tooltips.
  static List<String> timePeriods() => [
    'timePeriodNight'.tr,
    'timePeriodMorning'.tr,
    'timePeriodAfternoon'.tr,
    'timePeriodEvening'.tr,
  ];

  /// 12-hour axis labels for hourly chart.
  static List<String> hourlyRanges12h() => [
    'timeRange12to6Am'.tr,
    'timeRange6to12Am'.tr,
    'timeRange12to6Pm'.tr,
    'timeRange6to12Pm'.tr,
  ];

  /// 24-hour axis labels for hourly chart.
  static List<String> hourlyRanges24h() => [
    'timeRange0to6'.tr,
    'timeRange6to12'.tr,
    'timeRange12to18'.tr,
    'timeRange18to24'.tr,
  ];
}
