/// Core Riverpod providers for bootstrap, database, repositories, and services.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/core/bootstrap/app_bootstrap.dart';
import 'package:zest/core/caldav/caldav_credentials.dart';
import 'package:zest/core/caldav/caldav_sync_service.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/task_service.dart';
import 'package:zest/core/services/todo_service.dart';
import 'package:zest/core/settings/settings_writer.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/settings_repository.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/i18n/locale_utils.dart';

/// Provides the app bootstrap container; must be overridden at startup.
final bootstrapProvider = Provider<AppBootstrap>((ref) {
  throw UnimplementedError('bootstrapProvider must be overridden');
});

/// Provides the shared [Isar] database from [bootstrapProvider].
final isarProvider = Provider<Isar>((ref) => ref.watch(bootstrapProvider).isar);

/// Live mutable [Settings] singleton from bootstrap.
///
/// Use [ref.read] for writes. Do not watch this for UI — identity never changes.
final liveSettingsProvider = Provider<Settings>(
  (ref) => ref.watch(bootstrapProvider).settings,
);

/// Reactive [Settings] snapshot for UI.
///
/// Returns a [Settings.clone] when [settingsRevisionProvider] bumps so Riverpod
/// notifies listeners (the live bootstrap instance alone would not).
final settingsProvider = Provider<Settings>((ref) {
  ref.watch(settingsRevisionProvider);
  return ref.read(liveSettingsProvider).clone(includeId: true);
});

/// Provides the installed app version from platform package info.
final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

/// Provides the task repository.
final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepository(ref.watch(isarProvider)),
);

/// Provides the item repository.
final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => TodoRepository(ref.watch(isarProvider)),
);

/// Provides the settings repository and notifies on save.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(isarProvider),
    onSaved: () => notifySettingsChanged(ref),
  ),
);

/// Provides the local notification scheduling service.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(settings: ref.watch(settingsProvider)),
);

/// Item CRUD / status / move service (rebuilds when clock/locale prefs change).
final todoServiceProvider = Provider<TodoService>((ref) {
  final settings = ref.watch(settingsProvider);
  return TodoService(
    todoRepo: ref.watch(todoRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    calendarSync: ref.watch(deviceCalendarSyncServiceProvider),
    caldavSync: ref.watch(calDavSyncServiceProvider),
    timeformat: settings.timeformat,
    languageCode: languageCodeFromSettings(settings.language),
  );
});

/// Category (task list) CRUD service.
final taskServiceProvider = Provider<TaskService>(
  (ref) => TaskService(
    taskRepo: ref.watch(taskRepositoryProvider),
    todoRepo: ref.watch(todoRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    calendarSync: ref.watch(deviceCalendarSyncServiceProvider),
  ),
);

/// One-way export of item deadlines to the Android device calendar.
final deviceCalendarSyncServiceProvider = Provider<DeviceCalendarSyncService>(
  (ref) => DeviceCalendarSyncService(
    getSettings: () => ref.read(liveSettingsProvider),
    todoRepo: ref.watch(todoRepositoryProvider),
    saveSettings: (settings) async {
      await ref.read(settingsRepositoryProvider).save(settings);
    },
  ),
);

/// Secure store for the CalDAV password.
final calDavCredentialsStoreProvider = Provider<CalDavCredentialsStore>(
  (ref) => CalDavCredentialsStore(),
);

/// Two-way CalDAV VTODO sync against the selected calendar.
final calDavSyncServiceProvider = Provider<CalDavSyncService>(
  (ref) => CalDavSyncService(
    isar: ref.watch(isarProvider),
    getSettings: () => ref.read(liveSettingsProvider),
    todoRepo: ref.watch(todoRepositoryProvider),
    saveSettings: (settings) async {
      await ref.read(settingsRepositoryProvider).save(settings);
    },
    credentials: ref.watch(calDavCredentialsStoreProvider),
    notifications: ref.watch(notificationServiceProvider),
    calendarSync: ref.watch(deviceCalendarSyncServiceProvider),
  ),
);

/// Live [Settings] writes with revision bump and rollback on persist failure.
extension LiveSettingsWidgetWrite on WidgetRef {
  /// Mutates live settings and awaits persist.
  Future<void> writeLiveSettings({
    required void Function(Settings settings) mutate,
    Future<void> Function()? afterSave,
  }) {
    return SettingsWriter.write(
      settings: read(liveSettingsProvider),
      revision: read(settingsRevisionProvider.notifier),
      repository: read(settingsRepositoryProvider),
      mutate: mutate,
      afterSave: afterSave,
    );
  }

  /// Mutates live settings and persists in the background.
  void writeLiveSettingsOptimistic({
    required void Function(Settings settings) mutate,
    Future<void> Function()? afterSave,
    bool backgroundAfterSave = false,
  }) {
    SettingsWriter.writeOptimistic(
      settings: read(liveSettingsProvider),
      revision: read(settingsRevisionProvider.notifier),
      repository: read(settingsRepositoryProvider),
      mutate: mutate,
      afterSave: afterSave,
      backgroundAfterSave: backgroundAfterSave,
    );
  }
}

/// [LiveSettingsWidgetWrite] for [Notifier.ref] / other [Ref]s.
extension LiveSettingsRefWrite on Ref {
  /// Mutates live settings and awaits persist.
  Future<void> writeLiveSettings({
    required void Function(Settings settings) mutate,
    Future<void> Function()? afterSave,
  }) {
    return SettingsWriter.write(
      settings: read(liveSettingsProvider),
      revision: read(settingsRevisionProvider.notifier),
      repository: read(settingsRepositoryProvider),
      mutate: mutate,
      afterSave: afterSave,
    );
  }
}
