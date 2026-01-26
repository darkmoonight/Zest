import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:zest/app/controller/isar_controller.dart';
import 'package:zest/app/ui/home.dart';
import 'package:zest/app/ui/onboarding.dart';
import 'package:zest/app/ui/tasks/widgets/tasks_action.dart';
import 'package:zest/app/ui/todos/view/calendar_todos.dart';
import 'package:zest/app/utils/snackbar_overlay.dart';
import 'package:zest/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/app/controller/theme_controller.dart';
import 'package:zest/app/utils/device_info.dart';
import 'app/data/db.dart';
import 'app/ui/todos/view/all_todos.dart';
import 'app/utils/notification.dart';
import 'translation/translation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'platform/platform_features.dart'
    if (dart.library.io) 'platform/platform_features_mobile.dart'
    hide DynamicColorBuilder;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

late Isar isar;
late Settings settings;

bool amoledTheme = false;
bool materialColor = false;
RxBool isImage = true.obs;
RxString timeformat = '24'.obs;
RxString firstDay = 'monday'.obs;
Locale locale = const Locale('en', 'US');

final List<Map<String, dynamic>> appLanguages = [
  {'name': 'العربية', 'locale': const Locale('ar', 'AR')},
  {'name': 'Deutsch', 'locale': const Locale('de', 'DE')},
  {'name': 'English', 'locale': const Locale('en', 'US')},
  {'name': 'Español', 'locale': const Locale('es', 'ES')},
  {'name': 'Français', 'locale': const Locale('fr', 'FR')},
  {'name': 'Italiano', 'locale': const Locale('it', 'IT')},
  {'name': '한국어', 'locale': const Locale('ko', 'KR')},
  {'name': 'فارسی', 'locale': const Locale('fa', 'IR')},
  {'name': 'Polski', 'locale': const Locale('pl', 'PL')},
  {'name': 'Русский', 'locale': const Locale('ru', 'RU')},
  {'name': 'Tiếng việt', 'locale': const Locale('vi', 'VN')},
  {'name': 'Türkçe', 'locale': const Locale('tr', 'TR')},
  {'name': '中文(简体)', 'locale': const Locale('zh', 'CN')},
  {'name': '中文(繁體)', 'locale': const Locale('zh', 'TW')},
  {'name': 'Português', 'locale': const Locale('pt', 'PT')},
];

List<String> allScreens = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeApp();
  runApp(const MyApp());
}

Future<void> initializeApp() async {
  DeviceFeature().init();
  await PlatformFeatures.initialize();

  if (kDebugMode) {
    PlatformFeatures.logPlatformInfo();
  }

  await initializeTimeZone();
  await initializeNotifications();
  await IsarController.openDB();
  await initSettings();
  await PlatformFeatures.setScreenPrivacy(settings.screenPrivacy ?? false);

  if (PlatformFeatures.isMobile) {
    await PlatformFeatures.setSystemUIMode(edgeToEdge: true);
  }
}

Future<void> initializeTimeZone() async {
  try {
    final TimezoneInfo timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timeZoneName.identifier));
  } catch (e) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    debugPrint('Error initializing timezone: $e');
  }
}

Future<void> initializeNotifications() async {
  if (!PlatformFeatures.supportsNotifications) return;

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const linuxSettings = LinuxInitializationSettings(
    defaultActionName: 'Open notification',
  );

  const initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
    macOS: iosSettings,
    linux: linuxSettings,
  );
  try {
    await flutterLocalNotificationsPlugin!.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async =>
          await handleNotificationResponse(response),
      onDidReceiveBackgroundNotificationResponse: kIsWeb
          ? null
          : notificationTapBackground,
    );
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) =>
    handleNotificationResponse(response);

Future<void> handleNotificationResponse(NotificationResponse response) async {
  if (flutterLocalNotificationsPlugin == null) {
    await initializeNotifications();
  }
  await initializeTimeZone();
  try {
    final payload = response.payload;
    final actionId = response.actionId;

    if (payload == null) return;

    final todoId = int.tryParse(payload);
    if (todoId == null) return;

    switch (actionId) {
      case 'mark_done':
        await markTodoAsDone(todoId);
        break;
      case 'snooze':
        await snoozeTodo(todoId);
        break;
      default:
        break;
    }
  } catch (e) {
    debugPrint('Error handling notification: $e');
  }
}

Future<void> snoozeTodo(int todoId) async {
  try {
    final isarInstance = await _getIsarInstance();
    if (isarInstance == null) return;
    settings = isarInstance.settings.where().findFirstSync() ?? Settings();

    final todo = await isarInstance.todos.get(todoId);
    if (todo == null) return;

    final title = todo.name;
    final body = todo.description;

    final translations = Translation().keys;
    final localeCode = settings.language ?? 'en_US';
    final langMap = translations[localeCode] ?? translations['en_US']!;

    String translate(String key) => langMap[key] ?? key;

    final snoozeText =
        '${translate('snooze')} ${settings.snoozeDuration} ${translate('min')}';
    final markDoneText = translate('markAsDone');

    await NotificationShow().snoozeNotification(
      todoId,
      title,
      body,
      snoozeActionText: snoozeText,
      markDoneActionText: markDoneText,
    );

    await isarInstance.writeTxn(() async {
      todo.todoCompletedTime = DateTime.now().add(
        Duration(minutes: settings.snoozeDuration),
      );
      await isarInstance.todos.put(todo);
    });

    await isarInstance.close();
  } catch (e) {
    debugPrint('Error snoozing todo: $e');
  }
}

Future<void> markTodoAsDone(int todoId) async {
  try {
    final isarInstance = await _getIsarInstance();
    if (isarInstance == null) return;

    final todo = await isarInstance.todos.get(todoId);
    if (todo == null) return;

    if (!todo.done) {
      await isarInstance.writeTxn(() async {
        todo.done = true;
        todo.todoCompletionTime = DateTime.now();
        await isarInstance.todos.put(todo);
      });
      if (flutterLocalNotificationsPlugin != null) {
        await flutterLocalNotificationsPlugin!.cancel(id: todoId);
      }
      await isarInstance.close();
    }
  } catch (e) {
    debugPrint('Error marking todo as done: $e');
  }
}

Future<Isar?> _getIsarInstance() async {
  if (Isar.instanceNames.isEmpty) {
    final dir = await getApplicationSupportDirectory();
    return await Isar.open(
      [TasksSchema, TodosSchema, SettingsSchema],
      directory: dir.path,
      inspector: true,
    );
  } else {
    return Isar.getInstance();
  }
}

Future<void> initSettings() async {
  settings = isar.settings.where().findFirstSync() ?? Settings();
  settings.language ??= Get.deviceLocale.toString();
  settings.theme ??= 'system';
  settings.isImage ??= false;
  settings.screenPrivacy ??= false;
  if (settings.snoozeDuration <= 0) {
    settings.snoozeDuration = 10;
  }
  await isar.writeTxn(() => isar.settings.put(settings));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static Future<void> updateAppState(
    BuildContext context, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    bool? newIsImage,
    String? newTimeformat,
    String? newFirstDay,
    Locale? newLocale,
  }) async {
    final state = context.findAncestorStateOfType<_MyAppState>()!;
    if (newAmoledTheme != null) state.changeAmoledTheme(newAmoledTheme);
    if (newMaterialColor != null) state.changeMaterialTheme(newMaterialColor);
    if (newLocale != null) state.changeLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeController = Get.put(ThemeController());
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();
  String? _pendingShortcut;
  bool _isShowingBottomSheet = false;

  void changeAmoledTheme(bool newAmoledTheme) =>
      setState(() => amoledTheme = newAmoledTheme);
  void changeMaterialTheme(bool newMaterialColor) =>
      setState(() => materialColor = newMaterialColor);
  void changeLocale(Locale newLocale) {
    setState(() => locale = newLocale);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _setQuickActionsItems(),
    );
  }

  @override
  void initState() {
    super.initState();
    amoledTheme = settings.amoledTheme;
    materialColor = settings.materialColor;
    timeformat.value = settings.timeformat;
    firstDay.value = settings.firstDay;
    isImage.value = settings.isImage!;
    locale = Locale(
      settings.language!.substring(0, 2),
      settings.language!.substring(3),
    );
    _initQuickActions();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryHandlePending());
  }

  void _initQuickActions() {
    PlatformFeatures.initializeQuickActions(
      onShortcut: (String shortcutType) {
        _pendingShortcut = shortcutType;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _tryHandlePending(),
        );
      },
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _setQuickActionsItems(),
    );
  }

  void _setQuickActionsItems() {
    if (!PlatformFeatures.supportsQuickActions) return;

    PlatformFeatures.setQuickActionItems([
      QuickActionItem(
        type: 'action_new_categories',
        localizedTitle: 'addCategory'.tr,
        icon: 'ic_shortcut_new_categories',
      ),
      QuickActionItem(
        type: 'action_new_todo',
        localizedTitle: 'addTodo'.tr,
        icon: 'ic_shortcut_new_todo',
      ),
      QuickActionItem(
        type: 'action_all_todos',
        localizedTitle: 'allTodos'.tr,
        icon: 'ic_shortcut_all_todos',
      ),
      QuickActionItem(
        type: 'action_calendar_todos',
        localizedTitle: 'calendar'.tr,
        icon: 'ic_shortcut_calendar_todos',
      ),
    ]);
  }

  void _tryHandlePending() {
    if (_pendingShortcut == null) return;
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryHandlePending());
      return;
    }
    final hasMaterialLocalizations =
        Localizations.of<MaterialLocalizations>(ctx, MaterialLocalizations) !=
        null;
    if (!hasMaterialLocalizations) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryHandlePending());
      return;
    }
    final type = _pendingShortcut!;
    _pendingShortcut = null;
    _handleShortcutWithContext(type, ctx);
  }

  Future<void> _showCreateSheet(BuildContext ctx, Widget sheet) async {
    if (_isShowingBottomSheet) return;
    _isShowingBottomSheet = true;
    await showModalBottomSheet(
      enableDrag: false,
      context: ctx,
      isScrollControlled: true,
      builder: (BuildContext context) => sheet,
    );
    _isShowingBottomSheet = false;
  }

  void _handleShortcutWithContext(String type, BuildContext ctx) {
    switch (type) {
      case 'action_new_categories':
        if (_homeKey.currentState != null) {
          _homeKey.currentState!.changeTabIndex(0);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCreateSheet(ctx, TasksAction(text: 'create'.tr, edit: false));
          });
        } else {
          _showCreateSheet(ctx, TasksAction(text: 'create'.tr, edit: false));
        }
        break;
      case 'action_new_todo':
        if (_homeKey.currentState != null) {
          _homeKey.currentState!.changeTabIndex(1);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCreateSheet(
              ctx,
              TodosAction(text: 'create'.tr, edit: false, category: true),
            );
          });
        } else {
          _showCreateSheet(
            ctx,
            TodosAction(text: 'create'.tr, edit: false, category: true),
          );
        }
        break;
      case 'action_all_todos':
        if (_homeKey.currentState != null) {
          _homeKey.currentState!.changeTabIndex(1);
          _navigatorKey.currentState?.popUntil((r) => r.isFirst);
        } else {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const AllTodos()),
          );
        }
        break;
      case 'action_calendar_todos':
        if (_homeKey.currentState != null) {
          _homeKey.currentState!.changeTabIndex(2);
          _navigatorKey.currentState?.popUntil((r) => r.isFirst);
        } else {
          _navigatorKey.currentState?.push(
            MaterialPageRoute(builder: (_) => const CalendarTodos()),
          );
        }
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final edgeToEdgeAvailable = DeviceFeature().isEdgeToEdgeAvailable();

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          return _buildMaterialApp(
            edgeToEdgeAvailable,
            lightColorScheme,
            darkColorScheme,
          );
        },
      ),
    );
  }

  Widget _buildMaterialApp(
    bool edgeToEdgeAvailable,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  ) {
    final lightMaterialTheme = lightTheme(
      lightColorScheme?.surface,
      lightColorScheme,
      edgeToEdgeAvailable,
    );
    final darkMaterialTheme = darkTheme(
      darkColorScheme?.surface,
      darkColorScheme,
      edgeToEdgeAvailable,
    );
    final darkMaterialThemeOled = darkTheme(
      oledColor,
      darkColorScheme,
      edgeToEdgeAvailable,
    );

    return GetMaterialApp(
      navigatorKey: _navigatorKey,
      theme: materialColor
          ? lightColorScheme != null
                ? lightMaterialTheme
                : lightTheme(lightColor, colorSchemeLight, edgeToEdgeAvailable)
          : lightTheme(lightColor, colorSchemeLight, edgeToEdgeAvailable),
      darkTheme: amoledTheme
          ? materialColor
                ? darkColorScheme != null
                      ? darkMaterialThemeOled
                      : darkTheme(
                          oledColor,
                          colorSchemeDark,
                          edgeToEdgeAvailable,
                        )
                : darkTheme(oledColor, colorSchemeDark, edgeToEdgeAvailable)
          : materialColor
          ? darkColorScheme != null
                ? darkMaterialTheme
                : darkTheme(darkColor, colorSchemeDark, edgeToEdgeAvailable)
          : darkTheme(darkColor, colorSchemeDark, edgeToEdgeAvailable),
      themeMode: themeController.theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      translations: Translation(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: appLanguages.map((e) => e['locale'] as Locale).toList(),
      debugShowCheckedModeBanner: false,
      home: settings.onboard ? HomePage(key: _homeKey) : const OnBoarding(),
      title: 'Zest',
      builder: (context, child) {
        return Stack(children: [child!, const SnackBarOverlayWidget()]);
      },
    );
  }
}
