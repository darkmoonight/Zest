import 'package:flag_secure/flag_secure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/app/controller/isar_controller.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/settings/widgets/settings_section.dart';
import 'package:zest/app/ui/settings/widgets/settings_tile.dart';
import 'package:zest/app/ui/widgets/confirmation_dialog.dart';
import 'package:zest/app/ui/settings/widgets/selection_dialog.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/show_snack_bar.dart';
import 'package:zest/main.dart';
import 'package:zest/app/controller/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final todoController = Get.put(TodoController());
  final isarController = Get.put(IsarController());
  final themeController = Get.put(ThemeController());
  String? appVersion;

  @override
  void initState() {
    super.initState();
    _infoVersion();
  }

  Future<void> _infoVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() => appVersion = packageInfo.version);
  }

  Future<void> _updateLanguage(Locale locale) async {
    settings.language = '$locale';
    await isar.writeTxn(() => isar.settings.put(settings));
    Get.updateLocale(locale);
    setState(() {});
  }

  Future<void> _updateDefaultScreen(String defaultScreen) async {
    settings.defaultScreen = defaultScreen;
    await isar.writeTxn(() => isar.settings.put(settings));
    setState(() {});
  }

  Future<void> _urlLauncher(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? padding : padding * 2,
                vertical: padding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildAppearanceSection(context),
                  SizedBox(height: padding * 1.5),
                  _buildDateTimeSection(context),
                  SizedBox(height: padding * 1.5),
                  _buildPrivacySecuritySection(context),
                  SizedBox(height: padding * 1.5),
                  _buildAppPreferencesSection(context),
                  SizedBox(height: padding * 1.5),
                  _buildDataManagementSection(context),
                  SizedBox(height: padding * 1.5),
                  _buildCommunitySection(context),
                  SizedBox(height: padding * 1.5),
                  _buildAboutSection(context),
                  SizedBox(height: padding * 2),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTIONS ====================

  Widget _buildAppearanceSection(BuildContext context) {
    return SettingsSection(
      title: 'appearance',
      icon: IconsaxPlusBold.brush_1,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.moon),
          title: 'theme',
          value: settings.theme?.tr ?? 'system'.tr,
          onTap: () => _showThemeDialog(context),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.mobile),
          title: 'amoledTheme',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.amoledTheme,
              onChanged: (value) async {
                await themeController.saveOledTheme(value);
                if (!mounted) return;
                MyApp.updateAppState(this.context, newAmoledTheme: value);
                setState(() {});
              },
            ),
          ),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.colorfilter),
          title: 'materialColor',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.materialColor,
              onChanged: (value) async {
                await themeController.saveMaterialTheme(value);
                if (!mounted) return;
                MyApp.updateAppState(this.context, newMaterialColor: value);
                setState(() {});
              },
            ),
          ),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.image),
          title: 'isImages',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.isImage ?? false,
              onChanged: (value) async {
                await isar.writeTxn(() async {
                  settings.isImage = value;
                  await isar.settings.put(settings);
                });
                isImage.value = value;
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(BuildContext context) {
    return SettingsSection(
      title: 'dateTime',
      icon: IconsaxPlusBold.calendar_2,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.clock_1),
          title: 'timeformat',
          value: settings.timeformat.tr,
          onTap: () => _showTimeFormatDialog(context),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.calendar_edit),
          title: 'firstDayOfWeek',
          value: firstDay.value.tr,
          onTap: () => _showFirstDayOfWeekDialog(context),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.timer_1),
          title: 'snoozeDuration',
          value: '${settings.snoozeDuration} ${'min'.tr}',
          onTap: () => _showSnoozeDurationDialog(context),
        ),
      ],
    );
  }

  Widget _buildPrivacySecuritySection(BuildContext context) {
    return SettingsSection(
      title: 'privacySecurity',
      icon: IconsaxPlusBold.security,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.security_safe),
          title: 'screenPrivacy',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.screenPrivacy ?? false,
              onChanged: (value) async {
                try {
                  if (value) {
                    await FlagSecure.set();
                  } else {
                    await FlagSecure.unset();
                  }
                  await isar.writeTxn(() async {
                    settings.screenPrivacy = value;
                    await isar.settings.put(settings);
                  });
                  setState(() {});
                } on PlatformException {
                  // ignore
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection(BuildContext context) {
    return SettingsSection(
      title: 'appPreferences',
      icon: IconsaxPlusBold.mobile,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.monitor_mobbile),
          title: 'defaultScreen',
          value: settings.defaultScreen.isNotEmpty
              ? settings.defaultScreen.tr
              : allScreens[0].tr,
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
      ],
    );
  }

  Widget _buildDataManagementSection(BuildContext context) {
    return SettingsSection(
      title: 'dataManagement',
      icon: IconsaxPlusBold.cloud,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.cloud_plus),
          title: 'backup',
          onTap: isarController.createBackup,
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.cloud_add),
          title: 'restore',
          onTap: isarController.restoreDB,
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.refresh_circle),
          title: 'autoBackup',
          trailing: Transform.scale(
            scale: 0.8,
            child: Switch(
              value: settings.autoBackupEnabled,
              onChanged: (value) async {
                await isar.writeTxn(() async {
                  settings.autoBackupEnabled = value;
                  await isar.settings.put(settings);
                });
                setState(() {});
              },
            ),
          ),
        ),
        if (settings.autoBackupEnabled) ...[
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.folder),
            title: 'autoBackupPath',
            value: _getBackupPathDisplay(),
            onTap: () => _selectAutoBackupPath(context),
          ),
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.calendar_tick),
            title: 'autoBackupFrequency',
            value: _getFrequencyText(settings.autoBackupFrequency),
            onTap: () => _showAutoBackupFrequencyDialog(context),
          ),
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.archive),
            title: 'maxAutoBackups',
            value: '${settings.maxAutoBackups}',
            onTap: () => _showMaxBackupsDialog(context),
          ),
        ],
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.cloud_minus),
          title: 'deleteAllBD',
          onTap: () => _showDeleteAllDBDialog(context),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(BuildContext context) {
    return SettingsSection(
      title: 'groups',
      icon: IconsaxPlusBold.people,
      children: [
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.discord),
          title: 'Discord',
          onTap: () => _urlLauncher('https://discord.gg/JMMa9aHh8f'),
        ),
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.telegram),
          title: 'Telegram',
          onTap: () => _urlLauncher('https://t.me/darkmoonightX'),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return SettingsSection(
      title: 'aboutApp',
      icon: IconsaxPlusBold.info_circle,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.document_text),
          title: 'license',
          onTap: () {
            NavigationHelper.slideUp(
              LicensePage(
                applicationIcon: Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: const Image(
                    image: AssetImage('assets/icons/icon.png'),
                  ),
                ),
                applicationName: 'Zest',
                applicationVersion: appVersion,
              ),
            );
          },
        ),
        SettingsTile(
          leading: const Icon(LineAwesomeIcons.github),
          title: '${'project'.tr} GitHub',
          onTap: () => _urlLauncher('https://github.com/darkmoonight/Zest'),
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.code_circle),
          title: 'version',
          value: appVersion ?? '...',
        ),
      ],
    );
  }

  // ==================== DIALOGS ====================

  void _showThemeDialog(BuildContext context) {
    showSelectionDialog<String>(
      context: context,
      title: 'theme'.tr,
      icon: IconsaxPlusBold.moon,
      items: ['system', 'dark', 'light'],
      currentValue: settings.theme ?? 'system',
      itemBuilder: (theme) => theme.tr,
      onSelected: (value) async {
        ThemeMode mode = value == 'system'
            ? ThemeMode.system
            : value == 'dark'
            ? ThemeMode.dark
            : ThemeMode.light;
        await themeController.saveTheme(value);
        themeController.changeThemeMode(mode);
        setState(() {});
      },
    );
  }

  void _showTimeFormatDialog(BuildContext context) {
    showSelectionDialog<String>(
      context: context,
      title: 'timeformat'.tr,
      icon: IconsaxPlusBold.clock,
      items: ['12', '24'],
      currentValue: settings.timeformat,
      itemBuilder: (format) => format.tr,
      onSelected: (value) async {
        await isar.writeTxn(() async {
          settings.timeformat = value;
          await isar.settings.put(settings);
        });
        timeformat.value = value;
        todoController.todos.refresh();
        setState(() {});
      },
    );
  }

  void _showFirstDayOfWeekDialog(BuildContext context) {
    showSelectionDialog<String>(
      context: context,
      title: 'firstDayOfWeek'.tr,
      icon: IconsaxPlusBold.calendar,
      items: [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ],
      currentValue: firstDay.value,
      itemBuilder: (day) => day.tr,
      onSelected: (value) async {
        await isar.writeTxn(() async {
          settings.firstDay = value;
          await isar.settings.put(settings);
        });
        firstDay.value = value;
        setState(() {});
      },
    );
  }

  void _showSnoozeDurationDialog(BuildContext context) {
    showSelectionDialog<int>(
      context: context,
      title: 'snoozeDuration'.tr,
      icon: IconsaxPlusBold.timer_1,
      items: [5, 10, 15, 20, 30, 45, 60],
      currentValue: settings.snoozeDuration,
      itemBuilder: (duration) => '$duration ${'min'.tr}',
      onSelected: (value) async {
        await isar.writeTxn(() async {
          settings.snoozeDuration = value;
          await isar.settings.put(settings);
        });
        setState(() {});
      },
    );
  }

  void _showDefaultScreenDialog(BuildContext context) {
    showSelectionDialog<String>(
      context: context,
      title: 'defaultScreen'.tr,
      icon: IconsaxPlusBold.monitor_mobbile,
      items: allScreens,
      currentValue: settings.defaultScreen.isNotEmpty
          ? settings.defaultScreen
          : allScreens[0],
      itemBuilder: (screen) => screen.tr,
      onSelected: (value) {
        _updateDefaultScreen(value);
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showSelectionDialog<Map<String, dynamic>>(
      context: context,
      title: 'language'.tr,
      icon: IconsaxPlusBold.language_square,
      items: appLanguages,
      currentValue: appLanguages.firstWhere(
        (element) =>
            (element['locale'] as Locale).languageCode == locale.languageCode,
        orElse: () => <String, dynamic>{
          'name': 'English',
          'locale': const Locale('en', 'US'),
        },
      ),
      itemBuilder: (lang) => lang['name'] as String,
      onSelected: (value) {
        MyApp.updateAppState(context, newLocale: value['locale']);
        _updateLanguage(value['locale']);
      },
      enableSearch: true,
    );
  }

  void _showDeleteAllDBDialog(BuildContext context) {
    showConfirmationDialog(
      context: context,
      title: 'deleteAllBDTitle',
      message: 'deleteAllBDQuery',
      icon: IconsaxPlusBold.trash,
      isDestructive: true,
      confirmText: 'delete',
      onConfirm: () async {
        await isar.writeTxn(() async {
          await isar.todos.clear();
          await isar.tasks.clear();
          todoController.tasks.clear();
          todoController.todos.clear();
        });
        showSnackBar('deleteAll'.tr);
      },
    );
  }

  // ==================== HELPERS ====================

  String _getBackupPathDisplay() {
    final path = settings.autoBackupPath;

    if (path == null || path.isEmpty) {
      return 'defaultPath'.tr;
    }

    final decodedPath = Uri.decodeComponent(
      path,
    ).replaceAll('%3A', ':').replaceAll('%2F', '/');

    if (decodedPath.startsWith('content://')) {
      return 'customPath'.tr;
    }

    final parts = decodedPath.split('/').where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.last : 'customPath'.tr;
  }

  Future<void> _selectAutoBackupPath(BuildContext context) async {
    try {
      final path = await isarController.pickAutoBackupDirectory();
      if (path == null) return;

      await isar.writeTxn(() async {
        settings.autoBackupPath = path;
        await isar.settings.put(settings);
      });

      if (!mounted) return;
      setState(() {});
      showSnackBar('autoBackupPathSet'.tr);
    } catch (e) {
      debugPrint('Error selecting auto backup path: $e');
      if (!mounted) return;
      showSnackBar('error'.tr, isError: true);
    }
  }

  String _getFrequencyText(AutoBackupFrequency frequency) =>
      switch (frequency) {
        AutoBackupFrequency.daily => 'daily'.tr,
        AutoBackupFrequency.weekly => 'weekly'.tr,
        AutoBackupFrequency.monthly => 'monthly'.tr,
      };

  void _showAutoBackupFrequencyDialog(BuildContext context) {
    showSelectionDialog<AutoBackupFrequency>(
      context: context,
      title: 'autoBackupFrequency'.tr,
      icon: IconsaxPlusBold.calendar_tick,
      items: AutoBackupFrequency.values,
      currentValue: settings.autoBackupFrequency,
      itemBuilder: (frequency) => _getFrequencyText(frequency),
      onSelected: (value) async {
        await isar.writeTxn(() async {
          settings.autoBackupFrequency = value;
          await isar.settings.put(settings);
        });
        setState(() {});
      },
    );
  }

  void _showMaxBackupsDialog(BuildContext context) {
    showSelectionDialog<int>(
      context: context,
      title: 'maxAutoBackups'.tr,
      icon: IconsaxPlusBold.archive,
      items: [3, 5, 7, 10, 15, 20, 30],
      currentValue: settings.maxAutoBackups,
      itemBuilder: (count) => '$count',
      onSelected: (value) async {
        await isar.writeTxn(() async {
          settings.maxAutoBackups = value;
          await isar.settings.put(settings);
        });
        setState(() {});
      },
    );
  }
}
