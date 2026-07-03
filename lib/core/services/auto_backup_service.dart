import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:zest/core/services/backup_file_writer.dart';
import 'package:zest/data/models/db.dart';

/// Whether an automatic backup should run for [frequency] given [lastBackupTime].
bool shouldPerformAutoBackup({
  required DateTime? lastBackupTime,
  required AutoBackupFrequency frequency,
  DateTime? now,
}) {
  if (lastBackupTime == null) return true;

  final current = now ?? DateTime.now();

  return switch (frequency) {
    AutoBackupFrequency.daily => !_isSameCalendarDay(lastBackupTime, current),
    AutoBackupFrequency.weekly =>
      current.difference(lastBackupTime).inDays >= 7,
    AutoBackupFrequency.monthly =>
      current.difference(lastBackupTime).inDays >= 30,
  };
}

/// Returns whether [a] and [b] fall on the same calendar day.
bool _isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Scheduled and on-demand automatic database backups with retention.
class AutoBackupService {
  /// Private constructor; use static methods only.
  AutoBackupService._();

  /// Filename prefix for automatic backup archives.
  static const String _autoBackupPrefix = 'auto_backup_zest_db_';

  /// Default subdirectory name under app support for backups.
  static const String _backupFolderName = 'auto_backups';

  /// Runs a backup when enabled and the configured interval has elapsed.
  static Future<void> checkAndPerformAutoBackup(Isar isar) async {
    try {
      final currentSettings = await isar.settings.where().findFirst();
      if (currentSettings == null || !currentSettings.autoBackupEnabled) {
        return;
      }

      if (!shouldPerformAutoBackup(
        lastBackupTime: currentSettings.lastAutoBackupTime,
        frequency: currentSettings.autoBackupFrequency,
      )) {
        return;
      }

      await performAutoBackup(isar, currentSettings);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Auto backup check error: $e\n$stackTrace');
      }
    }
  }

  /// Forces an immediate backup regardless of schedule.
  static Future<bool> performManualAutoBackup(Isar isar) async {
    try {
      final currentSettings = await isar.settings.where().findFirst();
      if (currentSettings == null) {
        return false;
      }

      return performAutoBackup(isar, currentSettings);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Manual auto backup error: $e\n$stackTrace');
      }
      return false;
    }
  }

  /// Writes a compressed backup and updates last-backup metadata.
  static Future<bool> performAutoBackup(
    Isar isar,
    Settings currentSettings,
  ) async {
    try {
      final customPath = currentSettings.autoBackupPath;
      final isAndroidContentUri = _isAndroidContentUri(customPath);

      Directory? backupDir;
      String? outputDirectory;

      if (isAndroidContentUri) {
        outputDirectory = (await getTemporaryDirectory()).path;
      } else {
        backupDir = await _getAutoBackupDirectory(currentSettings);
        if (backupDir == null) {
          if (kDebugMode) {
            print('Auto backup skipped: no valid backup directory');
          }
          return false;
        }
        outputDirectory = backupDir.path;
      }

      if (!isAndroidContentUri && backupDir != null) {
        await _cleanOldBackups(backupDir, currentSettings);
      }

      final result = await BackupFileWriter.write(
        isar: isar,
        outputDirectory: outputDirectory,
        fileNamePrefix: _autoBackupPrefix,
        androidContentUri: isAndroidContentUri ? customPath : null,
      );

      if (!result.success) {
        return false;
      }

      await _updateLastBackupTime(isar, currentSettings);

      if (kDebugMode) {
        print('Auto backup completed: ${result.compressedFileName}');
      }
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Auto backup error: $e\n$stackTrace');
      }
      return false;
    }
  }

  /// Returns whether [path] is an Android content (SAF) URI.
  static bool _isAndroidContentUri(String? path) =>
      path != null && path.isNotEmpty && path.startsWith('content://');

  /// Deletes oldest backups when count exceeds [currentSettings.maxAutoBackups].
  static Future<void> _cleanOldBackups(
    Directory backupDir,
    Settings currentSettings,
  ) async {
    try {
      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => p.basename(f.path).startsWith(_autoBackupPrefix))
          .toList();

      if (files.isEmpty) return;

      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      if (files.length >= currentSettings.maxAutoBackups) {
        final filesToDelete = files.skip(currentSettings.maxAutoBackups - 1);
        for (final file in filesToDelete) {
          await file.delete();
          if (kDebugMode) {
            print('Deleted old backup: ${p.basename(file.path)}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning old backups: $e');
      }
    }
  }

  /// Resolves the backup directory from settings or app support.
  static Future<Directory?> _getAutoBackupDirectory(
    Settings currentSettings,
  ) async {
    try {
      final customPath = currentSettings.autoBackupPath;
      if (customPath != null && customPath.isNotEmpty) {
        final customDir = Directory(customPath);
        if (await customDir.exists()) {
          return customDir;
        }
        if (kDebugMode) {
          print('Custom backup path does not exist: $customPath');
        }
      }

      final appDir = await getApplicationSupportDirectory();
      final backupDir = Directory(p.join(appDir.path, _backupFolderName));

      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      return backupDir;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auto backup directory: $e');
      }
      return null;
    }
  }

  /// Persists [currentSettings.lastAutoBackupTime] after a successful backup.
  static Future<void> _updateLastBackupTime(
    Isar isar,
    Settings currentSettings,
  ) async {
    await isar.writeTxn(() async {
      currentSettings.lastAutoBackupTime = DateTime.now();
      await isar.settings.put(currentSettings);
    });
  }

  /// Lists automatic backup files sorted by newest first.
  static Future<List<File>> getAutoBackupFiles(Settings currentSettings) async {
    try {
      if (_isAndroidContentUri(currentSettings.autoBackupPath)) {
        if (kDebugMode) {
          print('Cannot list files from Android content URI');
        }
        return [];
      }

      final backupDir = await _getAutoBackupDirectory(currentSettings);
      if (backupDir == null) return [];

      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => p.basename(f.path).startsWith(_autoBackupPrefix))
          .toList();

      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      return files;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auto backup files: $e');
      }
      return [];
    }
  }

  /// Formats an auto-backup filename into a human-readable timestamp.
  static String formatBackupFileName(String fileName) {
    final regex = RegExp(r'auto_backup_zest_db_(\d{8})_(\d{6})');
    final match = regex.firstMatch(fileName);

    if (match == null) return fileName;

    final date = match.group(1)!;
    final time = match.group(2)!;

    final year = date.substring(0, 4);
    final month = date.substring(4, 6);
    final day = date.substring(6, 8);

    final hour = time.substring(0, 2);
    final minute = time.substring(2, 4);

    return '$year-$month-$day $hour:$minute';
  }
}
