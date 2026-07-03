/// Core Riverpod providers for bootstrap, database, repositories, and services.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/core/bootstrap/app_bootstrap.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/settings_repository.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';

/// Provides the app bootstrap container; must be overridden at startup.
final bootstrapProvider = Provider<AppBootstrap>((ref) {
  throw UnimplementedError('bootstrapProvider must be overridden');
});

/// Provides the shared [Isar] database from [bootstrapProvider].
final isarProvider = Provider<Isar>((ref) => ref.watch(bootstrapProvider).isar);

/// Provides persisted [Settings], refreshing when [settingsRevisionProvider] changes.
final settingsProvider = Provider<Settings>((ref) {
  ref.watch(settingsRevisionProvider);
  return ref.watch(bootstrapProvider).settings;
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

/// Provides the todo repository.
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
  (ref) => NotificationService(),
);
