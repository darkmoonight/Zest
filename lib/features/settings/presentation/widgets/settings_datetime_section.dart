import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/setting_enum_pickers.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/notifications/notification_settings_launcher.dart';
import 'package:zest/core/services/notification_plugin.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/features/settings/presentation/widgets/settings_selection.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Time format, week-start, snooze duration, and (Android) notification settings.
class SettingsDateTimeSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsDateTimeSection].
  const SettingsDateTimeSection({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<SettingsDateTimeSection> createState() =>
      _SettingsDateTimeSectionState();
}

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

    return SettingsSection(
      title: 'dateTime',
      icon: IconsaxPlusBold.calendar_2,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.clock_1),
          title: 'timeformat',
          value: timeformat.tr,
          onTap: () => showSettingsPicker(
            context: context,
            picker: settingTimeformatPicker,
            currentValue: timeformat,
            itemBuilder: (format) => format.tr,
            onSelected: actions.saveTimeFormat,
          ),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.calendar_edit),
          title: 'firstDayOfWeek',
          value: firstDay.tr,
          onTap: () => showSettingsPicker(
            context: context,
            picker: settingFirstDayPicker,
            currentValue: firstDay,
            itemBuilder: (day) => day.tr,
            onSelected: actions.saveFirstDayOfWeek,
          ),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.timer_1),
          title: 'snoozeDuration',
          value: '$snoozeDuration ${'min'.tr}',
          onTap: () => showSettingsPicker(
            context: context,
            picker: settingSnoozeDurationPicker,
            currentValue: snoozeDuration,
            itemBuilder: (duration) => '$duration ${'min'.tr}',
            onSelected: actions.saveSnoozeDuration,
          ),
        ),
        if (PlatformFeatures.isAndroid) ...[
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.notification),
            title: 'notificationChannels',
            subtitle: 'manageAppNotifications',
            onTap: _openAppNotificationSettings,
          ),
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.alarm),
            title: 'exactAlarms',
            subtitle: 'exactAlarmDeniedHint',
            onTap: _requestExactAlarmsPermission,
          ),
        ],
      ],
    );
  }

  Future<void> _openAppNotificationSettings() async {
    try {
      await NotificationSettingsLauncher.openAppSettings();
    } catch (e) {
      showSnackBar(
        'failedToOpenSettings'.trFormat({'error': '$e'}),
        isError: true,
      );
    }
  }

  Future<void> _requestExactAlarmsPermission() async {
    final plugin = NotificationPlugin.android;
    if (plugin == null) return;
    try {
      final allowed = await plugin.canScheduleExactNotifications();
      if (allowed == true) return;
      await plugin.requestExactAlarmsPermission();
      final after = await plugin.canScheduleExactNotifications();
      if (after != true) {
        showSnackBar('exactAlarmDeniedHint'.tr, isError: true);
      }
    } catch (_) {
      showSnackBar('exactAlarmDeniedHint'.tr, isError: true);
    }
  }
}
