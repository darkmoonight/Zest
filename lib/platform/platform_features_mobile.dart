import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:display_mode/display_mode.dart';
import 'package:flag_secure/flag_secure.dart';
import 'package:quick_actions/quick_actions.dart';

class QuickActionItem {
  final String type;
  final String localizedTitle;
  final String icon;

  QuickActionItem({
    required this.type,
    required this.localizedTitle,
    required this.icon,
  });
}

class PlatformFeatures {
  static QuickActions? _quickActions;
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  static bool get supportsNotifications => !kIsWeb;
  static bool get supportsQuickActions =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get supportsDynamicColor =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get supportsScreenPrivacy =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static bool get supportsDisplayMode => !kIsWeb && Platform.isAndroid;

  static Future<void> initialize() async {
    if (supportsDisplayMode) {
      await _setOptimalDisplayMode();
    }
  }

  static Future<void> _setOptimalDisplayMode() async {
    try {
      final List<DisplayModeJson> supported =
          await FlutterDisplayMode.supported;
      final DisplayModeJson active = await FlutterDisplayMode.active;
      final List<DisplayModeJson> sameResolution =
          supported
              .where(
                (DisplayModeJson m) =>
                    m.width == active.width && m.height == active.height,
              )
              .toList()
            ..sort(
              (DisplayModeJson a, DisplayModeJson b) =>
                  b.refreshRate.compareTo(a.refreshRate),
            );
      final DisplayModeJson mostOptimalMode = sameResolution.isNotEmpty
          ? sameResolution.first
          : active;
      await FlutterDisplayMode.setPreferredMode(mostOptimalMode);
    } catch (e) {
      debugPrint('Error setting display mode: $e');
    }
  }

  static Future<void> setScreenPrivacy(bool enabled) async {
    if (!supportsScreenPrivacy) return;

    try {
      if (enabled) {
        await FlagSecure.set();
      } else {
        await FlagSecure.unset();
      }
    } on PlatformException catch (e) {
      debugPrint('Error setting screen privacy: $e');
    }
  }

  static void initializeQuickActions({required Function(String) onShortcut}) {
    if (!supportsQuickActions) return;

    _quickActions = const QuickActions();
    _quickActions!.initialize(onShortcut);
  }

  static void setQuickActionItems(List<QuickActionItem> items) {
    if (!supportsQuickActions || _quickActions == null) return;

    final shortcutItems = items
        .map(
          (item) => ShortcutItem(
            type: item.type,
            localizedTitle: item.localizedTitle,
            icon: item.icon,
          ),
        )
        .toList();

    _quickActions!.setShortcutItems(shortcutItems);
  }
}
