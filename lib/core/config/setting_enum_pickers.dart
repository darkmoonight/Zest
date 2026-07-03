import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/navigation/home_tabs.dart';
import 'package:zest/data/models/db.dart';

/// Definition for a settings picker backed by a list of enum-like string values.
class SettingEnumPickerDefinition<T> {
  /// Creates an enum-like settings picker definition.
  const SettingEnumPickerDefinition({
    required this.titleKey,
    required this.icon,
    required this.items,
    required this.read,
    required this.write,
    this.itemBuilder,
  });

  /// Slang translation key for the dialog title.
  final String titleKey;

  /// Leading icon shown in the settings tile.
  final IconData icon;

  /// Selectable values shown in the picker.
  final List<T> items;

  /// Reads the current value from persisted [Settings].
  final T Function(Settings settings) read;

  /// Writes the selected value to [Settings].
  final void Function(Settings settings, T value) write;

  /// Optional label builder; defaults to `.tr` on string values.
  final String Function(T value)? itemBuilder;
}

/// Date, time, and snooze pickers on the settings date/time section.
const settingTimeformatPicker = SettingEnumPickerDefinition<String>(
  titleKey: 'timeformat',
  icon: IconsaxPlusBold.clock,
  items: AppConstants.timeformatChoices,
  read: _readTimeformat,
  write: _writeTimeformat,
);

/// First day of week picker.
const settingFirstDayPicker = SettingEnumPickerDefinition<String>(
  titleKey: 'firstDayOfWeek',
  icon: IconsaxPlusBold.calendar,
  items: AppConstants.weekDayChoices,
  read: _readFirstDay,
  write: _writeFirstDay,
);

/// Notification snooze duration picker.
const settingSnoozeDurationPicker = SettingEnumPickerDefinition<int>(
  titleKey: 'snoozeDuration',
  icon: IconsaxPlusBold.timer_1,
  items: AppConstants.snoozeDurationChoices,
  read: _readSnoozeDuration,
  write: _writeSnoozeDuration,
);

/// Theme mode picker on the appearance section.
const settingThemePicker = SettingEnumPickerDefinition<String>(
  titleKey: 'theme',
  icon: IconsaxPlusLinear.moon,
  items: AppConstants.themeChoices,
  read: _readTheme,
  write: _writeTheme,
);

/// Max auto-backup count picker on the data section.
const settingMaxAutoBackupsPicker = SettingEnumPickerDefinition<int>(
  titleKey: 'maxAutoBackups',
  icon: IconsaxPlusLinear.archive,
  items: AppConstants.maxAutoBackupChoices,
  read: _readMaxAutoBackups,
  write: _writeMaxAutoBackups,
);

/// Default home tab picker on the app preferences section.
const settingDefaultScreenPicker = SettingEnumPickerDefinition<String>(
  titleKey: 'defaultScreen',
  icon: IconsaxPlusLinear.home,
  items: tabScreenKeys,
  read: _readDefaultScreen,
  write: _writeDefaultScreen,
);

/// Reads the persisted clock format from [s].
String _readTimeformat(Settings s) => s.timeformat;

/// Writes [v] as the clock format on [s].
void _writeTimeformat(Settings s, String v) => s.timeformat = v;

/// Reads the persisted first day of week from [s].
String _readFirstDay(Settings s) => s.firstDay;

/// Writes [v] as the first day of week on [s].
void _writeFirstDay(Settings s, String v) => s.firstDay = v;

/// Reads the persisted notification snooze duration from [s].
int _readSnoozeDuration(Settings s) => s.snoozeDuration;

/// Writes [v] as the snooze duration on [s].
void _writeSnoozeDuration(Settings s, int v) => s.snoozeDuration = v;

/// Reads the persisted theme mode from [s].
String _readTheme(Settings s) => s.theme ?? AppConstants.defaultTheme;

/// Writes [v] as the theme mode on [s].
void _writeTheme(Settings s, String v) => s.theme = v;

/// Reads the persisted max auto-backup count from [s].
int _readMaxAutoBackups(Settings s) => s.maxAutoBackups;

/// Writes [v] as the max auto-backup count on [s].
void _writeMaxAutoBackups(Settings s, int v) => s.maxAutoBackups = v;

/// Reads the persisted default home tab from [s].
String _readDefaultScreen(Settings s) =>
    s.defaultScreen.isNotEmpty ? s.defaultScreen : AppConstants.defaultScreen;

/// Writes [v] as the default home tab on [s].
void _writeDefaultScreen(Settings s, String v) => s.defaultScreen = v;
