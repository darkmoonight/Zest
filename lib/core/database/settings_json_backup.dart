import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/data/models/db.dart';

/// Sidecar JSON copy of [Settings] so preferences survive Isar schema churn.
///
/// Map keys must stay in sync with [Settings] fields (see [Settings.copyValuesFrom]).
class SettingsJsonBackup {
  SettingsJsonBackup._();

  static const _fileName = 'settings_preferences.json';

  static String _path(String directory) => p.join(directory, _fileName);

  /// Writes [settings] next to the Isar database files.
  static Future<void> save(String directory, Settings settings) async {
    try {
      final file = File(_path(directory));
      await file.writeAsString(jsonEncode(_toJson(settings)));
    } catch (e, stackTrace) {
      debugPrint('Settings JSON backup failed: $e\n$stackTrace');
    }
  }

  /// Loads preferences previously written by [save], or `null` if missing.
  static Future<Settings?> load(String directory) async {
    try {
      final file = File(_path(directory));
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) return null;
      return _fromJson(json);
    } catch (e, stackTrace) {
      debugPrint('Settings JSON restore failed: $e\n$stackTrace');
      return null;
    }
  }

  static Map<String, dynamic> _toJson(Settings s) => {
    'id': s.id,
    'onboard': s.onboard,
    'theme': s.theme,
    'timeformat': s.timeformat,
    'materialColor': s.materialColor,
    'amoledTheme': s.amoledTheme,
    'colorPalette': s.colorPalette,
    'appFont': s.appFont,
    'isImage': s.isImage,
    'screenPrivacy': s.screenPrivacy,
    'language': s.language,
    'firstDay': s.firstDay,
    'calendarFormat': s.calendarFormat,
    'defaultScreen': s.defaultScreen,
    'snoozeDuration': s.snoozeDuration,
    'allTodosSortOption': s.allTodosSortOption.index,
    'showArchivedInAllTodos': s.showArchivedInAllTodos,
    'showArchivedInCalendar': s.showArchivedInCalendar,
    'showArchivedInStatistics': s.showArchivedInStatistics,
    'calendarSortOption': s.calendarSortOption.index,
    'autoBackupEnabled': s.autoBackupEnabled,
    'autoBackupFrequency': s.autoBackupFrequency.index,
    'lastAutoBackupTime': s.lastAutoBackupTime?.toIso8601String(),
    'maxAutoBackups': s.maxAutoBackups,
    'autoBackupPath': s.autoBackupPath,
    'notificationChannelsMigrated': s.notificationChannelsMigrated,
    'defaultCategorySeeded': s.defaultCategorySeeded,
    'defaultCategoryId': s.defaultCategoryId,
    'settingsSchemaVersion': s.settingsSchemaVersion,
  };

  static Settings _fromJson(Map<String, dynamic> json) {
    final settings = Settings();
    final id = json['id'];
    if (id is int) settings.id = id;
    settings.onboard = json['onboard'] as bool? ?? false;
    settings.theme = json['theme'] as String?;
    settings.timeformat =
        json['timeformat'] as String? ?? AppConstants.defaultTimeformat;
    settings.materialColor = json['materialColor'] as bool? ?? true;
    settings.amoledTheme = json['amoledTheme'] as bool? ?? false;
    settings.colorPalette =
        json['colorPalette'] as String? ?? AppConstants.defaultColorPalette;
    settings.appFont =
        json['appFont'] as String? ?? AppConstants.defaultAppFont;
    settings.isImage = json['isImage'] as bool?;
    settings.screenPrivacy = json['screenPrivacy'] as bool?;
    settings.language = json['language'] as String?;
    settings.firstDay =
        json['firstDay'] as String? ?? AppConstants.defaultFirstDay;
    settings.calendarFormat =
        json['calendarFormat'] as String? ?? AppConstants.defaultCalendarFormat;
    settings.defaultScreen =
        json['defaultScreen'] as String? ?? AppConstants.defaultScreen;
    settings.snoozeDuration =
        json['snoozeDuration'] as int? ?? AppConstants.defaultSnoozeDuration;
    settings.allTodosSortOption = _sortOption(json['allTodosSortOption']);
    settings.showArchivedInAllTodos =
        json['showArchivedInAllTodos'] as bool? ?? false;
    settings.showArchivedInCalendar =
        json['showArchivedInCalendar'] as bool? ?? false;
    settings.showArchivedInStatistics =
        json['showArchivedInStatistics'] as bool? ?? false;
    settings.calendarSortOption = _sortOption(json['calendarSortOption']);
    settings.autoBackupEnabled = json['autoBackupEnabled'] as bool? ?? false;
    settings.autoBackupFrequency = _backupFrequency(
      json['autoBackupFrequency'],
    );
    final lastBackup = json['lastAutoBackupTime'] as String?;
    settings.lastAutoBackupTime = lastBackup == null
        ? null
        : DateTime.tryParse(lastBackup);
    settings.maxAutoBackups =
        json['maxAutoBackups'] as int? ?? AppConstants.defaultMaxAutoBackups;
    settings.autoBackupPath = json['autoBackupPath'] as String?;
    settings.notificationChannelsMigrated =
        json['notificationChannelsMigrated'] as bool? ?? false;
    settings.defaultCategorySeeded =
        json['defaultCategorySeeded'] as bool? ?? false;
    settings.defaultCategoryId = json['defaultCategoryId'] as int?;
    settings.settingsSchemaVersion = json['settingsSchemaVersion'] as int? ?? 0;
    return settings;
  }

  static SortOption _sortOption(Object? value) {
    if (value is int && value >= 0 && value < SortOption.values.length) {
      return SortOption.values[value];
    }
    return SortOption.none;
  }

  static AutoBackupFrequency _backupFrequency(Object? value) {
    if (value is int &&
        value >= 0 &&
        value < AutoBackupFrequency.values.length) {
      return AutoBackupFrequency.values[value];
    }
    return AutoBackupFrequency.daily;
  }
}
