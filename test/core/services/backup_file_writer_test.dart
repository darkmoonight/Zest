import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/backup_file_writer.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late Directory tempDir;

  setUp(() async {
    isar = await openTestIsar();
    tempDir = await Directory.systemTemp.createTemp('zest_backup_test_');
  });

  tearDown(() async {
    await closeTestIsar(isar);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('directory_picker'),
          null,
        );
  });

  group('BackupFileWriter.generateFileName', () {
    test('matches expected pattern', () {
      final name = BackupFileWriter.generateFileName('backup_');
      expect(name, matches(r'^backup_\d{8}_\d{6}\.isar$'));
    });
  });

  group('BackupFileWriter.decompressIfNeeded', () {
    test('decodes gzipped bytes', () {
      const original = 'zest backup payload';
      final compressed = GZipEncoder().encode(original.codeUnits);
      expect(compressed, isNotNull);

      final decoded = BackupFileWriter.decompressIfNeeded(compressed);
      expect(String.fromCharCodes(decoded), original);
    });

    test('returns raw bytes when not gzipped', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      expect(BackupFileWriter.decompressIfNeeded(bytes), bytes);
    });

    test('throws on truncated gzip instead of returning garbage', () {
      const original = 'zest backup payload';
      final compressed = GZipEncoder().encode(original.codeUnits);
      expect(compressed.length, greaterThan(4));
      final truncated = compressed.sublist(0, 4);
      expect(truncated[0], 0x1f);
      expect(truncated[1], 0x8b);
      expect(
        () => BackupFileWriter.decompressIfNeeded(truncated),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('BackupFileWriter.validateIsarDatabase', () {
    test('accepts a real database copy', () async {
      final copy = File('${tempDir.path}/copy.isar');
      await isar.copyToFile(copy.path);
      final bytes = await copy.readAsBytes();
      expect(await BackupFileWriter.validateIsarDatabase(bytes), isTrue);
    });

    test('rejects garbage bytes', () async {
      expect(
        await BackupFileWriter.validateIsarDatabase([1, 2, 3, 4]),
        isFalse,
      );
    });
  });

  group('BackupFileWriter.write', () {
    test('creates compressed backup file', () async {
      final result = await BackupFileWriter.write(
        isar: isar,
        outputDirectory: tempDir.path,
        fileNamePrefix: 'test_backup_',
      );

      expect(result.success, isTrue);
      expect(result.compressedFileName, endsWith('.gz'));

      final output = File('${tempDir.path}/${result.compressedFileName}');
      expect(await output.exists(), isTrue);
    });

    test('returns success false when Android SAF write fails', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('directory_picker'),
            (call) async => false,
          );

      final result = await BackupFileWriter.write(
        isar: isar,
        outputDirectory: tempDir.path,
        fileNamePrefix: 'android_backup_',
        androidContentUri: 'content://tree/backup',
      );

      expect(result.success, isFalse);
    });

    test('returns success true when Android SAF write succeeds', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('directory_picker'), (
            call,
          ) async {
            expect(call.method, 'writeFile');
            return true;
          });

      final result = await BackupFileWriter.write(
        isar: isar,
        outputDirectory: tempDir.path,
        fileNamePrefix: 'android_backup_ok_',
        androidContentUri: 'content://tree/backup',
      );

      expect(result.success, isTrue);
    });
  });
}
