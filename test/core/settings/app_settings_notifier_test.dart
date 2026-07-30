import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/settings/app_settings_state.dart';
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
    container.dispose();
    await closeTestIsar(isar);
  });

  test('update changes in-memory settings state', () {
    final notifier = container.read(appSettingsProvider.notifier);

    notifier.update(
      timeformat: '12',
      firstDay: 'sunday',
      isImage: false,
      colorPalette: 'teal',
      appFont: 'system',
    );

    final state = container.read(appSettingsProvider);
    expect(state.timeformat, '12');
    expect(state.firstDay, 'sunday');
    expect(state.isImage, isFalse);
    expect(state.colorPalette, 'teal');
    expect(state.appFont, 'system');
  });

  test('colorPalette and appFont participate in equality', () {
    const a = AppSettingsState(colorPalette: 'indigo', appFont: 'ubuntu');
    const b = AppSettingsState(colorPalette: 'indigo', appFont: 'ubuntu');
    const c = AppSettingsState(colorPalette: 'teal', appFont: 'ubuntu');

    expect(a, equals(b));
    expect(a, isNot(equals(c)));
  });

  test('update locale changes app settings state', () {
    final notifier = container.read(appSettingsProvider.notifier);

    notifier.update(locale: const Locale('ru', 'RU'));

    expect(
      container.read(appSettingsProvider).locale,
      const Locale('ru', 'RU'),
    );
  });
}
