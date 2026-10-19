import 'package:zest/data/models/db.dart';
import 'package:zest/domain/entities/app_settings.dart';

/// Maps between Isar [Settings] rows and domain [AppSettings].
abstract final class SettingsMapper {
  /// Converts an Isar [Settings] row to domain [AppSettings].
  static AppSettings toDomain(Settings row) => AppSettings(
    id: row.id,
    onboard: row.onboard,
    theme: row.theme,
    timeformat: row.timeformat,
    materialColor: row.materialColor,
    amoledTheme: row.amoledTheme,
    colorPalette: row.colorPalette,
    appFont: row.appFont,
    isImage: row.isImage,
    screenPrivacy: row.screenPrivacy,
    language: row.language,
    firstDay: row.firstDay,
    calendarFormat: row.calendarFormat,
    defaultScreen: row.defaultScreen,
    snoozeDuration: row.snoozeDuration,
    allTodosSortOption: row.allTodosSortOption,
    showArchivedInAllTodos: row.showArchivedInAllTodos,
    showArchivedInCalendar: row.showArchivedInCalendar,
    showArchivedInStatistics: row.showArchivedInStatistics,
    calendarSortOption: row.calendarSortOption,
    autoBackupEnabled: row.autoBackupEnabled,
    autoBackupFrequency: row.autoBackupFrequency,
    lastAutoBackupTime: row.lastAutoBackupTime,
    maxAutoBackups: row.maxAutoBackups,
    autoBackupPath: row.autoBackupPath,
    notificationChannelsMigrated: row.notificationChannelsMigrated,
    defaultCategorySeeded: row.defaultCategorySeeded,
    defaultCategoryId: row.defaultCategoryId,
    deviceCalendarSyncEnabled: row.deviceCalendarSyncEnabled,
    deviceCalendarId: row.deviceCalendarId,
    autoEraseCompletedEnabled: row.autoEraseCompletedEnabled,
    autoEraseCompletedFrequency: row.autoEraseCompletedFrequency,
    lastAutoEraseCompletedTime: row.lastAutoEraseCompletedTime,
    caldavEnabled: row.caldavEnabled,
    caldavUrl: row.caldavUrl,
    caldavUsername: row.caldavUsername,
    caldavCalendarHref: row.caldavCalendarHref,
    caldavCalendarName: row.caldavCalendarName,
    caldavCtag: row.caldavCtag,
    caldavAllowInsecure: row.caldavAllowInsecure,
    caldavLastSyncTime: row.caldavLastSyncTime,
    caldavLastError: row.caldavLastError,
    caldavPendingDeletes: row.caldavPendingDeletes,
    todoCardLayout: row.todoCardLayout,
    settingsSchemaVersion: row.settingsSchemaVersion,
  );

  /// Applies domain fields onto an existing Isar [row].
  ///
  /// When [settings.id] is non-null, the Isar primary key is updated.
  static void applyDomain(Settings row, AppSettings settings) {
    if (settings.id != null) {
      row.id = settings.id!;
    }
    row.onboard = settings.onboard;
    row.theme = settings.theme;
    row.timeformat = settings.timeformat;
    row.materialColor = settings.materialColor;
    row.amoledTheme = settings.amoledTheme;
    row.colorPalette = settings.colorPalette;
    row.appFont = settings.appFont;
    row.isImage = settings.isImage;
    row.screenPrivacy = settings.screenPrivacy;
    row.language = settings.language;
    row.firstDay = settings.firstDay;
    row.calendarFormat = settings.calendarFormat;
    row.defaultScreen = settings.defaultScreen;
    row.snoozeDuration = settings.snoozeDuration;
    row.allTodosSortOption = settings.allTodosSortOption;
    row.showArchivedInAllTodos = settings.showArchivedInAllTodos;
    row.showArchivedInCalendar = settings.showArchivedInCalendar;
    row.showArchivedInStatistics = settings.showArchivedInStatistics;
    row.calendarSortOption = settings.calendarSortOption;
    row.autoBackupEnabled = settings.autoBackupEnabled;
    row.autoBackupFrequency = settings.autoBackupFrequency;
    row.lastAutoBackupTime = settings.lastAutoBackupTime;
    row.maxAutoBackups = settings.maxAutoBackups;
    row.autoBackupPath = settings.autoBackupPath;
    row.notificationChannelsMigrated = settings.notificationChannelsMigrated;
    row.defaultCategorySeeded = settings.defaultCategorySeeded;
    row.defaultCategoryId = settings.defaultCategoryId;
    row.deviceCalendarSyncEnabled = settings.deviceCalendarSyncEnabled;
    row.deviceCalendarId = settings.deviceCalendarId;
    row.autoEraseCompletedEnabled = settings.autoEraseCompletedEnabled;
    row.autoEraseCompletedFrequency = settings.autoEraseCompletedFrequency;
    row.lastAutoEraseCompletedTime = settings.lastAutoEraseCompletedTime;
    row.caldavEnabled = settings.caldavEnabled;
    row.caldavUrl = settings.caldavUrl;
    row.caldavUsername = settings.caldavUsername;
    row.caldavCalendarHref = settings.caldavCalendarHref;
    row.caldavCalendarName = settings.caldavCalendarName;
    row.caldavCtag = settings.caldavCtag;
    row.caldavAllowInsecure = settings.caldavAllowInsecure;
    row.caldavLastSyncTime = settings.caldavLastSyncTime;
    row.caldavLastError = settings.caldavLastError;
    row.caldavPendingDeletes = settings.caldavPendingDeletes;
    row.todoCardLayout = settings.todoCardLayout;
    row.settingsSchemaVersion = settings.settingsSchemaVersion;
  }

  /// Creates a new Isar [Settings] row from domain [settings].
  static Settings toIsar(AppSettings settings) {
    final row = Settings();
    applyDomain(row, settings);
    return row;
  }
}
