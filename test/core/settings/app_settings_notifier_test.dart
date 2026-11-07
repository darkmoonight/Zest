import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/settings/app_settings_state.dart';
import 'package:zest/data/mappers/settings_mapper.dart';
import 'package:zest/i18n/strings.g.dart';

import '../../helpers/isar_test_helper.dart';
import '../../helpers/provider_overrides.dart';

void main() {
  setUpAll(() {
    LocaleSettings.setLocaleSync(AppLocale.enUs);
  });

  late Isar isar;
  late ProviderContainer container;

  setUp(() async {
    isar = await openTestIsar();
    container = createTestContainer(isar: isar);
  });

  tearDown(() async {
    if (isarCoreUnavailable) return;
    container.dispose();
    await closeTestIsar(isar);
  });

  test('appSettingsProvider mirrors settingsProvider via fromSettings', () {
    final domain = container.read(settingsProvider);
    final ui = container.read(appSettingsProvider);
    expect(ui, AppSettingsState.fromSettings(domain));
  });

  test('colorPalette and appFont participate in equality', () {
    const a = AppSettingsState(colorPalette: 'indigo', appFont: 'ubuntu');
    const b = AppSettingsState(colorPalette: 'indigo', appFont: 'ubuntu');
    const c = AppSettingsState(colorPalette: 'teal', appFont: 'ubuntu');

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });

  test('localeProvider tracks language on settingsProvider', () {
    final settings = container.read(liveSettingsProvider);
    SettingsMapper.applyDomain(
      settings,
      SettingsMapper.toDomain(settings).copyWith(language: 'ru_RU'),
    );
    container.read(settingsRevisionProvider.notifier).bump();

    expect(container.read(localeProvider), const Locale('ru', 'RU'));
  });
}
