import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:zest/core/bootstrap/isar_bootstrap.dart';
import 'package:zest/core/services/backup_constants.dart';
import 'package:zest/data/models/db.dart';

/// Outcome of writing a gzipped Isar database backup.
class BackupWriteResult {
  /// Creates a result with [success] and the written [compressedFileName].
  const BackupWriteResult({
    required this.success,
    required this.compressedFileName,
  });

  /// Whether the backup file was written successfully.
  final bool success;

  /// Gzipped backup filename that was created.
  final String compressedFileName;
}

/// Shared backup pipeline: copy Isar to disk, gzip, optional Android SAF write.
class BackupFileWriter {
  /// Private constructor; use static methods only.
  BackupFileWriter._();

  /// Platform channel for Android SAF file writes.
  static const MethodChannel _platform = MethodChannel(
    kBackupDirectoryPickerChannel,
  );

  /// Uncompressed Isar backup file extension.
  static const String backupExtension = '.isar';

  /// Gzip compression extension appended to backup files.
  static const String compressedExtension = '.gz';

  /// Builds `prefix_yyyyMMdd_HHmmss.isar`.
  static String generateFileName(String prefix) {
    final timeStamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '$prefix$timeStamp$backupExtension';
  }

  /// Copies [isar] to [outputDirectory], compresses to `.gz`, and optionally
  /// writes through [androidContentUri] on Android (SAF tree URI).
  ///
  /// On SAF success the staging gzip is deleted after the content URI write.
  static Future<BackupWriteResult> write({
    required Isar isar,
    required String outputDirectory,
    required String fileNamePrefix,
    String? androidContentUri,
  }) async {
    final backupFileName = generateFileName(fileNamePrefix);
    final backupFile = File(p.join(outputDirectory, backupFileName));

    if (await backupFile.exists()) {
      await backupFile.delete();
    }

    await isar.copyToFile(backupFile.path);

    final compressedFileName = '$backupFileName$compressedExtension';
    final compressedFile = File(p.join(outputDirectory, compressedFileName));

    await _compressFile(backupFile, compressedFile);
    await backupFile.delete();

    if (androidContentUri != null && androidContentUri.isNotEmpty) {
      final saved = await _saveToAndroidContentUri(
        directoryUri: androidContentUri,
        compressedFile: compressedFile,
        fileName: compressedFileName,
      );
      await _deleteQuietly(compressedFile);
      return BackupWriteResult(
        success: saved,
        compressedFileName: compressedFileName,
      );
    }

    return BackupWriteResult(
      success: true,
      compressedFileName: compressedFileName,
    );
  }

  static const int _gzipMagic0 = 0x1f;
  static const int _gzipMagic1 = 0x8b;
  static const int _mdbxMagicOffset = 21;
  static const _mdbxMagic = [0x11, 0x4c, 0xef, 0xbd, 0x9d, 0x65, 0x59];

  static bool _hasGzipMagic(List<int> bytes) =>
      bytes.length >= 2 && bytes[0] == _gzipMagic0 && bytes[1] == _gzipMagic1;

  static bool _looksLikeIsar(List<int> bytes) {
    final end = _mdbxMagicOffset + _mdbxMagic.length;
    if (bytes.length < end) return false;
    for (var i = 0; i < _mdbxMagic.length; i++) {
      if (bytes[_mdbxMagicOffset + i] != _mdbxMagic[i]) return false;
    }
    return true;
  }

  /// Decompresses gzip payloads; returns raw bytes when the file is not gzipped.
  static List<int> decompressIfNeeded(List<int> bytes) {
    if (!_hasGzipMagic(bytes)) return bytes;
    final decoded = GZipDecoder().decodeBytes(bytes);
    if (decoded.isEmpty) {
      throw const FormatException('Corrupt gzip backup');
    }
    return decoded;
  }

  /// Whether [directory]/[name].isar opens with this app's schemas.
  static Future<bool> validateIsarDirectory(
    String directory, {
    String name = Isar.defaultName,
    bool deleteFromDisk = false,
  }) async {
    try {
      final isar = await Isar.open(
        IsarBootstrap.schemas,
        directory: directory,
        name: name,
        inspector: false,
      );
      try {
        await isar.settings.where().findAll();
        await isar.tasks.where().findAll();
        await isar.todos.where().findAll();
      } finally {
        await isar.close(deleteFromDisk: deleteFromDisk);
      }
      return true;
    } catch (e) {
      debugPrint('Invalid Isar backup: $e');
      return false;
    }
  }

  /// Whether [bytes] are a readable Isar database for this app.
  static Future<bool> validateIsarDatabase(List<int> bytes) async {
    if (!_looksLikeIsar(bytes)) return false;

    final dir = await Directory.systemTemp.createTemp('zest_restore_validate_');
    final name = 'v${dir.path.hashCode.abs()}';
    try {
      await File(p.join(dir.path, '$name$backupExtension')).writeAsBytes(bytes);
      return await validateIsarDirectory(
        dir.path,
        name: name,
        deleteFromDisk: true,
      );
    } finally {
      try {
        if (await dir.exists()) await dir.delete(recursive: true);
      } catch (_) {}
    }
  }

  /// Gzip-encodes [source] bytes into [destination].
  static Future<void> _compressFile(File source, File destination) async {
    final bytes = await source.readAsBytes();
    final compressedData = GZipEncoder().encode(bytes);
    await destination.writeAsBytes(compressedData);
  }

  /// Writes [compressedFile] into an Android content URI directory.
  static Future<bool> _saveToAndroidContentUri({
    required String directoryUri,
    required File compressedFile,
    required String fileName,
  }) async {
    try {
      final backupData = await compressedFile.readAsBytes();

      final success = await _platform.invokeMethod<bool>(
        kBackupWriteFileMethod,
        {
          'directoryUri': directoryUri,
          'fileName': fileName,
          'fileContent': backupData,
        },
      );

      if (kDebugMode && success != true) {
        debugPrint('Failed to save backup to Android content URI');
      }
      return success == true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Android backup save error: $e');
      }
      return false;
    }
  }

  static Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
