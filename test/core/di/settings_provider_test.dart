import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/di/settings_revision.dart';
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

  test('settingsProvider returns a new instance after revision bump', () {
    final first = container.read(settingsProvider);
    final live = container.read(liveSettingsProvider);

    expect(identical(first, live), isFalse);

    live.timeformat = '12';
    container.read(settingsRevisionProvider.notifier).bump();

    final second = container.read(settingsProvider);
    expect(identical(first, second), isFalse);
    expect(second.timeformat, '12');
    expect(live.timeformat, '12');
  });

  test(
    'mutating liveSettings does not change prior settingsProvider snapshot',
    () {
      final snapshot = container.read(settingsProvider);
      final live = container.read(liveSettingsProvider);

      live.timeformat = '12';

      expect(snapshot.timeformat, isNot('12'));
      expect(live.timeformat, '12');
    },
  );
}
