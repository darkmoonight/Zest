import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/theme/theme_mode_notifier.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/provider_overrides.dart';

void main() {
  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await openTestIsar();
    final settings = Settings()..theme = 'dark';
    await seedSettings(isar, settings: settings);
    container = createTestContainer(isar: isar, settings: settings);
  });

  tearDown(() async {
    container.dispose();
    await closeTestIsar(isar);
  });

  test('maps dark theme to ThemeMode.dark', () {
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  test('setTheme persists and updates state', () async {
    final notifier = container.read(themeModeProvider.notifier);

    await notifier.setTheme('light');

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(container.read(settingsProvider).theme, 'light');
    expect((await isar.settings.where().findFirst())?.theme, 'light');
  });

  test('unknown theme falls back to light', () async {
    final notifier = container.read(themeModeProvider.notifier);
    await notifier.setTheme('unknown');

    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('saveOledTheme persists amoled flag', () async {
    final notifier = container.read(themeModeProvider.notifier);

    await notifier.saveOledTheme(true);

    expect(container.read(settingsProvider).amoledTheme, isTrue);
    expect((await isar.settings.where().findFirst())?.amoledTheme, isTrue);
  });

  test('saveMaterialTheme persists material flag', () async {
    final notifier = container.read(themeModeProvider.notifier);

    await notifier.saveMaterialTheme(false);

    expect(container.read(settingsProvider).materialColor, isFalse);
    expect((await isar.settings.where().findFirst())?.materialColor, isFalse);
  });
}
