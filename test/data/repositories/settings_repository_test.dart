import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/settings_repository.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late SettingsRepository repo;
  var savedCount = 0;

  setUp(() async {
    isar = await openTestIsar();
    savedCount = 0;
    repo = SettingsRepository(isar, onSaved: () => savedCount++);
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('getSettings returns defaults when database is empty', () async {
    final settings = await repo.getSettings();

    expect(settings.theme, 'system');
    expect(settings.timeformat, '24');
    expect(settings.snoozeDuration, 10);
  });

  test('save persists settings and invokes callback', () async {
    final settings = Settings()
      ..theme = 'dark'
      ..snoozeDuration = 25
      ..language = 'ru';

    await repo.save(settings);

    final loaded = await repo.getSettings();
    expect(loaded.theme, 'dark');
    expect(loaded.snoozeDuration, 25);
    expect(loaded.language, 'ru');
    expect(savedCount, 1);
  });

  test('save updates existing settings row', () async {
    final settings = await repo.getSettings();
    settings.autoBackupEnabled = true;
    settings.maxAutoBackups = 7;
    await repo.save(settings);

    final loaded = await repo.getSettings();
    expect(loaded.autoBackupEnabled, isTrue);
    expect(loaded.maxAutoBackups, 7);
  });
}
