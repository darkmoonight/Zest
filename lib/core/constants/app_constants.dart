import 'package:material_ui/material_ui.dart';

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

  /// Snackbar display duration before auto-dismiss.
  static const Duration snackbarDisplayDuration = Duration(milliseconds: 2500);

  // Size
  /// Small border radius for chips and compact controls.
  static const double borderRadiusSmall = 8.0;

  /// Compact border radius for counters and inline chips (between small and medium).
  static const double borderRadiusCompact = 10.0;

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

  /// Inline icon size on metadata chips and compact labels.
  static const double iconSizeInline = 11.0;

  /// App bar action icon size.
  static const double iconSizeAppBarAction = 22.0;

  /// Square icon container size in modals and statistics.
  static const double iconBoxSize = 44.0;

  // Constraints
  /// Maximum width for dialogs on wide screens.
  static const double maxDialogWidth = 400.0;

  /// Maximum content width on desktop layouts.
  static const double maxDesktopWidth = 1200.0;

  /// Maximum width for modal bottom sheets.
  static const double maxModalWidth = 500.0;

  /// Modal sheet height fraction on mobile (large forms).
  static const double modalHeightFractionLargeMobile = 0.95;

  /// Modal sheet height fraction on desktop (large forms).
  static const double modalHeightFractionLargeDesktop = 0.85;

  /// Modal sheet height fraction on desktop (item action sheet).
  static const double modalHeightFractionLargeDesktopWide = 0.90;

  /// Modal sheet height fraction on mobile (transfer sheet).
  static const double modalHeightFractionMediumMobile = 0.70;

  /// Modal sheet height fraction on desktop (transfer sheet).
  static const double modalHeightFractionMediumDesktop = 0.65;

  // Opacity
  /// Light opacity overlay.
  static const double opacityLight = 0.3;

  /// Medium opacity overlay.
  static const double opacityMedium = 0.5;

  /// Background alpha for tinted chips and badges.
  static const double chipBackgroundAlpha = 0.15;

  /// Border alpha for tinted chips and badges.
  static const double chipBorderAlpha = 0.3;

  /// Scale factor when a card is pressed.
  static const double cardTapScale = 0.97;

  // Border width
  /// Thin border width.
  static const double borderWidthThin = 1.0;

  /// Thick border width.
  static const double borderWidthThick = 2.0;

  /// Bottom list padding so content clears the floating action button.
  static const double listFabClearanceHeight = 80.0;

  /// Delay before restarting the app after a successful restore.
  static const Duration restoreRestartDelay = Duration(milliseconds: 1500);

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
  static const String themeSystem = 'system';

  /// Theme mode key: dark.
  static const String themeDark = 'dark';

  /// Theme mode key: light.
  static const String themeLight = 'light';

  /// Default theme mode string stored in Isar.
  static const String defaultTheme = themeSystem;

  /// Available theme mode picker values.
  static const List<String> themeChoices = [themeSystem, themeDark, themeLight];

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

  /// Android application id (`applicationId` / package name).
  static const String androidPackageName = 'com.yoshi.todark';

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

  /// Default accent palette id ([AppColorPalette.defaultId]).
  static const String defaultColorPalette = 'indigo';

  /// Default app font id ([AppFont.defaultId]).
  static const String defaultAppFont = 'ubuntu';

  /// Current [Settings] Isar layout version (Rain-style rewrite migration).
  static const int settingsSchemaVersion = 4;

  /// How far ahead calendar / due-date pickers allow selecting dates.
  static const Duration calendarSelectableRange = Duration(days: 1000);

  /// Android small-icon resource name for local notifications.
  static const String androidNotificationIcon = 'ic_notification';

  // Metadata chips (item/task cards)
  /// Horizontal padding for metadata chips on cards.
  static const double chipPaddingH = 7.0;

  /// Vertical padding for metadata chips on cards.
  static const double chipPaddingV = 3.0;

  /// Border radius for metadata chips on cards.
  static const double chipBorderRadius = 7.0;

  // Assets
  /// Empty-state illustration for task/item lists.
  static const String emptyStateTaskImage = 'assets/images/Task.png';

  /// Empty-state illustration for category lists.
  static const String emptyStateCategoryImage = 'assets/images/Category.png';

  /// Empty-state illustration for item lists.
  static const String emptyStateTodoImage = 'assets/images/Todo.png';

  /// Empty-state illustration for calendar item lists.
  static const String emptyStateCalendarImage = 'assets/images/Calendar.png';

  /// Extra top padding for empty list states on mobile.
  static const double emptyStateTopOffsetMobile = 60.0;

  /// Extra top padding for empty list states on tablet/desktop.
  static const double emptyStateTopOffsetWide = 70.0;

  /// Circular progress diameter on mobile task cards.
  static const double circularProgressSizeMobile = 54.0;

  /// Circular progress diameter on tablet task cards.
  static const double circularProgressSizeTablet = 62.0;

  /// Circular progress diameter on desktop task cards.
  static const double circularProgressSizeDesktop = 70.0;

  /// Default color for newly created tasks.
  static const Color defaultTaskColor = Color(0xFF2196F3);
}
