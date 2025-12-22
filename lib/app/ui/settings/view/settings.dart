import 'package:flag_secure/flag_secure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/app/controller/isar_controller.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/settings/widgets/settings_card.dart';
import 'package:zest/main.dart';
import 'package:zest/theme/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zest/app/ui/widgets/header_compact.dart';

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

  void _updateLanguage(Locale locale) {
    settings.language = '$locale';
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.updateLocale(locale);
    Get.back();
  }

  void _updateDefaultScreen(String defaultScreen) {
    settings.defaultScreen = defaultScreen;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.back();
    setState(() {});
  }

  Future<void> _urlLauncher(String uri) async {
    final Uri url = Uri.parse(uri);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  String _firstDayOfWeek(String newValue) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days.firstWhere((day) => newValue == day.tr, orElse: () => 'monday');
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text(
        'settings'.tr,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          _buildAppearanceCard(context),
          _buildDateTimeCard(context),
          _buildPrivacySecurityCard(context),
          _buildAppPreferencesCard(context),
          _buildDataManagementCard(context),
          _buildCommunityCard(context),
          _buildAboutAppCard(context),
        ],
      ),
    ),
  );

  Widget _buildAppearanceCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.brush_1),
    text: 'appearance'.tr,
    onPressed: () => _showAppearanceBottomSheet(context),
  );

  void _showAppearanceBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildBottomSheetHeaderCompact(context, 'appearance'.tr),
              _buildThemeSettingCard(context, setState),
              _buildAmoledThemeSettingCard(context, setState),
              _buildMaterialColorSettingCard(context, setState),
              _buildIsImagesSettingCard(context, setState),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildThemeSettingCard(BuildContext context, StateSetter setState) =>
      SettingCard(
        elevation: 4,
        icon: const Icon(IconsaxPlusLinear.moon),
        text: 'theme'.tr,
        dropdown: true,
        dropdownName: settings.theme?.tr,
        dropdownList: <String>['system'.tr, 'dark'.tr, 'light'.tr],
        dropdownChange: (String? newValue) =>
            _updateTheme(newValue, context, setState),
      );

  void _updateTheme(
    String? newValue,
    BuildContext context,
    StateSetter setState,
  ) {
    ThemeMode themeMode = newValue?.tr == 'system'.tr
        ? ThemeMode.system
        : newValue?.tr == 'dark'.tr
        ? ThemeMode.dark
        : ThemeMode.light;
    String theme = newValue?.tr == 'system'.tr
        ? 'system'
        : newValue?.tr == 'dark'.tr
        ? 'dark'
        : 'light';
    themeController.saveTheme(theme);
    themeController.changeThemeMode(themeMode);
  }

  Widget _buildAmoledThemeSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.mobile),
    text: 'amoledTheme'.tr,
    switcher: true,
    value: settings.amoledTheme,
    onChange: (value) {
      themeController.saveOledTheme(value);
      MyApp.updateAppState(context, newAmoledTheme: value);
    },
  );

  Widget _buildMaterialColorSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.colorfilter),
    text: 'materialColor'.tr,
    switcher: true,
    value: settings.materialColor,
    onChange: (value) {
      themeController.saveMaterialTheme(value);
      MyApp.updateAppState(context, newMaterialColor: value);
    },
  );

  Widget _buildIsImagesSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.image),
    text: 'isImages'.tr,
    switcher: true,
    value: settings.isImage,
    onChange: (value) {
      isar.writeTxnSync(() {
        settings.isImage = value;
        isar.settings.putSync(settings);
      });
      isImage.value = value;
      setState(() {});
    },
  );

  Widget _buildDateTimeCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.calendar_2),
    text: 'dateTime'.tr,
    onPressed: () => _showDateTimeBottomSheet(context),
  );

  void _showDateTimeBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildBottomSheetHeaderCompact(context, 'dateTime'.tr),
              _buildTimeFormatSettingCard(context, setState),
              _buildFirstDayOfWeekSettingCard(context, setState),
              _buildSnoozeDropdownCard(context, setState),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildTimeFormatSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.clock_1),
    text: 'timeformat'.tr,
    dropdown: true,
    dropdownName: settings.timeformat.tr,
    dropdownList: <String>['12'.tr, '24'.tr],
    dropdownChange: (String? newValue) =>
        _updateTimeFormat(newValue, context, setState),
  );

  void _updateTimeFormat(
    String? newValue,
    BuildContext context,
    StateSetter setState,
  ) {
    final String format = newValue == '12'.tr ? '12' : '24';
    isar.writeTxnSync(() {
      settings.timeformat = format;
      isar.settings.putSync(settings);
    });
    timeformat.value = format;
    setState(() {});
    todoController.todos.refresh();
  }

  Widget _buildFirstDayOfWeekSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.calendar_edit),
    text: 'firstDayOfWeek'.tr,
    dropdown: true,
    dropdownName: firstDay.value.tr,
    dropdownList: <String>[
      'monday'.tr,
      'tuesday'.tr,
      'wednesday'.tr,
      'thursday'.tr,
      'friday'.tr,
      'saturday'.tr,
      'sunday'.tr,
    ],
    dropdownChange: (String? newValue) =>
        _updateFirstDayOfWeek(newValue, context, setState),
  );

  void _updateFirstDayOfWeek(
    String? newValue,
    BuildContext context,
    StateSetter setState,
  ) {
    if (newValue == null) return;
    String selectedDay = _firstDayOfWeek(newValue);
    isar.writeTxnSync(() {
      settings.firstDay = selectedDay;
      isar.settings.putSync(settings);
    });
    firstDay.value = selectedDay;
    setState(() {});
  }

  Widget _buildSnoozeDropdownCard(BuildContext context, StateSetter setState) =>
      SettingCard(
        elevation: 4,
        icon: const Icon(IconsaxPlusLinear.timer_1),
        text: 'snoozeDuration'.tr,
        dropdown: true,
        dropdownName: '${settings.snoozeDuration} ${'min'.tr}',
        dropdownList: <String>[
          '5 ${'min'.tr}',
          '10 ${'min'.tr}',
          '15 ${'min'.tr}',
          '20 ${'min'.tr}',
          '30 ${'min'.tr}',
          '45 ${'min'.tr}',
          '60 ${'min'.tr}',
        ],
        dropdownChange: (String? newValue) {
          if (newValue == null) return;
          final duration = int.tryParse(newValue.split(' ')[0]) ?? 10;
          isar.writeTxnSync(() {
            settings.snoozeDuration = duration;
            isar.settings.putSync(settings);
          });
          setState(() {});
        },
      );

  Widget _buildPrivacySecurityCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.security),
    text: 'privacySecurity'.tr,
    onPressed: () => _showPrivacySecurityBottomSheet(context),
  );

  void _showPrivacySecurityBottomSheet(BuildContext context) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildBottomSheetHeaderCompact(context, 'privacySecurity'.tr),
                  _buildScreenPrivacySettingCard(context, setState),
                  const Gap(10),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildScreenPrivacySettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.security_safe),
    text: 'screenPrivacy'.tr,
    switcher: true,
    value: settings.screenPrivacy ?? false,
    onChange: (value) async {
      try {
        if (value == true) {
          await FlagSecure.set();
        } else {
          await FlagSecure.unset();
        }
        isar.writeTxnSync(() {
          settings.screenPrivacy = value;
          isar.settings.putSync(settings);
        });
        setState(() {});
      } on PlatformException {
        // ignore
      }
    },
  );

  Widget _buildAppPreferencesCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.mobile),
    text: 'appPreferences'.tr,
    onPressed: () => _showAppPreferencesBottomSheet(context),
  );

  void _showAppPreferencesBottomSheet(BuildContext context) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildBottomSheetHeaderCompact(context, 'appPreferences'.tr),
                  _buildDefaultScreenSettingCard(context, setState),
                  _buildLanguageSettingCard(context, setState),
                  const Gap(10),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildDefaultScreenSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.mobile),
    text: 'defaultScreen'.tr,
    dropdown: true,
    dropdownName: settings.defaultScreen.isNotEmpty
        ? settings.defaultScreen.tr
        : allScreens[0].tr,
    dropdownList: allScreens.map((screen) => screen.tr).toList(),
    dropdownChange: (String? newValue) {
      if (newValue == null) return;
      final selectedScreen = allScreens.firstWhere(
        (screen) => screen.tr == newValue,
        orElse: () => allScreens[0],
      );
      _updateDefaultScreen(selectedScreen);
      setState(() {});
    },
  );

  Widget _buildLanguageSettingCard(
    BuildContext context,
    StateSetter setState,
  ) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.language_square),
    text: 'language'.tr,
    dropdown: true,
    dropdownName: appLanguages.firstWhere(
      (element) => (element['locale'] == locale),
      orElse: () => {'name': ''},
    )['name'],
    dropdownList: appLanguages.map((lang) => lang['name'] as String).toList(),
    dropdownChange: (String? newValue) {
      if (newValue == null) return;
      final selectedLang = appLanguages.firstWhere(
        (lang) => lang['name'] == newValue,
      );
      MyApp.updateAppState(context, newLocale: selectedLang['locale']);
      _updateLanguage(selectedLang['locale']);
      setState(() {});
    },
  );

  Widget _buildDataManagementCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.cloud),
    text: 'dataManagement'.tr,
    onPressed: () => _showDataManagementBottomSheet(context),
  );

  void _showDataManagementBottomSheet(BuildContext context) =>
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildBottomSheetHeaderCompact(context, 'dataManagement'.tr),
                  _buildBackupSettingCard(context),
                  _buildRestoreSettingCard(context),
                  _buildDeleteAllDBSettingCard(context),
                  const Gap(10),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildBackupSettingCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.cloud_plus),
    text: 'backup'.tr,
    onPressed: isarController.createBackUp,
  );

  Widget _buildRestoreSettingCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.cloud_add),
    text: 'restore'.tr,
    onPressed: isarController.restoreDB,
  );

  Widget _buildDeleteAllDBSettingCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.cloud_minus),
    text: 'deleteAllBD'.tr,
    onPressed: () => _showDeleteAllDBConfirmationDialog(context),
  );

  void _showDeleteAllDBConfirmationDialog(BuildContext context) => showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Text('deleteAllBDTitle'.tr, style: context.textTheme.titleLarge),
      content: Text(
        'deleteAllBDQuery'.tr,
        style: context.textTheme.titleMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'cancel'.tr,
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.blueAccent,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            isar.writeTxnSync(() {
              isar.todos.clearSync();
              isar.tasks.clearSync();
              todoController.tasks.clear();
              todoController.todos.clear();
            });
            EasyLoading.showSuccess('deleteAll'.tr);
            Get.back();
          },
          child: Text(
            'delete'.tr,
            style: context.textTheme.titleMedium?.copyWith(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  Widget _buildCommunityCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.link_square),
    text: 'groups'.tr,
    onPressed: () => _showCommunityBottomSheet(context),
  );

  void _showCommunityBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildBottomSheetHeaderCompact(context, 'groups'.tr),
              SettingCard(
                elevation: 4,
                icon: const Icon(LineAwesomeIcons.discord),
                text: 'Discord',
                onPressed: () => _urlLauncher('https://discord.gg/JMMa9aHh8f'),
              ),
              SettingCard(
                elevation: 4,
                icon: const Icon(LineAwesomeIcons.telegram),
                text: 'Telegram',
                onPressed: () => _urlLauncher('https://t.me/darkmoonightX'),
              ),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildAboutAppCard(BuildContext context) => SettingCard(
    icon: const Icon(IconsaxPlusLinear.info_circle),
    text: 'aboutApp'.tr,
    onPressed: () => _showAboutAppBottomSheet(context),
  );

  void _showAboutAppBottomSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    builder: (BuildContext context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: StatefulBuilder(
        builder: (BuildContext context, setState) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildBottomSheetHeaderCompact(context, 'aboutApp'.tr),
              _buildLicenseCard(context),
              _buildVersionCard(context),
              _buildGitHubCard(context),
              const Gap(10),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildLicenseCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.document),
    text: 'license'.tr,
    onPressed: () {
      Get.to(
        () => LicensePage(
          applicationIcon: Container(
            width: 100,
            height: 100,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Image(image: AssetImage('assets/icons/icon.png')),
          ),
          applicationName: 'Zest',
          applicationVersion: appVersion,
        ),
        transition: Transition.downToUp,
      );
    },
  );

  Widget _buildVersionCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(IconsaxPlusLinear.hierarchy_square_2),
    text: 'version'.tr,
    info: true,
    textInfo: '$appVersion',
  );

  Widget _buildGitHubCard(BuildContext context) => SettingCard(
    elevation: 4,
    icon: const Icon(LineAwesomeIcons.github),
    text: '${'project'.tr} GitHub',
    onPressed: () => _urlLauncher('https://github.com/darkmoonight/Zest'),
  );
}
