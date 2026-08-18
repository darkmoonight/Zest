import 'package:isar_community/isar.dart';
import 'package:zest/core/bootstrap/isar_bootstrap.dart';
import 'package:zest/core/bootstrap/notification_bootstrap.dart';
import 'package:zest/core/caldav/caldav_credentials.dart';
import 'package:zest/core/caldav/caldav_sync_service.dart';
import 'package:zest/core/database/settings_persist.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/todo_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/i18n/locale_utils.dart';

/// Shared Isar + services for background notification / Workmanager isolates.
class BackgroundIsarContext {
  BackgroundIsarContext._({
    required this.isar,
    required this.openedHere,
    required this.settings,
    required this.todoRepo,
    required this.notifications,
    required this.calendarSync,
    required this.caldavSync,
  });

  /// Open Isar handle for this background run.
  final Isar isar;

  /// Whether [isar] was opened in this isolate and must be closed by [dispose].
  final bool openedHere;

  /// Settings loaded for this run.
  final Settings settings;

  /// Item repository bound to [isar].
  final TodoRepository todoRepo;

  /// Notification service using [settings].
  final NotificationService notifications;

  /// Device calendar sync with [persistSettings] writes.
  final DeviceCalendarSyncService calendarSync;

  /// Two-way CalDAV sync for mark-done / snooze in this isolate.
  final CalDavSyncService caldavSync;

  /// Acquires Isar, applies locale, and builds shared services.
  ///
  /// Returns null when Isar cannot be opened.
  static Future<BackgroundIsarContext?> open() async {
    final (isarInstance, openedHere) =
        await IsarBootstrap.acquireIsarForBackgroundHandler();
    if (isarInstance == null) return null;

    final settings =
        await isarInstance.settings.where().findFirst() ?? Settings();
    await applyAppLocale(appLocaleFromLanguageCode(settings.language));
    await ensureNotificationEnvironmentForBackground(
      snoozeMinutes: settings.snoozeDuration,
    );

    final todoRepo = TodoRepository(isarInstance);
    final notifications = NotificationService(settings: settings);
    final calendarSync = DeviceCalendarSyncService(
      getSettings: () => settings,
      todoRepo: todoRepo,
      saveSettings: (updated) async {
        await persistSettings(isarInstance, updated);
      },
    );
    final caldavSync = CalDavSyncService(
      isar: isarInstance,
      getSettings: () => settings,
      todoRepo: todoRepo,
      saveSettings: (updated) async {
        await persistSettings(isarInstance, updated);
      },
      credentials: CalDavCredentialsStore(),
      notifications: notifications,
      calendarSync: calendarSync,
    );

    return BackgroundIsarContext._(
      isar: isarInstance,
      openedHere: openedHere,
      settings: settings,
      todoRepo: todoRepo,
      notifications: notifications,
      calendarSync: calendarSync,
      caldavSync: caldavSync,
    );
  }

  /// [TodoService] for mark-done / snooze in background handlers.
  TodoService todoService() {
    return TodoService(
      todoRepo: todoRepo,
      notificationService: notifications,
      calendarSync: calendarSync,
      caldavSync: caldavSync,
      timeformat: settings.timeformat,
      languageCode: languageCodeFromSettings(settings.language),
    );
  }

  /// Closes Isar when it was opened for this context.
  Future<void> dispose() async {
    if (openedHere) {
      await isar.close();
    }
  }
}

/// Opens a [BackgroundIsarContext], runs [action], and disposes it.
///
/// Returns false when Isar cannot be opened.
Future<bool> withBackgroundIsar(
  Future<void> Function(BackgroundIsarContext ctx) action,
) async {
  final ctx = await BackgroundIsarContext.open();
  if (ctx == null) return false;
  try {
    await action(ctx);
    return true;
  } finally {
    await ctx.dispose();
  }
}
