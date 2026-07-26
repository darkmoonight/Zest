import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/core/database/settings_schema_migration.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  group('performSettingsSchemaMigrationIfNeeded', () {
    late Isar isar;

    setUp(() async {
      isar = await openTestIsar();
    });

    tearDown(() async {
      await closeTestIsar(isar);
    });

    test('rewrites settings and bumps schema version', () async {
      final settings = Settings()
        ..theme = 'dark'
        ..appFont = 'roboto'
        ..settingsSchemaVersion = 0;
      await isar.writeTxn(() => isar.settings.put(settings));

      final migrated = await performSettingsSchemaMigrationIfNeeded(
        isar,
        settings,
      );

      expect(migrated, isTrue);
      expect(
        settings.settingsSchemaVersion,
        AppConstants.settingsSchemaVersion,
      );

      final loaded = await isar.settings.where().findFirst();
      expect(loaded?.theme, 'dark');
      expect(loaded?.appFont, 'roboto');
      expect(loaded?.settingsSchemaVersion, AppConstants.settingsSchemaVersion);
    });

    test('is a no-op when already at current version', () async {
      final settings = Settings()
        ..settingsSchemaVersion = AppConstants.settingsSchemaVersion;
      await isar.writeTxn(() => isar.settings.put(settings));

      final migrated = await performSettingsSchemaMigrationIfNeeded(
        isar,
        settings,
      );

      expect(migrated, isFalse);
    });
  });

  group('SettingsJsonBackup', () {
    test('round-trips preference values', () async {
      final dir = await Directory.systemTemp.createTemp('zest_settings_json_');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });

      final settings = Settings()
        ..theme = 'light'
        ..language = 'ru_RU'
        ..showArchivedInStatistics = true
        ..snoozeDuration = 30
        ..defaultCategoryId = 7;

      await SettingsJsonBackup.save(dir.path, settings);
      final loaded = await SettingsJsonBackup.load(dir.path);

      expect(loaded, isNotNull);
      expect(loaded!.theme, 'light');
      expect(loaded.language, 'ru_RU');
      expect(loaded.showArchivedInStatistics, isTrue);
      expect(loaded.snoozeDuration, 30);
      expect(loaded.defaultCategoryId, 7);
    });
  });

  group('Settings.copyValuesFrom', () {
    test('clone copies preference fields without sharing identity', () {
      final original = Settings()
        ..theme = 'dark'
        ..showArchivedInStatistics = true
        ..settingsSchemaVersion = 1
        ..defaultCategoryId = 9;

      final copy = original.clone();
      expect(copy.theme, 'dark');
      expect(copy.showArchivedInStatistics, isTrue);
      expect(copy.settingsSchemaVersion, 1);
      expect(copy.defaultCategoryId, 9);

      copy.theme = 'light';
      expect(original.theme, 'dark');
    });
  });
}
