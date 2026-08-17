import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/services/auto_backup_service.dart';
import 'package:zest/data/models/db.dart';

void main() {
  group('shouldPerformAutoBackup', () {
    test('runs when there is no previous backup', () {
      expect(
        shouldPerformAutoBackup(
          lastBackupTime: null,
          frequency: AutoBackupFrequency.daily,
        ),
        isTrue,
      );
    });

    test('daily runs on the next calendar day', () {
      final lastBackup = DateTime(2026, 6, 22, 23, 30);
      final nextMorning = DateTime(2026, 6, 23, 8, 0);

      expect(
        shouldPerformAutoBackup(
          lastBackupTime: lastBackup,
          frequency: AutoBackupFrequency.daily,
          now: nextMorning,
        ),
        isTrue,
      );
    });

    test('daily does not run on the same calendar day', () {
      final lastBackup = DateTime(2026, 6, 23, 8, 0);
      final laterSameDay = DateTime(2026, 6, 23, 20, 0);

      expect(
        shouldPerformAutoBackup(
          lastBackupTime: lastBackup,
          frequency: AutoBackupFrequency.daily,
          now: laterSameDay,
        ),
        isFalse,
      );
    });

    test('weekly waits seven calendar days', () {
      final lastBackup = DateTime(2026, 6, 1, 12, 0);

      expect(
        shouldPerformAutoBackup(
          lastBackupTime: lastBackup,
          frequency: AutoBackupFrequency.weekly,
          now: DateTime(2026, 6, 7, 12, 0),
        ),
        isFalse,
      );
      expect(
        shouldPerformAutoBackup(
          lastBackupTime: lastBackup,
          frequency: AutoBackupFrequency.weekly,
          now: DateTime(2026, 6, 8, 12, 0),
        ),
        isTrue,
      );
    });

    test('monthly waits until the next calendar month', () {
      final lastBackup = DateTime(2026, 5, 1, 12, 0);

      expect(
        shouldPerformAutoBackup(
          lastBackupTime: lastBackup,
          frequency: AutoBackupFrequency.monthly,
          now: DateTime(2026, 5, 31, 12, 0),
        ),
        isFalse,
      );
      expect(
        shouldPerformAutoBackup(
          lastBackupTime: lastBackup,
          frequency: AutoBackupFrequency.monthly,
          now: DateTime(2026, 6, 1, 12, 0),
        ),
        isTrue,
      );
    });
  });

  group('formatBackupFileName', () {
    test('parses timestamp from backup file name', () {
      expect(
        AutoBackupService.formatBackupFileName(
          'auto_backup_zest_db_20260623_143000.gz',
        ),
        '2026-06-23 14:30',
      );
    });

    test('returns original name when pattern does not match', () {
      expect(
        AutoBackupService.formatBackupFileName('manual_backup.gz'),
        'manual_backup.gz',
      );
    });
  });
}
