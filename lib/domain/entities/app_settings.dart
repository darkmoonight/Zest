import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/domain/enums/enums.dart';

/// Domain model mirroring persisted app preferences.
class AppSettings {
  const AppSettings({
    this.id,
    this.onboard = false,
    this.theme = AppConstants.defaultTheme,
    this.timeformat = AppConstants.defaultTimeformat,
    this.materialColor = true,
    this.amoledTheme = false,
    this.colorPalette = AppConstants.defaultColorPalette,
    this.appFont = AppConstants.defaultAppFont,
    this.isImage = AppConstants.defaultIsImage,
    this.screenPrivacy = false,
    this.language,
    this.firstDay = AppConstants.defaultFirstDay,
    this.calendarFormat = AppConstants.defaultCalendarFormat,
    this.defaultScreen = AppConstants.defaultScreen,
    this.snoozeDuration = AppConstants.defaultSnoozeDuration,
    this.allTodosSortOption = SortOption.none,
    this.showArchivedInAllTodos = false,
    this.showArchivedInCalendar = false,
    this.showArchivedInStatistics = false,
    this.calendarSortOption = SortOption.none,
    this.autoBackupEnabled = false,
    this.autoBackupFrequency = AutoBackupFrequency.daily,
    this.lastAutoBackupTime,
    this.maxAutoBackups = AppConstants.defaultMaxAutoBackups,
    this.autoBackupPath,
    this.notificationChannelsMigrated = false,
    this.defaultCategorySeeded = false,
    this.defaultCategoryId,
    this.deviceCalendarSyncEnabled = false,
    this.deviceCalendarId,
    this.autoEraseCompletedEnabled = false,
    this.autoEraseCompletedFrequency = AutoEraseCompletedFrequency.weekly,
    this.lastAutoEraseCompletedTime,
    this.caldavEnabled = false,
    this.caldavUrl,
    this.caldavUsername,
    this.caldavCalendarHref,
    this.caldavCalendarName,
    this.caldavCtag,
    this.caldavAllowInsecure = false,
    this.caldavLastSyncTime,
    this.caldavLastError,
    this.caldavPendingDeletes = '[]',
    this.todoCardLayout = '',
    this.settingsSchemaVersion = 0,
  });

  final int? id;
  final bool onboard;
  final String? theme;
  final String timeformat;
  final bool materialColor;
  final bool amoledTheme;
  final String colorPalette;
  final String appFont;
  final bool? isImage;
  final bool? screenPrivacy;
  final String? language;
  final String firstDay;
  final String calendarFormat;
  final String defaultScreen;
  final int snoozeDuration;
  final SortOption allTodosSortOption;
  final bool showArchivedInAllTodos;
  final bool showArchivedInCalendar;
  final bool showArchivedInStatistics;
  final SortOption calendarSortOption;
  final bool autoBackupEnabled;
  final AutoBackupFrequency autoBackupFrequency;
  final DateTime? lastAutoBackupTime;
  final int maxAutoBackups;
  final String? autoBackupPath;
  final bool notificationChannelsMigrated;
  final bool defaultCategorySeeded;
  final int? defaultCategoryId;
  final bool deviceCalendarSyncEnabled;
  final String? deviceCalendarId;
  final bool autoEraseCompletedEnabled;
  final AutoEraseCompletedFrequency autoEraseCompletedFrequency;
  final DateTime? lastAutoEraseCompletedTime;
  final bool caldavEnabled;
  final String? caldavUrl;
  final String? caldavUsername;
  final String? caldavCalendarHref;
  final String? caldavCalendarName;
  final String? caldavCtag;
  final bool caldavAllowInsecure;
  final DateTime? caldavLastSyncTime;
  final String? caldavLastError;
  final String caldavPendingDeletes;
  final String todoCardLayout;
  final int settingsSchemaVersion;

  AppSettings copyWith({
    int? id,
    bool? onboard,
    String? theme,
    String? timeformat,
    bool? materialColor,
    bool? amoledTheme,
    String? colorPalette,
    String? appFont,
    bool? isImage,
    bool? screenPrivacy,
    String? language,
    String? firstDay,
    String? calendarFormat,
    String? defaultScreen,
    int? snoozeDuration,
    SortOption? allTodosSortOption,
    bool? showArchivedInAllTodos,
    bool? showArchivedInCalendar,
    bool? showArchivedInStatistics,
    SortOption? calendarSortOption,
    bool? autoBackupEnabled,
    AutoBackupFrequency? autoBackupFrequency,
    DateTime? lastAutoBackupTime,
    int? maxAutoBackups,
    String? autoBackupPath,
    bool? notificationChannelsMigrated,
    bool? defaultCategorySeeded,
    int? defaultCategoryId,
    bool? deviceCalendarSyncEnabled,
    String? deviceCalendarId,
    bool? autoEraseCompletedEnabled,
    AutoEraseCompletedFrequency? autoEraseCompletedFrequency,
    DateTime? lastAutoEraseCompletedTime,
    bool? caldavEnabled,
    String? caldavUrl,
    String? caldavUsername,
    String? caldavCalendarHref,
    String? caldavCalendarName,
    String? caldavCtag,
    bool? caldavAllowInsecure,
    DateTime? caldavLastSyncTime,
    String? caldavLastError,
    bool clearCaldavLastError = false,
    String? caldavPendingDeletes,
    String? todoCardLayout,
    int? settingsSchemaVersion,
  }) {
    return AppSettings(
      id: id ?? this.id,
      onboard: onboard ?? this.onboard,
      theme: theme ?? this.theme,
      timeformat: timeformat ?? this.timeformat,
      materialColor: materialColor ?? this.materialColor,
      amoledTheme: amoledTheme ?? this.amoledTheme,
      colorPalette: colorPalette ?? this.colorPalette,
      appFont: appFont ?? this.appFont,
      isImage: isImage ?? this.isImage,
      screenPrivacy: screenPrivacy ?? this.screenPrivacy,
      language: language ?? this.language,
      firstDay: firstDay ?? this.firstDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      defaultScreen: defaultScreen ?? this.defaultScreen,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      allTodosSortOption: allTodosSortOption ?? this.allTodosSortOption,
      showArchivedInAllTodos:
          showArchivedInAllTodos ?? this.showArchivedInAllTodos,
      showArchivedInCalendar:
          showArchivedInCalendar ?? this.showArchivedInCalendar,
      showArchivedInStatistics:
          showArchivedInStatistics ?? this.showArchivedInStatistics,
      calendarSortOption: calendarSortOption ?? this.calendarSortOption,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupFrequency: autoBackupFrequency ?? this.autoBackupFrequency,
      lastAutoBackupTime: lastAutoBackupTime ?? this.lastAutoBackupTime,
      maxAutoBackups: maxAutoBackups ?? this.maxAutoBackups,
      autoBackupPath: autoBackupPath ?? this.autoBackupPath,
      notificationChannelsMigrated:
          notificationChannelsMigrated ?? this.notificationChannelsMigrated,
      defaultCategorySeeded:
          defaultCategorySeeded ?? this.defaultCategorySeeded,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      deviceCalendarSyncEnabled:
          deviceCalendarSyncEnabled ?? this.deviceCalendarSyncEnabled,
      deviceCalendarId: deviceCalendarId ?? this.deviceCalendarId,
      autoEraseCompletedEnabled:
          autoEraseCompletedEnabled ?? this.autoEraseCompletedEnabled,
      autoEraseCompletedFrequency:
          autoEraseCompletedFrequency ?? this.autoEraseCompletedFrequency,
      lastAutoEraseCompletedTime:
          lastAutoEraseCompletedTime ?? this.lastAutoEraseCompletedTime,
      caldavEnabled: caldavEnabled ?? this.caldavEnabled,
      caldavUrl: caldavUrl ?? this.caldavUrl,
      caldavUsername: caldavUsername ?? this.caldavUsername,
      caldavCalendarHref: caldavCalendarHref ?? this.caldavCalendarHref,
      caldavCalendarName: caldavCalendarName ?? this.caldavCalendarName,
      caldavCtag: caldavCtag ?? this.caldavCtag,
      caldavAllowInsecure: caldavAllowInsecure ?? this.caldavAllowInsecure,
      caldavLastSyncTime: caldavLastSyncTime ?? this.caldavLastSyncTime,
      caldavLastError: clearCaldavLastError
          ? null
          : (caldavLastError ?? this.caldavLastError),
      caldavPendingDeletes: caldavPendingDeletes ?? this.caldavPendingDeletes,
      todoCardLayout: todoCardLayout ?? this.todoCardLayout,
      settingsSchemaVersion:
          settingsSchemaVersion ?? this.settingsSchemaVersion,
    );
  }

  /// Returns a new [AppSettings] with preference fields from [other].
  ///
  /// When [includeId] is false (default), the result keeps this [id].
  AppSettings copyValuesFrom(AppSettings other, {bool includeId = false}) {
    return copyWith(
      id: includeId ? other.id : id,
      onboard: other.onboard,
      theme: other.theme,
      timeformat: other.timeformat,
      materialColor: other.materialColor,
      amoledTheme: other.amoledTheme,
      colorPalette: other.colorPalette,
      appFont: other.appFont,
      isImage: other.isImage,
      screenPrivacy: other.screenPrivacy,
      language: other.language,
      firstDay: other.firstDay,
      calendarFormat: other.calendarFormat,
      defaultScreen: other.defaultScreen,
      snoozeDuration: other.snoozeDuration,
      allTodosSortOption: other.allTodosSortOption,
      showArchivedInAllTodos: other.showArchivedInAllTodos,
      showArchivedInCalendar: other.showArchivedInCalendar,
      showArchivedInStatistics: other.showArchivedInStatistics,
      calendarSortOption: other.calendarSortOption,
      autoBackupEnabled: other.autoBackupEnabled,
      autoBackupFrequency: other.autoBackupFrequency,
      lastAutoBackupTime: other.lastAutoBackupTime,
      maxAutoBackups: other.maxAutoBackups,
      autoBackupPath: other.autoBackupPath,
      notificationChannelsMigrated: other.notificationChannelsMigrated,
      defaultCategorySeeded: other.defaultCategorySeeded,
      defaultCategoryId: other.defaultCategoryId,
      deviceCalendarSyncEnabled: other.deviceCalendarSyncEnabled,
      deviceCalendarId: other.deviceCalendarId,
      autoEraseCompletedEnabled: other.autoEraseCompletedEnabled,
      autoEraseCompletedFrequency: other.autoEraseCompletedFrequency,
      lastAutoEraseCompletedTime: other.lastAutoEraseCompletedTime,
      caldavEnabled: other.caldavEnabled,
      caldavUrl: other.caldavUrl,
      caldavUsername: other.caldavUsername,
      caldavCalendarHref: other.caldavCalendarHref,
      caldavCalendarName: other.caldavCalendarName,
      caldavCtag: other.caldavCtag,
      caldavAllowInsecure: other.caldavAllowInsecure,
      caldavLastSyncTime: other.caldavLastSyncTime,
      caldavLastError: other.caldavLastError,
      caldavPendingDeletes: other.caldavPendingDeletes,
      todoCardLayout: other.todoCardLayout,
      settingsSchemaVersion: other.settingsSchemaVersion,
    );
  }
}
