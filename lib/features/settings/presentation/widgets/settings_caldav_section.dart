import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/caldav/caldav_account.dart';
import 'package:zest/core/caldav/caldav_remote.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/settings/presentation/widgets/selection_dialog.dart';
import 'package:zest/features/settings/presentation/widgets/settings_list_dialog_shell.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/locale_utils.dart';
import 'package:zest/i18n/tr.dart';

/// CalDAV account, calendar picker, and manual sync controls.
class SettingsCalDavSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsCalDavSection].
  const SettingsCalDavSection({super.key});

  @override
  ConsumerState<SettingsCalDavSection> createState() =>
      _SettingsCalDavSectionState();
}

class _SettingsCalDavSectionState
    extends SettingsSectionConsumerState<SettingsCalDavSection> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final timeformat = ref.watch(
      appSettingsProvider.select((s) => s.timeformat),
    );

    return SettingsSection(
      title: 'caldavSync',
      icon: IconsaxPlusBold.cloud,
      children: [
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.cloud_change),
          title: 'caldavEnabled',
          value: settings.caldavEnabled,
          onChanged: _busy
              ? (_) {}
              : (value) {
                  actions.saveSettingsOptimistic(
                    mutate: (s) => s.caldavEnabled = value,
                    afterSave: value
                        ? () => ref.read(calDavSyncServiceProvider).syncNow()
                        : null,
                  );
                },
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.user),
          title: 'caldavAccount',
          subtitleText: settings.hasCalDavAccount
              ? settings.caldavUsername
              : 'caldavNotConfigured'.tr,
          onTap: _busy ? null : _editAccount,
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.calendar),
          title: 'caldavCalendar',
          value: settings.caldavCalendarName?.trim().isNotEmpty == true
              ? settings.caldavCalendarName
              : 'caldavNotConfigured'.tr,
          onTap: _busy ? null : _pickCalendar,
        ),
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.shield),
          title: 'caldavAllowInsecure',
          value: settings.caldavAllowInsecure,
          onChanged: _busy
              ? (_) {}
              : (value) {
                  actions.saveSettingsOptimistic(
                    mutate: (s) => s.caldavAllowInsecure = value,
                  );
                },
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.refresh),
          title: 'caldavSyncNow',
          subtitleText: _statusText(settings, timeformat),
          onTap: _busy ? null : _syncNow,
        ),
      ],
    );
  }

  String _statusText(Settings settings, String timeformat) {
    final error = settings.caldavLastError;
    if (error != null && error.isNotEmpty) {
      final conflictMatch = RegExp(
        r'Server copy kept for (\d+) conflicting item',
      ).firstMatch(error);
      if (conflictMatch != null) {
        return 'caldavConflictServerWins'.trFormat({
          'count': conflictMatch.group(1)!,
        });
      }
      return 'caldavSyncFailed'.trFormat({'error': error});
    }
    final last = settings.caldavLastSyncTime;
    if (last == null) return 'caldavNeverSynced'.tr;
    final formatted = DateTimeFormatHelper.formatDateTime(
      last,
      timeformat: timeformat,
      languageCode: languageCodeFromSettings(settings.language),
    );
    return 'caldavLastSync'.trFormat({'time': formatted});
  }

  Future<void> _withBusy(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _editAccount() async {
    final settings = ref.read(liveSettingsProvider);
    final store = ref.read(calDavCredentialsStoreProvider);
    final savedPassword = await store.readPassword() ?? '';
    if (!mounted) return;
    await NavigationHelper.showAppDialog<void>(
      context: context,
      child: _CalDavAccountDialog(
        initialUrl: settings.caldavUrl ?? '',
        initialUsername: settings.caldavUsername ?? '',
        initialPassword: savedPassword,
        allowInsecure: settings.caldavAllowInsecure,
        onSave: (url, username, password, calendars) async {
          await store.savePassword(password);
          final href = settings.caldavCalendarHref;
          final stillValid =
              href != null &&
              calendars.any((calendar) => calendar.href == href);
          actions.saveSettingsOptimistic(
            mutate: (s) {
              s.caldavUrl = url;
              s.caldavUsername = username;
              if (!stillValid) {
                s.setCalDavCalendar(calendars.isEmpty ? null : calendars.first);
              }
            },
          );
        },
      ),
    );
  }

  Future<void> _pickCalendar() async {
    await _withBusy(() async {
      try {
        final calendars = await _discoverCalendars();
        if (!mounted) return;
        if (calendars.isEmpty) {
          showSnackBar('caldavNoCalendars'.tr, isError: true);
          return;
        }
        final currentHref = ref.read(liveSettingsProvider).caldavCalendarHref;
        await showSelectionDialog<CalDavCalendarInfo>(
          context: context,
          title: 'caldavCalendar'.tr,
          icon: IconsaxPlusBold.calendar,
          items: calendars,
          currentValue: selectCalDavCalendar(calendars, currentHref),
          itemBuilder: (calendar) => calendar.displayName,
          onSelected: (calendar) async {
            actions.saveSettingsOptimistic(
              mutate: (s) => s.setCalDavCalendar(calendar),
              afterSave: () => ref.read(calDavSyncServiceProvider).syncNow(),
            );
          },
        );
      } catch (e) {
        showSnackBar(
          'caldavConnectionFailed'.trFormat({'error': '$e'}),
          isError: true,
        );
      }
    });
  }

  Future<void> _syncNow() async {
    await _withBusy(() async {
      final result = await ref.read(calDavSyncServiceProvider).syncNow();
      if (result.skipped) {
        showSnackBar('caldavNotConfigured'.tr, isInfo: true);
        return;
      }
      if (result.success) {
        if (result.conflicts > 0) {
          showSnackBar(
            'caldavConflictServerWins'.trFormat({
              'count': '${result.conflicts}',
            }),
            isInfo: true,
          );
        } else {
          showSnackBar('caldavSyncSuccess'.tr);
        }
      } else {
        showSnackBar(
          'caldavSyncFailed'.trFormat({'error': result.error ?? ''}),
          isError: true,
        );
      }
    });
  }

  Future<List<CalDavCalendarInfo>> _discoverCalendars() async {
    final account = await _loadAccount();
    if (!account.isComplete) {
      throw StateError('caldavNotConfigured'.tr);
    }
    return discoverCalDavTodoCalendars(account);
  }

  Future<CalDavAccount> _loadAccount() async {
    final settings = ref.read(liveSettingsProvider);
    final password =
        await ref.read(calDavCredentialsStoreProvider).readPassword() ?? '';
    return CalDavAccount(
      url: settings.caldavUrl ?? '',
      username: settings.caldavUsername ?? '',
      password: password,
      allowInsecure: settings.caldavAllowInsecure,
    );
  }
}

/// Modal form for CalDAV server URL, username, and password.
class _CalDavAccountDialog extends StatefulWidget {
  const _CalDavAccountDialog({
    required this.initialUrl,
    required this.initialUsername,
    required this.initialPassword,
    required this.allowInsecure,
    required this.onSave,
  });

  final String initialUrl;
  final String initialUsername;
  final String initialPassword;
  final bool allowInsecure;
  final Future<void> Function(
    String url,
    String username,
    String password,
    List<CalDavCalendarInfo> calendars,
  )
  onSave;

  @override
  State<_CalDavAccountDialog> createState() => _CalDavAccountDialogState();
}

class _CalDavAccountDialogState extends State<_CalDavAccountDialog> {
  late final TextEditingController _url;
  late final TextEditingController _username;
  late final TextEditingController _password;
  bool _busy = false;
  bool _obscure = true;

  static const _fieldGap = SizedBox(height: AppConstants.spacingM);

  @override
  void initState() {
    super.initState();
    _url = TextEditingController(text: widget.initialUrl);
    _username = TextEditingController(text: widget.initialUsername);
    _password = TextEditingController(text: widget.initialPassword);
  }

  @override
  void dispose() {
    _url.dispose();
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  CalDavAccount get _account => CalDavAccount(
    url: _url.text,
    username: _username.text,
    password: _password.text,
    allowInsecure: widget.allowInsecure,
  );

  @override
  Widget build(BuildContext context) {
    return SettingsListDialogShell(
      shrinkWrapBody: true,
      header: SettingsListDialogHeader(
        title: 'caldavAccount'.tr,
        icon: IconsaxPlusBold.cloud,
      ),
      body: SettingsListDialogFormBody(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _url,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(labelText: 'caldavServerUrl'.tr),
            ),
            _fieldGap,
            TextField(
              controller: _username,
              autocorrect: false,
              decoration: InputDecoration(labelText: 'caldavUsername'.tr),
            ),
            _fieldGap,
            TextField(
              controller: _password,
              obscureText: _obscure,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: 'caldavPassword'.tr,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? IconsaxPlusLinear.eye
                        : IconsaxPlusLinear.eye_slash,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              'caldavInsecureHint'.tr,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      footer: SettingsListDialogCancelSaveFooter(
        enabled: !_busy,
        onSave: _save,
      ),
    );
  }

  Future<void> _save() async {
    if (!_account.isComplete) {
      showSnackBar('caldavNotConfigured'.tr, isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      final calendars = await discoverCalDavTodoCalendars(_account);
      await widget.onSave(
        _account.url.trim(),
        _account.username.trim(),
        _account.password,
        calendars,
      );
      if (!mounted) return;
      showSnackBar('caldavConnectionOk'.tr);
      NavigationHelper.back(context);
    } catch (e) {
      showSnackBar(
        'caldavConnectionFailed'.trFormat({'error': '$e'}),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
