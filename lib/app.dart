import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/bootstrap/app_bootstrap.dart';
import 'package:zest/core/navigation/app_router.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/theme/app_themes_provider.dart';
import 'package:zest/core/theme/theme_mode_notifier.dart';
import 'package:zest/core/bootstrap/notification_navigation_listener.dart';
import 'package:zest/core/bootstrap/notification_sync_listener.dart';
import 'package:zest/core/services/auto_backup_lifecycle_listener.dart';
import 'package:zest/core/utils/quick_actions_listener.dart';
import 'package:zest/core/utils/snackbar_overlay.dart';
import 'package:zest/i18n/strings.g.dart';

/// Root widget: routing, theming, localization, and global overlays.
class ZestApp extends ConsumerWidget {
  const ZestApp({super.key, required this.bootstrap});

  /// Bootstrap container with Isar and initial settings.
  final AppBootstrap bootstrap;

  /// Applies settings changes through [appSettingsProvider].
  static void updateAppState(
    WidgetRef ref, {
    bool? newAmoledTheme,
    bool? newMaterialColor,
    bool? newIsImage,
    String? newColorPalette,
    String? newAppFont,
    String? newTimeformat,
    String? newFirstDay,
    Locale? newLocale,
  }) {
    ref
        .read(appSettingsProvider.notifier)
        .update(
          amoledTheme: newAmoledTheme,
          materialColor: newMaterialColor,
          isImage: newIsImage,
          colorPalette: newColorPalette,
          appFont: newAppFont,
          timeformat: newTimeformat,
          firstDay: newFirstDay,
          locale: newLocale,
        );
  }

  /// Builds the themed [MaterialApp.router] with localization and overlays.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialColor = ref.watch(
      appSettingsProvider.select((s) => s.materialColor),
    );
    final amoledTheme = ref.watch(
      appSettingsProvider.select((s) => s.amoledTheme),
    );
    final locale = ref.watch(appSettingsProvider.select((s) => s.locale));
    final appFont = ref.watch(appSettingsProvider.select((s) => s.appFont));
    final colorPalette = ref.watch(
      appSettingsProvider.select((s) => s.colorPalette),
    );
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DynamicColorBuilder(
        builder: (lightColorScheme, darkColorScheme) {
          final themes = ref.watch(
            appThemesProvider(
              AppThemeInputs(
                materialColor: materialColor,
                amoledTheme: amoledTheme,
                colorPalette: colorPalette,
                appFont: appFont,
                lightDynamic: lightColorScheme,
                darkDynamic: darkColorScheme,
              ),
            ),
          );

          return TranslationProvider(
            child: AutoBackupLifecycleListener(
              child: NotificationSyncListener(
                child: NotificationNavigationListener(
                  child: QuickActionsListener(
                    child: MaterialApp.router(
                      routerConfig: router,
                      themeMode: themeMode,
                      theme: themes.light,
                      darkTheme: themes.dark,
                      locale: locale,
                      supportedLocales: AppLocaleUtils.supportedLocales,
                      localizationsDelegates: const [
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      debugShowCheckedModeBanner: false,
                      title: 'Zest',
                      builder: (context, child) => Stack(
                        children: [?child, const SnackBarOverlayWidget()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
