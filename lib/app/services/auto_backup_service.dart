import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:archive/archive.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/main.dart';

class AutoBackupService {
  AutoBackupService._();

  static const _platform = MethodChannel('directory_picker');
  static const String _autoBackupPrefix = 'auto_backup_zest_db_';
  static const String _backupExtension = '.isar';
  static const String _compressedExtension = '.gz';
  static const String _backupFolderName = 'auto_backups';

  // ==================== Auto Backup ====================

  static Future<void> checkAndPerformAutoBackup() async {
    try {
      final currentSettings = await isar.settings.where().findFirst();
      if (currentSettings == null || !currentSettings.autoBackupEnabled) {
        return;
      }

      if (!_shouldPerformBackup(currentSettings)) {
        return;
      }

      await performAutoBackup(currentSettings);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Auto backup check error: $e\n$stackTrace');
      }
    }
  }

  static Future<bool> performManualAutoBackup() async {
    try {
      final currentSettings = await isar.settings.where().findFirst();
      if (currentSettings == null) {
        return false;
      }

      await performAutoBackup(currentSettings);
      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Manual auto backup error: $e\n$stackTrace');
      }
      return false;
    }
  }

  static bool _shouldPerformBackup(Settings currentSettings) {
    final lastBackup = currentSettings.lastAutoBackupTime;
    if (lastBackup == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastBackup);

    return switch (currentSettings.autoBackupFrequency) {
      AutoBackupFrequency.daily => difference.inDays >= 1,
      AutoBackupFrequency.weekly => difference.inDays >= 7,
      AutoBackupFrequency.monthly => difference.inDays >= 30,
    };
  }

  static Future<void> performAutoBackup(Settings currentSettings) async {
    try {
      final customPath = currentSettings.autoBackupPath;
      final isAndroidContentUri =
          customPath != null &&
          customPath.isNotEmpty &&
          customPath.startsWith('content://');

      Directory? backupDir;
      String? allowedPath;

      if (isAndroidContentUri) {
        allowedPath = await _getDownloadsDirectory();
        if (allowedPath == null) {
          if (kDebugMode) {
            print('Auto backup skipped: no valid backup directory');
          }
          return;
        }
      } else {
        backupDir = await _getAutoBackupDirectory(currentSettings);
        if (backupDir == null) {
          if (kDebugMode) {
            print('Auto backup skipped: no valid backup directory');
          }
          return;
        }
        allowedPath = backupDir.path;
      }

      if (!isAndroidContentUri && backupDir != null) {
        await _cleanOldBackups(backupDir, currentSettings);
      }

      final backupFileName = _generateAutoBackupFileName();
      final backupFile = File(p.join(allowedPath, backupFileName));

      if (await backupFile.exists()) {
        await backupFile.delete();
      }

      await isar.copyToFile(backupFile.path);

      final compressedFileName = '$backupFileName$_compressedExtension';
      final compressedFile = File(p.join(allowedPath, compressedFileName));

      await _compressFile(backupFile, compressedFile);
      await backupFile.delete();

      if (isAndroidContentUri) {
        await _saveBackupAndroid(
          backupDir: customPath,
          compressedFile: compressedFile,
          fileName: compressedFileName,
        );
      }

      await _updateLastBackupTime(currentSettings);

      if (kDebugMode) {
        print('Auto backup completed: $compressedFileName');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Auto backup error: $e\n$stackTrace');
      }
    }
  }

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

  static String _generateAutoBackupFileName() {
    final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '$_autoBackupPrefix$timeStamp$_backupExtension';
  }

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

  static Future<void> _compressFile(File source, File destination) async {
    final bytes = await source.readAsBytes();
    final encoder = GZipEncoder();
    final compressedData = encoder.encode(bytes);
    await destination.writeAsBytes(compressedData);
  }

  static Future<void> _updateLastBackupTime(Settings currentSettings) async {
    await isar.writeTxn(() async {
      currentSettings.lastAutoBackupTime = DateTime.now();
      await isar.settings.put(currentSettings);
    });
  }

  static Future<void> _saveBackupAndroid({
    required String backupDir,
    required File compressedFile,
    required String fileName,
  }) async {
    try {
      final backupData = await compressedFile.readAsBytes();

      final success = await _platform.invokeMethod<bool>('writeFile', {
        'directoryUri': backupDir,
        'fileName': fileName,
        'fileContent': backupData,
      });

      await compressedFile.delete();

      if (kDebugMode) {
        if (success == true) {
          print('Auto backup saved to Android content URI successfully');
        } else {
          print('Failed to save auto backup to Android content URI');
        }
      }
    } catch (e) {
      await compressedFile.delete();
      if (kDebugMode) {
        print('Android auto backup save error: $e');
      }
    }
  }

  static Future<String?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
    return null;
  }

  // ==================== Utility Methods ====================

  static Future<List<File>> getAutoBackupFiles(Settings currentSettings) async {
    try {
      final customPath = currentSettings.autoBackupPath;
      final isAndroidContentUri =
          customPath != null &&
          customPath.isNotEmpty &&
          customPath.startsWith('content://');

      if (isAndroidContentUri) {
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
