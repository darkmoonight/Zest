import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

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
  static const MethodChannel _platform = MethodChannel('directory_picker');

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

  /// Decompresses [bytes] when gzipped; returns raw bytes otherwise.
  static List<int> decompressIfNeeded(List<int> bytes) {
    try {
      return GZipDecoder().decodeBytes(bytes);
    } catch (_) {
      return bytes;
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

      final success = await _platform.invokeMethod<bool>('writeFile', {
        'directoryUri': directoryUri,
        'fileName': fileName,
        'fileContent': backupData,
      });

      await compressedFile.delete();

      if (kDebugMode && success != true) {
        debugPrint('Failed to save backup to Android content URI');
      }
      return success == true;
    } catch (e) {
      if (await compressedFile.exists()) {
        await compressedFile.delete();
      }
      if (kDebugMode) {
        print('Android backup save error: $e');
      }
      return false;
    }
  }
}
