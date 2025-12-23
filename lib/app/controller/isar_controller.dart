import 'dart:io';
import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/utils/show_snack_bar.dart';
import 'package:zest/main.dart';

class IsarController {
  final platform = MethodChannel('directory_picker');

  // ------------------------
  // Loading Dialog
  // ------------------------

  void _showLoadingDialog(String message) {
    final context = Get.context;
    if (context == null) return;

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

  void _hideLoadingDialog() {
    final context = Get.context;
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // ------------------------
  // Database
  // ------------------------

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationSupportDirectory();
      return isar = await Isar.open(
        [TasksSchema, TodosSchema, SettingsSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  // ------------------------
  // Directory Picker
  // ------------------------

  Future<String?> pickDirectory() async {
    if (Platform.isAndroid) {
      return await _pickDirectoryAndroid();
    } else if (Platform.isIOS) {
      return await _getDirectoryPath();
    }
    return null;
  }

  Future<String?> _pickDirectoryAndroid() async {
    try {
      final String? uri = await platform.invokeMethod('pickDirectory');
      return uri;
    } on PlatformException catch (e) {
      debugPrint('Error picking directory: $e');
      return null;
    }
  }

  Future<String?> _getDirectoryPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String?> _getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
    return null;
  }

  Future<String?> _getAllowedPath(String? backUpDir) async {
    if (Platform.isAndroid) {
      return await _getDownloadsDirectory();
    }
    return backUpDir;
  }

  // ------------------------
  // Backup
  // ------------------------

  Future<void> createBackUp() async {
    _showLoadingDialog('creatingBackup'.tr);

    try {
      final backUpDir = await pickDirectory();
      final allowedPath = await _getAllowedPath(backUpDir);

      if (backUpDir == null || allowedPath == null) {
        _hideLoadingDialog();
        showSnackBar('errorPath'.tr, isInfo: true);
        return;
      }

      final backupFileName = _generateBackupFileName();
      final backUpFile = File('$allowedPath/$backupFileName');

      await _prepareBackupFile(backUpFile);
      await isar.copyToFile(backUpFile.path);

      final compressedFileName = '$backupFileName.gz';
      final compressedFile = File('$allowedPath/$compressedFileName');

      final bytes = await backUpFile.readAsBytes();
      final encoder = GZipEncoder();
      final compressedData = encoder.encode(bytes);

      await compressedFile.writeAsBytes(compressedData);
      await backUpFile.delete();

      if (Platform.isAndroid) {
        final backupData = await compressedFile.readAsBytes();
        final success = await platform.invokeMethod<bool>('writeFile', {
          'directoryUri': backUpDir,
          'fileName': compressedFileName,
          'fileContent': backupData,
        });
        await compressedFile.delete();

        _hideLoadingDialog();

        if (success == true) {
          showSnackBar('successBackup'.tr);
        } else {
          showSnackBar('error'.tr, isError: true);
        }
      } else {
        _hideLoadingDialog();
        showSnackBar('successBackup'.tr);
      }
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Backup error: $e');
      showSnackBar('error'.tr, isError: true);
    }
  }

  String _generateBackupFileName() {
    final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'backup_zest_db_$timeStamp.isar';
  }

  Future<void> _prepareBackupFile(File backUpFile) async {
    if (await backUpFile.exists()) {
      await backUpFile.delete();
    }
  }

  // ------------------------
  // Restore
  // ------------------------

  Future<void> restoreDB() async {
    _showLoadingDialog('restoringBackup'.tr);

    try {
      final dbDirectory = await getApplicationSupportDirectory();
      final backupFile = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(label: 'Isar Database', extensions: ['isar', 'gz']),
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
      List<int> decompressedBytes;

      try {
        final decoder = GZipDecoder();
        decompressedBytes = decoder.decodeBytes(bytes);
      } catch (_) {
        decompressedBytes = bytes;
      }

      final tempIsarPath = p.join(dbDirectory.path, 'temp.isar');
      final tempFile = File(tempIsarPath);
      await tempFile.writeAsBytes(decompressedBytes);

      await isar.close();
      final dbPath = p.join(dbDirectory.path, 'default.isar');

      if (await tempFile.exists()) {
        await tempFile.copy(dbPath);
        await tempFile.delete();
      }

      _hideLoadingDialog();
      showSnackBar('successRestoreCategory'.tr);

      await Future.delayed(
        const Duration(milliseconds: 1500),
        () => Restart.restartApp(),
      );
    } catch (e) {
      _hideLoadingDialog();
      debugPrint('Restore error: $e');
      showSnackBar('error'.tr, isError: true);
    }
  }
}
