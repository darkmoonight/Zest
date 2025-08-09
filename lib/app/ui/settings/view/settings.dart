import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/app/controller/isar_contoller.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/settings/widgets/settings_card.dart';
import 'package:zest/main.dart';
import 'package:zest/theme/theme_controller.dart';
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
    setState(() {
      appVersion = packageInfo.version;
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
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
            _buildFunctionsCard(context),
            _buildDefaultScreenCard(context),
            _buildLanguageCard(context),
            _buildGroupsCard(context),
            _buildLicenseCard(context),
            _buildVersionCard(context),
            _buildGitHubCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceCard(BuildContext context) {
    return SettingCard(
      icon: const Icon(IconsaxPlusLinear.brush_1),
      text: 'appearance'.tr,
      onPressed: () {
        _showAppearanceBottomSheet(context);
      },
    );
  }

  void _showAppearanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        'appearance'.tr,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    _buildThemeSettingCard(context, setState),
                    _buildAmoledThemeSettingCard(context, setState),
                    _buildMaterialColorSettingCard(context, setState),
                    _buildIsImagesSettingCard(context, setState),
                    const Gap(10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildThemeSettingCard(BuildContext context, StateSetter setState) {
    return SettingCard(
      elevation: 4,
      icon: const Icon(IconsaxPlusLinear.moon),
      text: 'theme'.tr,
      dropdown: true,
      dropdownName: settings.theme?.tr,
      dropdownList: <String>['system'.tr, 'dark'.tr, 'light'.tr],
      dropdownChange: (String? newValue) {
        _updateTheme(newValue, context, setState);
      },
    );
  }

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
    setState(() {});
  }

  Widget _buildAmoledThemeSettingCard(
    BuildContext context,
    StateSetter setState,
  ) {
    return SettingCard(
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
  }

  Widget _buildMaterialColorSettingCard(
    BuildContext context,
    StateSetter setState,
  ) {
    return SettingCard(
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
  }

  Widget _buildIsImagesSettingCard(BuildContext context, StateSetter setState) {
    return SettingCard(
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
        MyApp.updateAppState(context, newIsImage: value);
        setState(() {});
      },
    );
  }

  Widget _buildFunctionsCard(BuildContext context) {
    return SettingCard(
      icon: const Icon(IconsaxPlusLinear.code_1),
      text: 'functions'.tr,
      onPressed: () {
        _showFunctionsBottomSheet(context);
      },
    );
  }

  void _showFunctionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        'functions'.tr,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    _buildTimeFormatSettingCard(context, setState),
                    _buildFirstDayOfWeekSettingCard(context, setState),
                    _buildBackupSettingCard(context),
                    _buildRestoreSettingCard(context),
                    _buildDeleteAllDBSettingCard(context),
                    const Gap(10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTimeFormatSettingCard(
    BuildContext context,
    StateSetter setState,
  ) {
    return SettingCard(
      elevation: 4,
      icon: const Icon(IconsaxPlusLinear.clock_1),
      text: 'timeformat'.tr,
      dropdown: true,
      dropdownName: settings.timeformat.tr,
      dropdownList: <String>['12'.tr, '24'.tr],
      dropdownChange: (String? newValue) {
        _updateTimeFormat(newValue, context, setState);
      },
    );
  }

  void _updateTimeFormat(
    String? newValue,
    BuildContext context,
    StateSetter setState,
  ) {
    isar.writeTxnSync(() {
      settings.timeformat = newValue == '12'.tr ? '12' : '24';
      isar.settings.putSync(settings);
    });
    MyApp.updateAppState(
      context,
      newTimeformat: newValue == '12'.tr ? '12' : '24',
    );
    setState(() {});
  }

  Widget _buildFirstDayOfWeekSettingCard(
    BuildContext context,
    StateSetter setState,
  ) {
    return SettingCard(
      elevation: 4,
      icon: const Icon(IconsaxPlusLinear.calendar_edit),
      text: 'firstDayOfWeek'.tr,
      dropdown: true,
      dropdownName: settings.firstDay.tr,
      dropdownList: <String>[
        'monday'.tr,
        'tuesday'.tr,
        'wednesday'.tr,
        'thursday'.tr,
        'friday'.tr,
        'saturday'.tr,
        'sunday'.tr,
      ],
      dropdownChange: (String? newValue) {
        _updateFirstDayOfWeek(newValue, context, setState);
      },
    );
  }

  void _updateFirstDayOfWeek(
    String? newValue,
    BuildContext context,
    StateSetter setState,
  ) {
    if (newValue == null) return;
    isar.writeTxnSync(() {
      const days = [
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
        'sunday',
      ];
      for (final day in days) {
        if (newValue == day.tr) {
          settings.firstDay = day;
          break;
        }
      }
      isar.settings.putSync(settings);
    });
    MyApp.updateAppState(context, newFirstDay: _firstDayOfWeek(newValue));
    setState(() {});
  }

  Widget _buildBackupSettingCard(BuildContext context) {
    return SettingCard(
      elevation: 4,
      icon: const Icon(IconsaxPlusLinear.cloud_plus),
      text: 'backup'.tr,
      onPressed: isarController.createBackUp,
    );
  }

  Widget _buildRestoreSettingCard(BuildContext context) {
    return SettingCard(
      elevation: 4,
      icon: const Icon(IconsaxPlusLinear.cloud_add),
      text: 'restore'.tr,
      onPressed: isarController.restoreDB,
    );
  }

  Widget _buildDeleteAllDBSettingCard(BuildContext context) {
    return SettingCard(
      elevation: 4,
      icon: const Icon(IconsaxPlusLinear.cloud_minus),
      text: 'deleteAllBD'.tr,
      onPressed: () {
        _showDeleteAllDBConfirmationDialog(context);
      },
    );
  }

  void _showDeleteAllDBConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'deleteAllBDTitle'.tr,
            style: context.textTheme.titleLarge,
          ),
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
                style: context.textTheme.titleMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDefaultScreenCard(BuildContext context) {
    return SettingCard(
      icon: const Icon(IconsaxPlusLinear.mobile),
      text: 'defaultScreen'.tr,
      info: true,
      infoSettings: true,
      textInfo: settings.defaultScreen.isNotEmpty
          ? settings.defaultScreen.tr
          : allScreens[0].tr,
      onPressed: () {
        _showDefaultScreenBottomSheet(context);
      },
    );
  }

  void _showDefaultScreenBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Text(
                      'defaultScreen'.tr,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: allScreens.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            allScreens[index].tr,
                            style: context.textTheme.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            _updateDefaultScreen(allScreens[index]);
                            Get.back();
                          },
                        ),
                      );
                    },
                  ),
                  const Gap(10),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    return SettingCard(
      icon: const Icon(IconsaxPlusLinear.language_square),
      text: 'language'.tr,
      info: true,
      infoSettings: true,
      textInfo: appLanguages.firstWhere(
        (element) => (element['locale'] == locale),
        orElse: () => {'name': ''},
      )['name'],
      onPressed: () {
        _showLanguageBottomSheet(context);
      },
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    child: Text(
                      'language'.tr,
                      style: context.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: appLanguages.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: ListTile(
                          title: Text(
                            appLanguages[index]['name'],
                            style: context.textTheme.labelLarge,
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            MyApp.updateAppState(
                              context,
                              newLocale: appLanguages[index]['locale'],
                            );
                            _updateLanguage(appLanguages[index]['locale']);
                            Get.back();
                          },
                        ),
                      );
                    },
                  ),
                  const Gap(10),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildGroupsCard(BuildContext context) {
    return SettingCard(
      icon: const Icon(IconsaxPlusLinear.link_square),
      text: 'groups'.tr,
      onPressed: () {
        _showGroupsBottomSheet(context);
      },
    );
  }

  void _showGroupsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                      child: Text(
                        'groups'.tr,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SettingCard(
                      elevation: 4,
                      icon: const Icon(LineAwesomeIcons.discord),
                      text: 'Discord',
                      onPressed: () =>
                          _urlLauncher('https://discord.gg/JMMa9aHh8f'),
                    ),
                    SettingCard(
                      elevation: 4,
                      icon: const Icon(LineAwesomeIcons.telegram),
                      text: 'Telegram',
                      onPressed: () =>
                          _urlLauncher('https://t.me/darkmoonightX'),
                    ),
                    const Gap(10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLicenseCard(BuildContext context) {
    return SettingCard(
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
  }

  Widget _buildVersionCard(BuildContext context) {
    return SettingCard(
      icon: const Icon(IconsaxPlusLinear.hierarchy_square_2),
      text: 'version'.tr,
      info: true,
      textInfo: '$appVersion',
    );
  }

  Widget _buildGitHubCard(BuildContext context) {
    return SettingCard(
      icon: const Icon(LineAwesomeIcons.github),
      text: '${'project'.tr} GitHub',
      onPressed: () => _urlLauncher('https://github.com/darkmoonight/Zest'),
    );
  }
}
