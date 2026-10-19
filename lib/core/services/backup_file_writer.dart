import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:zest/core/bootstrap/isar_bootstrap.dart';
import 'package:zest/core/services/backup_constants.dart';
import 'package:zest/core/utils/app_log.dart';
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

    // Strip CalDAV identity / sync runtime from the on-disk copy so backups
    // do not leak server URL or username. Live settings are restored after.
    final caldavSnapshot = await _redactCaldavIdentity(isar);
    try {
      await isar.copyToFile(backupFile.path);
    } finally {
      await _restoreCaldavIdentity(isar, caldavSnapshot);
    }

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
      AppLog.d('Invalid Isar backup: $e');
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

      if (success != true) {
        AppLog.d('Failed to save backup to Android content URI');
      }
      return success == true;
    } catch (e) {
      AppLog.d('Android backup save error: $e');
      return false;
    }
  }

  static Future<void> _deleteQuietly(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  /// Snapshot of CalDAV fields temporarily cleared before [Isar.copyToFile].
  static Future<_CaldavBackupSnapshot?> _redactCaldavIdentity(Isar isar) async {
    final settings = await isar.settings.where().findFirst();
    if (settings == null) return null;

    final snapshot = _CaldavBackupSnapshot(
      url: settings.caldavUrl,
      username: settings.caldavUsername,
      calendarHref: settings.caldavCalendarHref,
      calendarName: settings.caldavCalendarName,
      ctag: settings.caldavCtag,
      lastError: settings.caldavLastError,
      pendingDeletes: settings.caldavPendingDeletes,
    );

    await isar.writeTxn(() async {
      settings.caldavUrl = null;
      settings.caldavUsername = null;
      settings.caldavCalendarHref = null;
      settings.caldavCalendarName = null;
      settings.caldavCtag = null;
      settings.caldavLastError = null;
      settings.caldavPendingDeletes = '[]';
      await isar.settings.put(settings);
    });

    return snapshot;
  }

  /// Restores CalDAV fields cleared by [_redactCaldavIdentity].
  static Future<void> _restoreCaldavIdentity(
    Isar isar,
    _CaldavBackupSnapshot? snapshot,
  ) async {
    if (snapshot == null) return;

    final settings = await isar.settings.where().findFirst();
    if (settings == null) return;

    await isar.writeTxn(() async {
      settings.caldavUrl = snapshot.url;
      settings.caldavUsername = snapshot.username;
      settings.caldavCalendarHref = snapshot.calendarHref;
      settings.caldavCalendarName = snapshot.calendarName;
      settings.caldavCtag = snapshot.ctag;
      settings.caldavLastError = snapshot.lastError;
      settings.caldavPendingDeletes = snapshot.pendingDeletes;
      await isar.settings.put(settings);
    });
  }
}

/// In-memory CalDAV fields held across a backup [Isar.copyToFile].
class _CaldavBackupSnapshot {
  const _CaldavBackupSnapshot({
    required this.url,
    required this.username,
    required this.calendarHref,
    required this.calendarName,
    required this.ctag,
    required this.lastError,
    required this.pendingDeletes,
  });

  final String? url;
  final String? username;
  final String? calendarHref;
  final String? calendarName;
  final String? ctag;
  final String? lastError;
  final String pendingDeletes;
}
