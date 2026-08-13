import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/services/backup_constants.dart';
import 'package:zest/core/services/backup_file_writer.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/i18n/tr.dart';

/// Manual backup, restore, and directory picking for data management settings.
class IsarService {
  /// Creates a service bound to [isar] and a UI [context] for dialogs.
  IsarService(this._isar, this._context);

  /// Open Isar database instance.
  final Isar _isar;

  /// Build context for loading dialogs and snackbars.
  final BuildContext _context;

  /// Platform channel for Android directory and SAF operations.
  static const _platform = MethodChannel(kBackupDirectoryPickerChannel);

  /// Temporary filename used during restore.
  static const String _tempFileName = 'temp.isar';

  /// Default on-disk Isar database filename.
  static const String _defaultDbName = 'default.isar';

  /// Prefix for a safety copy created before restore.
  static const String _backupBeforeRestorePrefix = 'backup_before_restore_';

  /// Prompts for a destination and writes a gzipped database backup.
  Future<void> createBackup() async {
    try {
      final backupDir = await _pickDirectory();
      if (backupDir == null) {
        showSnackBar('errorPath'.tr, isInfo: true);
        return;
      }

      final stagingPath = await _stagingDirectory(backupDir);
      if (stagingPath == null) {
        showSnackBar('errorPath'.tr, isInfo: true);
        return;
      }
      _showLoadingDialog('creatingBackup'.tr);

      final androidUri = isAndroidContentUri(backupDir) ? backupDir : null;
      final result = await BackupFileWriter.write(
        isar: _isar,
        outputDirectory: stagingPath,
        fileNamePrefix: kManualBackupFilePrefix,
        androidContentUri: androidUri,
      );

      if (result.success) {
        _hideLoadingDialog();
        showSnackBar('successBackup'.tr);
      } else {
        _hideLoadingDialog();
        showSnackBar('error'.tr, isError: true);
      }
    } catch (e, stackTrace) {
      _hideLoadingDialog();
      debugPrint('Backup error: $e\n$stackTrace');
      showSnackBar('error'.tr, isError: true);
    }
  }

  /// Restores the database from a user-selected backup file and restarts the app.
  Future<void> restoreDB() async {
    _showLoadingDialog('restoringBackup'.tr);

    try {
      final backupFile = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'isarDatabase'.tr,
            extensions: [
              BackupFileWriter.backupExtension.substring(1),
              BackupFileWriter.compressedExtension.substring(1),
            ],
          ),
        ],
      );

      if (backupFile == null) {
        _hideLoadingDialog();
        showSnackBar('errorPathRe'.tr, isInfo: true);
        return;
      }

      final selectedFile = File(backupFile.path);

      if (!await selectedFile.exists()) {
        _hideLoadingDialog();
        showSnackBar('errorPathRe'.tr, isInfo: true);
        return;
      }

      final bytes = await selectedFile.readAsBytes();
      await _restoreFromBytes(bytes);
    } catch (e, stackTrace) {
      _hideLoadingDialog();
      debugPrint('Restore error: $e\n$stackTrace');
      showSnackBar('error'.tr, isError: true);
    }
  }

  /// Decompresses [bytes], validates them, then finishes restore and restart.
  Future<void> _restoreFromBytes(List<int> bytes) async {
    final decompressedBytes = BackupFileWriter.decompressIfNeeded(bytes);
    if (decompressedBytes.isEmpty) {
      _hideLoadingDialog();
      showSnackBar('error'.tr, isError: true);
      return;
    }
    await _finishRestore(decompressedBytes);
  }

  /// Applies [decompressedBytes], shows success, and restarts the app.
  Future<void> _finishRestore(List<int> decompressedBytes) async {
    final dbDirectory = await getApplicationSupportDirectory();
    await _performRestore(dbDirectory, decompressedBytes);

    _hideLoadingDialog();
    showSnackBar('successRestore'.tr);

    await Future.delayed(
      AppConstants.restoreRestartDelay,
      () => Restart.restartApp(),
    );
  }

  /// Swaps the live database with [decompressedBytes], keeping a rollback copy.
  Future<void> _performRestore(
    Directory dbDirectory,
    List<int> decompressedBytes,
  ) async {
    final tempIsarPath = p.join(dbDirectory.path, _tempFileName);
    final tempFile = File(tempIsarPath);

    final currentDbPath = p.join(dbDirectory.path, _defaultDbName);
    final currentDbBackupPath = p.join(
      dbDirectory.path,
      '$_backupBeforeRestorePrefix${DateTime.now().millisecondsSinceEpoch}${BackupFileWriter.backupExtension}',
    );

    final currentDb = File(currentDbPath);
    if (await currentDb.exists()) {
      await currentDb.copy(currentDbBackupPath);
    }

    try {
      await tempFile.writeAsBytes(decompressedBytes);
      await _isar.close();

      if (await tempFile.exists()) {
        await tempFile.copy(currentDbPath);
        await tempFile.delete();

        if (await File(currentDbBackupPath).exists()) {
          await File(currentDbBackupPath).delete();
        }
      }
    } catch (e) {
      if (await File(currentDbBackupPath).exists()) {
        await File(currentDbBackupPath).copy(currentDbPath);
      }
      rethrow;
    }
  }

  /// Opens the platform directory picker for auto-backup path selection.
  Future<String?> pickAutoBackupDirectory() async {
    return _pickDirectory();
  }

  /// Resolves a backup destination path for the current platform.
  Future<String?> _pickDirectory() async {
    if (Platform.isAndroid) {
      return _pickDirectoryAndroid();
    }
    if (Platform.isIOS) {
      return _getIosDocumentsPath();
    }
    // Desktop (Linux / Windows / macOS): system directory picker.
    return getDirectoryPath();
  }

  /// Opens the Android SAF directory picker via platform channel.
  Future<String?> _pickDirectoryAndroid() async {
    try {
      final String? uri = await _platform.invokeMethod(
        kBackupPickDirectoryMethod,
      );
      return uri;
    } on PlatformException catch (e) {
      debugPrint('Error picking directory: $e');
      return null;
    }
  }

  /// Returns the iOS application documents directory path.
  Future<String> _getIosDocumentsPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Local staging directory before optional Android SAF copy.
  Future<String?> _stagingDirectory(String? backupDir) async {
    if (isAndroidContentUri(backupDir)) {
      return (await getTemporaryDirectory()).path;
    }
    return backupDir;
  }

  /// Shows a non-dismissible loading dialog with [message].
  void _showLoadingDialog(String message) {
    final colorScheme = Theme.of(_context).colorScheme;

    showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxDialogWidth,
            ),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusXXLarge,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingXXL),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: AppConstants.spacingXL),
                    Text(
                      message,
                      style: Theme.of(dialogContext).textTheme.bodyLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Dismisses the loading dialog when one is on the navigator stack.
  void _hideLoadingDialog() {
    if (Navigator.of(_context).canPop()) {
      Navigator.of(_context).pop();
    }
  }
}
