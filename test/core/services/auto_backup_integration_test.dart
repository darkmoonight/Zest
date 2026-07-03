import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/data/models/db.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory backupDir;

  setUp(() async {
    isar = await openTestIsar();
    backupDir = await Directory.systemTemp.createTemp('zest_auto_backup_');
  });

  tearDown(() async {
    await closeTestIsar(isar);
    if (await backupDir.exists()) {
      await backupDir.delete(recursive: true);
    }
  });

  Future<Settings> saveEnabledSettings({
    bool enabled = true,
    int maxBackups = 3,
  }) async {
    final settings = Settings()
      ..autoBackupEnabled = enabled
      ..autoBackupPath = backupDir.path
      ..maxAutoBackups = maxBackups
      ..autoBackupFrequency = AutoBackupFrequency.daily;
    await seedSettings(isar, settings: settings);
    return settings;
  }

  test('checkAndPerformAutoBackup is a no-op when disabled', () async {
    await saveEnabledSettings(enabled: false);

    await AutoBackupService.checkAndPerformAutoBackup(isar);

    final files = backupDir.listSync().whereType<File>().toList();
    expect(files, isEmpty);
  });

  test('performManualAutoBackup writes a compressed backup file', () async {
    await saveEnabledSettings();

    final success = await AutoBackupService.performManualAutoBackup(isar);
    expect(success, isTrue);

    final files = await AutoBackupService.getAutoBackupFiles(
      (await isar.settings.where().findFirst())!,
    );
    expect(files, isNotEmpty);
    expect(files.first.path, endsWith('.gz'));
  });

  test('retention keeps only maxAutoBackups newest files', () async {
    final settings = await saveEnabledSettings(maxBackups: 2);

    for (var i = 0; i < 3; i++) {
      final file = File(
        '${backupDir.path}/auto_backup_zest_db_2026062${i}_12000$i.gz',
      );
      await file.writeAsString('backup $i');
      await file.setLastModified(DateTime(2026, 6, 20 + i, 12, 0, i));
    }

    final backupDirFile = Directory(backupDir.path);
    final existing = backupDirFile.listSync().whereType<File>().length;
    expect(existing, 3);

    await AutoBackupService.performAutoBackup(isar, settings);

    final remaining = backupDirFile
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('auto_backup_zest_db_'))
        .toList();
    expect(remaining.length, lessThanOrEqualTo(2));
  });

  test('getAutoBackupFiles returns empty list for content URI paths', () async {
    final settings = Settings()..autoBackupPath = 'content://tree/backup';

    final files = await AutoBackupService.getAutoBackupFiles(settings);
    expect(files, isEmpty);
  });
}
