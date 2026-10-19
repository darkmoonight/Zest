/// Core Riverpod providers for bootstrap, database, repositories, and services.
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/core/bootstrap/app_bootstrap.dart';
import 'package:zest/core/caldav/caldav_credentials.dart';
import 'package:zest/core/caldav/caldav_sync_service.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/services/isar_service.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/domain/usecases/category_usecases.dart';
import 'package:zest/domain/usecases/todo_usecases.dart';
import 'package:zest/core/settings/settings_writer.dart';
import 'package:zest/data/mappers/settings_mapper.dart';
import 'package:zest/data/repositories/category_repository.dart';
import 'package:zest/data/repositories/settings_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';
import 'package:zest/domain/entities/app_settings.dart';
import 'package:zest/domain/repositories/category_repository.dart';
import 'package:zest/domain/repositories/settings_repository.dart';
import 'package:zest/domain/repositories/todo_repository.dart';
import 'package:zest/i18n/locale_utils.dart';

/// Provides the app bootstrap container; must be overridden at startup.
final bootstrapProvider = Provider<AppBootstrap>((ref) {
  throw UnimplementedError('bootstrapProvider must be overridden');
});

/// Provides the shared [Isar] database from [bootstrapProvider].
final isarProvider = Provider<Isar>((ref) => ref.watch(bootstrapProvider).isar);

/// Builds [IsarService] for dialogs (backup/restore); Isar stays out of UI.
IsarService createIsarService(WidgetRef ref, BuildContext context) =>
    IsarService(ref.read(isarProvider), context);

/// Runs a manual auto-backup using the app [isarProvider].
Future<bool> performManualAutoBackup(WidgetRef ref) =>
    AutoBackupService.performManualAutoBackup(ref.read(isarProvider));

/// Live mutable [Settings] singleton from bootstrap.
///
/// Use [ref.read] for writes. Do not watch this for UI — identity never changes.
final liveSettingsProvider = Provider<Settings>(
  (ref) => ref.watch(bootstrapProvider).settings,
);

/// Reactive [AppSettings] snapshot for UI.
///
/// Maps a [Settings.clone] of the live row when [settingsRevisionProvider] bumps
/// so Riverpod notifies listeners (the live bootstrap instance alone would not).
final settingsProvider = Provider<AppSettings>((ref) {
  ref.watch(settingsRevisionProvider);
  return SettingsMapper.toDomain(
    ref.read(liveSettingsProvider).clone(includeId: true),
  );
});

/// Provides the installed app version from platform package info.
final appVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

/// Provides the category repository.
final categoryRepositoryProvider = Provider<CategoryRepositoryPort>(
  (ref) => CategoryRepository(ref.watch(isarProvider)),
);

/// Provides the item repository.
final todoRepositoryProvider = Provider<TodoRepositoryPort>(
  (ref) => TodoRepository(ref.watch(isarProvider)),
);

/// Provides the settings repository and notifies on save.
final settingsRepositoryProvider = Provider<SettingsRepositoryPort>(
  (ref) => SettingsRepository(
    ref.watch(isarProvider),
    onSaved: () => notifySettingsChanged(ref),
  ),
);

/// Provides the local notification scheduling service.
///
/// Settings are read lazily so preference saves do not recreate this service.
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(
    settingsReader: () => ref.read(settingsProvider),
    categoryRepo: ref.watch(categoryRepositoryProvider),
  ),
);

/// Item CRUD / status / move service (rebuilds when clock/locale prefs change).
final todoServiceProvider = Provider<TodoService>((ref) {
  final timeformat = ref.watch(settingsProvider.select((s) => s.timeformat));
  final language = ref.watch(settingsProvider.select((s) => s.language));
  return TodoService(
    todoRepo: ref.watch(todoRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    calendarSync: ref.watch(deviceCalendarSyncServiceProvider),
    caldavSync: ref.watch(calDavSyncServiceProvider),
    timeformat: timeformat,
    languageCode: languageCodeFromSettings(language),
  );
});

/// Category (task list) CRUD service.
final categoryServiceProvider = Provider<CategoryService>(
  (ref) => CategoryService(
    categoryRepo: ref.watch(categoryRepositoryProvider),
    todoRepo: ref.watch(todoRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
    calendarSync: ref.watch(deviceCalendarSyncServiceProvider),
    caldavSync: ref.watch(calDavSyncServiceProvider),
  ),
);

/// One-way export of item deadlines to the Android device calendar.
final deviceCalendarSyncServiceProvider = Provider<DeviceCalendarSyncService>(
  (ref) => DeviceCalendarSyncService(
    getSettings: () => SettingsMapper.toDomain(ref.read(liveSettingsProvider)),
    todoRepo: ref.watch(todoRepositoryProvider),
    saveSettings: (settings) async {
      SettingsMapper.applyDomain(ref.read(liveSettingsProvider), settings);
      await ref.read(settingsRepositoryProvider).save(settings);
      ref.read(settingsRevisionProvider.notifier).bump();
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
    getSettings: () => SettingsMapper.toDomain(ref.read(liveSettingsProvider)),
    todoRepo: ref.watch(todoRepositoryProvider),
    saveSettings: (settings) async {
      SettingsMapper.applyDomain(ref.read(liveSettingsProvider), settings);
      await ref.read(settingsRepositoryProvider).save(settings);
      ref.read(settingsRevisionProvider.notifier).bump();
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
    required LiveSettingsMutate mutate,
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
    required LiveSettingsMutate mutate,
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
    required LiveSettingsMutate mutate,
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
