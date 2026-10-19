import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/bootstrap/app_bootstrap.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/settings/app_settings_state.dart';
import 'package:zest/data/mappers/settings_mapper.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/shell/application/fab_notifier.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

import 'fake_notification_show.dart';

/// Creates a [ProviderContainer] wired to an in-memory [isar] instance.
ProviderContainer createTestContainer({
  required Isar isar,
  Settings? settings,
  FakeNotificationShow? fakeNotifications,
  Iterable extraOverrides = const [],
}) {
  final resolvedSettings = settings ?? Settings();

  return ProviderContainer(
    overrides: [
      bootstrapProvider.overrideWithValue(
        AppBootstrap(isar: isar, settings: resolvedSettings),
      ),
      if (fakeNotifications != null)
        notificationServiceProvider.overrideWithValue(
          NotificationService(notificationShow: fakeNotifications),
        ),
      appSettingsProvider.overrideWith(
        () => _TestAppSettingsNotifier(resolvedSettings),
      ),
      ...extraOverrides,
    ],
  );
}

class _TestAppSettingsNotifier extends AppSettingsNotifier {
  _TestAppSettingsNotifier(this._settings);

  final Settings _settings;

  @override
  AppSettingsState build() =>
      AppSettingsState.fromSettings(SettingsMapper.toDomain(_settings));
}

/// Reads [TodosNotifier] after its initial async load completes.
Future<TodosNotifier> readTodosNotifier(ProviderContainer container) async {
  final notifier = container.read(todosNotifierProvider.notifier);
  await Future<void>.delayed(Duration.zero);
  await notifier.reloadTodos();
  return notifier;
}

/// Reads [CategoriesNotifier] after its initial async load completes.
Future<CategoriesNotifier> readCategoriesNotifier(
  ProviderContainer container,
) async {
  final notifier = container.read(categoriesNotifierProvider.notifier);
  await Future<void>.delayed(Duration.zero);
  await notifier.reloadCategories();
  return notifier;
}

/// Creates a container with [FabNotifier] ready to use.
(FabNotifier notifier, ProviderContainer container) createFabTestScope() {
  final container = ProviderContainer();
  final notifier = container.read(fabNotifierProvider.notifier);
  return (notifier, container);
}
