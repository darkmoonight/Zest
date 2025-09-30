import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/main.dart';
import 'package:archive/archive.dart';

class IsarController {
  var platform = MethodChannel('directory_picker');

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

  Future<String?> pickDirectory() async {
    if (Platform.isAndroid) {
      return await _pickDirectoryAndroid();
    } else if (Platform.isIOS) {
      return await getDirectoryPath();
    }
    return null;
  }

  Future<String?> _pickDirectoryAndroid() async {
    try {
      final String? uri = await platform.invokeMethod('pickDirectory');
      return uri;
    } on PlatformException {
      return null;
    }
  }

  Future<String?> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download';
    } else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
    return null;
  }

  Future<void> createBackUp() async {
    final backUpDir = await pickDirectory();
    final allowedPath = await _getAllowedPath(backUpDir);

    if (backUpDir == null || allowedPath == null) {
      EasyLoading.showInfo('errorPath'.tr);
      return;
    }

    try {
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
        final success = await platform.invokeMethod('writeFile', {
          'directoryUri': backUpDir,
          'fileName': compressedFileName,
          'fileContent': backupData,
        });
        await compressedFile.delete();

        if (success) {
          EasyLoading.showSuccess('successBackup'.tr);
        } else {
          EasyLoading.showError('error'.tr);
        }
      } else {
        EasyLoading.showSuccess('successBackup'.tr);
      }
    } catch (e) {
      EasyLoading.showError('error'.tr);
      return Future.error(e);
    }
  }

  Future<String?> _getAllowedPath(String? backUpDir) async {
    if (Platform.isAndroid) {
      return await getDownloadsDirectory();
    }
    return backUpDir;
  }

  String _generateBackupFileName() {
    final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return 'backup_zest_db$timeStamp.isar';
  }

  Future<void> _prepareBackupFile(File backUpFile) async {
    if (await backUpFile.exists()) {
      await backUpFile.delete();
    }
  }

  Future<void> restoreDB() async {
    final dbDirectory = await getApplicationSupportDirectory();
    final backupFile = await openFile();

    if (backupFile == null) {
      EasyLoading.showInfo('errorPathRe'.tr);
      return;
    }

    try {
      final selectedFile = File(backupFile.path);
      if (!await selectedFile.exists()) {
        EasyLoading.showInfo('errorPathRe'.tr);
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

      EasyLoading.showSuccess('successRestoreCategory'.tr);
      await Future.delayed(
        const Duration(milliseconds: 500),
        () => Restart.restartApp(),
      );
    } catch (e) {
      EasyLoading.showError('error'.tr);
      return Future.error(e);
    }
  }
}
