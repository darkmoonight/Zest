import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/setting_enum_pickers.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/settings/presentation/widgets/settings_selection.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';

/// Time format, calendar week-start, and notification snooze settings.
class SettingsDateTimeSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsDateTimeSection].
  const SettingsDateTimeSection({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<SettingsDateTimeSection> createState() =>
      _SettingsDateTimeSectionState();
}

/// Widget that settings date time section state.
class _SettingsDateTimeSectionState
    extends SettingsSectionConsumerState<SettingsDateTimeSection> {
  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final timeformat = ref.watch(
      appSettingsProvider.select((s) => s.timeformat),
    );
    final snoozeDuration = ref.watch(
      settingsProvider.select((s) => s.snoozeDuration),
    );
    final firstDay = ref.watch(appSettingsProvider.select((s) => s.firstDay));
    final settings = ref.read(liveSettingsProvider);

    return SettingsSection(
      title: 'dateTime',
      icon: IconsaxPlusBold.calendar_2,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.clock_1),
          title: 'timeformat',
          value: timeformat.tr,
          onTap: () => _showTimeFormatDialog(context, settings),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.calendar_edit),
          title: 'firstDayOfWeek',
          value: firstDay.tr,
          onTap: () => _showFirstDayOfWeekDialog(context, settings),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.timer_1),
          title: 'snoozeDuration',
          value: '$snoozeDuration ${'min'.tr}',
          onTap: () => _showSnoozeDurationDialog(context, settings),
        ),
      ],
    );
  }

  /// Show time format dialog.
  void _showTimeFormatDialog(BuildContext context, Settings settings) {
    final picker = settingTimeformatPicker;
    showSettingsSelection<String>(
      context: context,
      title: picker.titleKey,
      icon: picker.icon,
      items: picker.items,
      currentValue: picker.read(settings),
      itemBuilder: (format) => format.tr,
      onSelected: actions.saveTimeFormat,
    );
  }

  /// Show first day of week dialog.
  void _showFirstDayOfWeekDialog(BuildContext context, Settings settings) {
    final picker = settingFirstDayPicker;
    final appSettings = ref.read(appSettingsProvider);
    showSettingsSelection<String>(
      context: context,
      title: picker.titleKey,
      icon: picker.icon,
      items: picker.items,
      currentValue: appSettings.firstDay,
      itemBuilder: (day) => day.tr,
      onSelected: actions.saveFirstDayOfWeek,
    );
  }

  /// Show snooze duration dialog.
  void _showSnoozeDurationDialog(BuildContext context, Settings settings) {
    final picker = settingSnoozeDurationPicker;
    showSettingsSelection<int>(
      context: context,
      title: picker.titleKey,
      icon: picker.icon,
      items: picker.items,
      currentValue: picker.read(settings),
      itemBuilder: (duration) => '$duration ${'min'.tr}',
      onSelected: (value) async {
        actions.saveSettingsOptimistic(mutate: (s) => picker.write(s, value));
      },
    );
  }
}
