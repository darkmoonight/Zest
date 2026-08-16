import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/setting_enum_pickers.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/constants/app_languages.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/device_calendar_sync_service.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/iterable_extensions.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/features/settings/presentation/widgets/selection_dialog.dart';
import 'package:zest/features/settings/presentation/widgets/settings_selection.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';
import 'package:zest/platform/platform_features.dart'
    if (dart.library.io) 'package:zest/platform/platform_features_mobile.dart';

/// Default screen, language, and statistics preferences.
class SettingsAppPreferencesSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsAppPreferencesSection].
  const SettingsAppPreferencesSection({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<SettingsAppPreferencesSection> createState() =>
      _SettingsAppPreferencesSectionState();
}

class _SettingsAppPreferencesSectionState
    extends SettingsSectionConsumerState<SettingsAppPreferencesSection> {
  String? _calendarLabel;
  String? _resolvedCalendarId;
  bool _resolvingCalendarLabel = false;
  ProviderSubscription<(bool, String?)>? _calendarLabelSub;

  @override
  void initState() {
    super.initState();
    _calendarLabelSub = ref.listenManual(
      settingsProvider.select(
        (s) => (s.deviceCalendarSyncEnabled, s.deviceCalendarId),
      ),
      (previous, next) {
        final (enabled, calendarId) = next;
        if (!enabled) {
          if (_calendarLabel != null || _resolvedCalendarId != null) {
            setState(() {
              _calendarLabel = null;
              _resolvedCalendarId = null;
            });
          }
          return;
        }
        _resolveCalendarLabel(calendarId);
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _calendarLabelSub?.close();
    super.dispose();
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final defaultScreen = ref.watch(
      settingsProvider.select((s) => s.defaultScreen),
    );
    final locale = ref.watch(appSettingsProvider.select((s) => s.locale));
    final showArchivedInStatistics = ref.watch(
      settingsProvider.select((s) => s.showArchivedInStatistics),
    );
    final deviceCalendarSyncEnabled = ref.watch(
      settingsProvider.select((s) => s.deviceCalendarSyncEnabled),
    );
    final deviceCalendarId = ref.watch(
      settingsProvider.select((s) => s.deviceCalendarId),
    );

    return SettingsSection(
      title: 'appPreferences',
      icon: IconsaxPlusBold.mobile,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.monitor_mobbile),
          title: 'defaultScreen',
          value: defaultScreen.isNotEmpty
              ? defaultScreen.tr
              : AppConstants.defaultScreen.tr,
          onTap: () => _showDefaultScreenDialog(context),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.language_square),
          title: 'language',
          value:
              appLanguages.firstWhere(
                    (element) => (element['locale'] == locale),
                    orElse: () => {'name': ''},
                  )['name']
                  as String,
          onTap: () => _showLanguageDialog(context),
        ),
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.chart_21),
          title: 'showArchivedInStatistics',
          value: showArchivedInStatistics,
          onChanged: (value) {
            actions.saveSettingsOptimistic(
              mutate: (s) => s.showArchivedInStatistics = value,
            );
          },
        ),
        if (PlatformFeatures.isAndroid) ...[
          SettingsSwitchTile(
            leading: const Icon(IconsaxPlusLinear.calendar_1),
            title: 'deviceCalendarSync',
            value: deviceCalendarSyncEnabled,
            onChanged: _onDeviceCalendarSyncChanged,
          ),
          if (deviceCalendarSyncEnabled)
            SettingsTile(
              leading: const Icon(IconsaxPlusLinear.calendar),
              title: 'deviceCalendar',
              value: _calendarDisplayLabel(deviceCalendarId),
              onTap: () => _showDeviceCalendarDialog(context),
            ),
        ],
      ],
    );
  }

  String _calendarDisplayLabel(String? calendarId) {
    if (calendarId == null || calendarId.isEmpty) {
      return 'deviceCalendarDefault'.tr;
    }
    if (_calendarLabel != null && _resolvedCalendarId == calendarId) {
      return _calendarLabel!;
    }
    return '';
  }

  Future<void> _resolveCalendarLabel(String? calendarId) async {
    if (calendarId == null || calendarId.isEmpty) {
      if (_calendarLabel != null || _resolvedCalendarId != null) {
        setState(() {
          _calendarLabel = null;
          _resolvedCalendarId = null;
        });
      }
      return;
    }
    if (_resolvedCalendarId == calendarId && _calendarLabel != null) return;
    if (_resolvingCalendarLabel) return;

    _resolvingCalendarLabel = true;
    try {
      final calendars = await ref
          .read(deviceCalendarSyncServiceProvider)
          .listWritableCalendars();
      if (!mounted) return;

      final matched = calendars.firstWhereOrNull((c) => c.id == calendarId);
      setState(() {
        _resolvedCalendarId = calendarId;
        _calendarLabel = matched == null
            ? null
            : _writableCalendarLabel(matched);
      });
    } finally {
      _resolvingCalendarLabel = false;
    }
  }

  String _writableCalendarLabel(Calendar calendar) {
    final account = calendar.accountName?.trim();
    if (account != null &&
        account.isNotEmpty &&
        account.toLowerCase() != calendar.name.toLowerCase()) {
      return '${calendar.name} ($account)';
    }
    if (DeviceCalendarSyncService.isLocalCalendar(calendar)) {
      return '${calendar.name} (${'deviceCalendarLocal'.tr})';
    }
    return calendar.name;
  }

  Future<void> _onDeviceCalendarSyncChanged(bool enabled) async {
    if (!enabled) {
      final sync = ref.read(deviceCalendarSyncServiceProvider);
      await sync.removeAllSynced();
      if (!mounted) return;
      actions.saveSettingsOptimistic(
        mutate: (s) {
          s.deviceCalendarSyncEnabled = false;
        },
      );
      return;
    }

    final sync = ref.read(deviceCalendarSyncServiceProvider);
    final status = await sync.requestPermission();
    // Full access is required for update/delete and calendar listing.
    if (status != CalendarPermissionStatus.granted) {
      showSnackBar('deviceCalendarPermissionDenied'.tr, isError: true);
      return;
    }

    actions.saveSettingsOptimistic(
      mutate: (s) {
        s.deviceCalendarSyncEnabled = true;
        // Re-resolve so Google calendars are preferred when available.
        s.deviceCalendarId = null;
      },
    );
    final calendarId = await sync.ensureWritableCalendarId();
    await sync.backfillAllEligible();
    if (!mounted) return;
    await _resolveCalendarLabel(calendarId);
  }

  Future<void> _showDeviceCalendarDialog(BuildContext context) async {
    final sync = ref.read(deviceCalendarSyncServiceProvider);
    final calendars = await sync.listWritableCalendars();
    if (!context.mounted) return;

    final currentId = ref.read(settingsProvider).deviceCalendarId;
    final items = <String?>[null, ...calendars.map((c) => c.id)];
    final labels = <String?, String>{
      null: 'deviceCalendarDefault'.tr,
      for (final calendar in calendars)
        calendar.id: _writableCalendarLabel(calendar),
    };

    await showSelectionDialog<String?>(
      context: context,
      title: 'deviceCalendar'.tr,
      icon: IconsaxPlusBold.calendar,
      items: items,
      currentValue: currentId,
      itemBuilder: (id) => labels[id] ?? id ?? 'deviceCalendarDefault'.tr,
      onSelected: (id) async {
        setState(() {
          _resolvedCalendarId = id;
          _calendarLabel = id == null ? null : labels[id];
        });
        final previousId = ref.read(settingsProvider).deviceCalendarId;
        actions.saveSettingsOptimistic(mutate: (s) => s.deviceCalendarId = id);
        if (previousId != id) {
          await sync.recreateAllSyncedEvents();
        }
      },
    );
  }

  /// Show default screen dialog.
  void _showDefaultScreenDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final picker = settingDefaultScreenPicker;
    showSettingsSelection<String>(
      context: context,
      title: picker.titleKey,
      icon: IconsaxPlusBold.monitor_mobbile,
      items: picker.items,
      currentValue: picker.read(settings),
      itemBuilder: (screen) => screen.tr,
      onSelected: actions.updateDefaultScreen,
    );
  }

  /// Show language dialog.
  void _showLanguageDialog(BuildContext context) {
    final appSettings = ref.read(appSettingsProvider);
    showSelectionDialog<Map<String, dynamic>>(
      context: context,
      title: 'language'.tr,
      icon: IconsaxPlusBold.language_square,
      items: appLanguages,
      currentValue: appLanguages.firstWhere(
        (element) =>
            (element['locale'] as Locale).languageCode ==
            appSettings.locale.languageCode,
        orElse: () => <String, dynamic>{
          'name': 'English',
          'locale': AppConstants.defaultLocale,
        },
      ),
      itemBuilder: (lang) => lang['name'] as String,
      onSelected: (value) {
        actions.updateLanguage(value['locale'] as Locale);
      },
      enableSearch: true,
    );
  }
}
