import 'package:flutter/material.dart';

/// Shared layout, timing, and persisted-settings defaults for the app.
class AppConstants {
  // Animation
  /// Default animation duration for UI transitions.
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// Short animation duration for micro-interactions.
  static const Duration shortAnimation = Duration(milliseconds: 150);

  /// Long animation duration for card and list transitions.
  static const Duration longAnimation = Duration(milliseconds: 250);

  /// Card tap scale animation duration.
  static const Duration cardTapAnimation = Duration(milliseconds: 240);

  // Size
  /// Small border radius for chips and compact controls.
  static const double borderRadiusSmall = 8.0;

  /// Medium border radius for cards and dialogs.
  static const double borderRadiusMedium = 12.0;

  /// Large border radius for prominent surfaces.
  static const double borderRadiusLarge = 16.0;

  /// Extra-large border radius for hero elements.
  static const double borderRadiusXLarge = 20.0;

  /// Maximum border radius for pill-shaped containers.
  static const double borderRadiusXXLarge = 24.0;

  // Elevation
  /// Low elevation for subtle separation.
  static const double elevationLow = 1.0;

  /// Medium elevation for floating elements.
  static const double elevationMedium = 6.0;

  /// High elevation for modals and overlays.
  static const double elevationHigh = 8.0;

  // Spacing
  /// Extra-small spacing (4dp).
  static const double spacingXS = 4.0;

  /// Small spacing (8dp).
  static const double spacingS = 8.0;

  /// Medium spacing (12dp).
  static const double spacingM = 12.0;

  /// Large spacing (16dp).
  static const double spacingL = 16.0;

  /// Extra-large spacing (20dp).
  static const double spacingXL = 20.0;

  /// Double extra-large spacing (24dp).
  static const double spacingXXL = 24.0;

  // Icon sizes
  /// Small icon size.
  static const double iconSizeSmall = 18.0;

  /// Medium icon size.
  static const double iconSizeMedium = 20.0;

  /// Large icon size.
  static const double iconSizeLarge = 24.0;

  /// Extra-large icon size.
  static const double iconSizeXLarge = 32.0;

  // Constraints
  /// Maximum width for dialogs on wide screens.
  static const double maxDialogWidth = 400.0;

  /// Maximum content width on desktop layouts.
  static const double maxDesktopWidth = 1200.0;

  /// Maximum width for modal bottom sheets.
  static const double maxModalWidth = 500.0;

  // Opacity
  /// Light opacity overlay.
  static const double opacityLight = 0.3;

  /// Medium opacity overlay.
  static const double opacityMedium = 0.5;

  /// Heavy opacity overlay.
  static const double opacityHeavy = 0.8;

  // Border width
  /// Thin border width.
  static const double borderWidthThin = 1.0;

  /// Medium border width.
  static const double borderWidthMedium = 1.5;

  /// Thick border width.
  static const double borderWidthThick = 2.0;

  // Debounce
  /// Default debounce delay for scroll and input handlers.
  static const debounceDelay = Duration(milliseconds: 150);

  // Settings defaults
  /// Default clock display format (24-hour).
  static const String defaultTimeformat = '24';

  /// 12-hour clock format identifier.
  static const String timeformat12 = '12';

  /// Available time format picker values.
  static const List<String> timeformatChoices = ['12', '24'];

  /// Default first day of the week.
  static const String defaultFirstDay = 'monday';

  /// Weekday keys for the first-day-of-week picker.
  static const List<String> weekDayChoices = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  /// Default theme mode string stored in Isar.
  static const String defaultTheme = 'system';

  /// Available theme mode picker values.
  static const List<String> themeChoices = ['system', 'dark', 'light'];

  /// Default calendar view format.
  static const String defaultCalendarFormat = 'week';

  /// Two-week calendar format identifier.
  static const String calendarFormatTwoWeeks = 'twoWeeks';

  /// Month calendar format identifier.
  static const String calendarFormatMonth = 'month';

  /// Available calendar format picker values.
  static const List<String> calendarFormatChoices = [
    defaultCalendarFormat,
    calendarFormatTwoWeeks,
    calendarFormatMonth,
  ];

  /// Default home tab on first launch.
  static const String defaultScreen = 'categories';

  /// Default notification snooze duration in minutes.
  static const int defaultSnoozeDuration = 10;

  /// Snooze duration picker values in minutes.
  static const List<int> snoozeDurationChoices = [5, 10, 15, 20, 30, 45, 60];

  /// Max auto-backup count picker values.
  static const List<int> maxAutoBackupChoices = [3, 5, 7, 10, 15, 20, 30];

  /// Default fallback locale when none is stored.
  static const Locale defaultLocale = Locale('en', 'US');

  /// Default language code for date formatting and services.
  static const String defaultLanguageCode = 'en';

  /// Default value for showing illustration images in empty states.
  static const bool defaultIsImage = false;

  /// Default max number of retained auto-backup files.
  static const int defaultMaxAutoBackups = 5;

  // Metadata chips (todo/task cards)
  /// Horizontal padding for metadata chips on cards.
  static const double chipPaddingH = 7.0;

  /// Vertical padding for metadata chips on cards.
  static const double chipPaddingV = 3.0;

  /// Border radius for metadata chips on cards.
  static const double chipBorderRadius = 7.0;

  // Assets
  /// Empty-state illustration for task/todo lists.
  static const String emptyStateTaskImage = 'assets/images/Task.png';

  // Notifications
  /// Android notification channel id for todo reminders.
  static const String notificationChannelId = 'Zest';

  /// Slang key for the Android notification channel display name.
  static const String notificationChannelNameKey = 'notificationChannelName';
}
