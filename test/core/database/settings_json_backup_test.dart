import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/database/settings_json_backup.dart';
import 'package:zest/data/models/db.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('zest_settings_json_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('omits CalDAV identity and sync runtime from sidecar JSON', () async {
    final settings = Settings()
      ..caldavEnabled = true
      ..caldavUrl = 'https://cal.example/dav'
      ..caldavUsername = 'alice'
      ..caldavCalendarHref = '/calendars/alice/tasks/'
      ..caldavCalendarName = 'Tasks'
      ..caldavCtag = 'etag-1'
      ..caldavAllowInsecure = true
      ..caldavLastError = 'boom'
      ..caldavPendingDeletes = '["uid-1"]';

    await SettingsJsonBackup.save(tempDir.path, settings);

    final raw = jsonDecode(
      await File('${tempDir.path}/settings_preferences.json').readAsString(),
    ) as Map<String, dynamic>;

    expect(raw.containsKey('caldavUrl'), isFalse);
    expect(raw.containsKey('caldavUsername'), isFalse);
    expect(raw.containsKey('caldavCtag'), isFalse);
    expect(raw.containsKey('caldavLastError'), isFalse);
    expect(raw.containsKey('caldavPendingDeletes'), isFalse);
    expect(raw['caldavEnabled'], isTrue);
    expect(raw['caldavCalendarHref'], '/calendars/alice/tasks/');
    expect(raw['caldavAllowInsecure'], isTrue);
  });

  test('ignores legacy identity keys when loading sidecar', () async {
    final file = File('${tempDir.path}/settings_preferences.json');
    await file.writeAsString(
      jsonEncode({
        'caldavEnabled': true,
        'caldavUrl': 'https://legacy.example',
        'caldavUsername': 'bob',
        'caldavCtag': 'old',
        'caldavLastError': 'err',
        'caldavPendingDeletes': '["x"]',
        'caldavCalendarName': 'Legacy',
      }),
    );

    final loaded = await SettingsJsonBackup.load(tempDir.path);
    expect(loaded, isNotNull);
    expect(loaded!.caldavEnabled, isTrue);
    expect(loaded.caldavUrl, isNull);
    expect(loaded.caldavUsername, isNull);
    expect(loaded.caldavCtag, isNull);
    expect(loaded.caldavLastError, isNull);
    expect(loaded.caldavPendingDeletes, '[]');
    expect(loaded.caldavCalendarName, 'Legacy');
  });
}
