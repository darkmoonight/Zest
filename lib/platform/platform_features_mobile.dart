import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:display_mode/display_mode.dart';
import 'package:flag_secure/flag_secure.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:zest/platform/quick_action_item.dart';

export 'package:zest/platform/quick_action_item.dart';

/// Maps [QuickActionItem] onto the quick_actions plugin model.
extension QuickActionItemShortcut on QuickActionItem {
  /// Converts this item to a [ShortcutItem] for the quick_actions plugin.
  ShortcutItem toShortcutItem() {
    return ShortcutItem(type: type, localizedTitle: localizedTitle, icon: icon);
  }
}

/// Mobile and desktop platform integrations for notifications, UI, and shortcuts.
class PlatformFeatures {
  static QuickActions? _quickActions;

  // ==================== PLATFORM CHECKS ====================

  /// Whether the runtime is Android or iOS.
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Whether the runtime is Windows, Linux, or macOS.
  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// Whether the runtime is web.
  static bool get isWeb => kIsWeb;

  /// Whether the runtime is Android.
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  // ==================== FEATURE SUPPORT ====================

  /// Whether local notifications are available.
  static bool get supportsNotifications => !kIsWeb;

  /// Whether home-screen quick actions are available.
  static bool get supportsQuickActions => isMobile;

  /// Whether Material You dynamic color is available.
  static bool get supportsDynamicColor => isMobile;

  /// Whether FLAG_SECURE screen privacy is available.
  static bool get supportsScreenPrivacy => isMobile;

  /// Whether display refresh-rate selection is available.
  static bool get supportsDisplayMode => isAndroid;

  // ==================== INITIALIZATION ====================

  /// Performs one-time platform initialization.
  static Future<void> initialize() async {
    try {
      if (supportsDisplayMode) {
        await setOptimalDisplayMode();
      }
    } catch (e) {
      debugPrint('PlatformFeatures initialization error: $e');
    }
  }

  // ==================== DISPLAY MODE ====================

  /// Selects the highest refresh rate for the current resolution.
  static Future<void> setOptimalDisplayMode() async {
    if (!supportsDisplayMode) return;

    try {
      final supported = await FlutterDisplayMode.supported;
      final active = await FlutterDisplayMode.active;

      final sameResolution =
          supported
              .where(
                (mode) =>
                    mode.width == active.width && mode.height == active.height,
              )
              .toList()
            ..sort((a, b) => b.refreshRate.compareTo(a.refreshRate));

      final optimalMode = sameResolution.isNotEmpty
          ? sameResolution.first
          : active;

      await FlutterDisplayMode.setPreferredMode(optimalMode);
      debugPrint(
        'Display mode set: ${optimalMode.width}x${optimalMode.height}@${optimalMode.refreshRate}Hz',
      );
    } catch (e) {
      debugPrint('Error setting optimal display mode: $e');
    }
  }

  // ==================== SCREEN PRIVACY ====================

  /// Enables or disables screen capture blocking via FLAG_SECURE.
  static Future<void> setScreenPrivacy(bool enabled) async {
    if (!supportsScreenPrivacy) return;

    try {
      if (enabled) {
        await FlagSecure.set();
        debugPrint('Screen privacy enabled');
      } else {
        await FlagSecure.unset();
        debugPrint('Screen privacy disabled');
      }
    } on PlatformException catch (e) {
      debugPrint('Error setting screen privacy: $e');
      rethrow;
    }
  }

  // ==================== QUICK ACTIONS ====================

  /// Registers [onShortcut] for launcher quick-action taps.
  static void initializeQuickActions({required Function(String) onShortcut}) {
    if (!supportsQuickActions) return;

    try {
      _quickActions = const QuickActions();
      _quickActions!.initialize(onShortcut);
      debugPrint('Quick actions initialized');
    } catch (e) {
      debugPrint('Error initializing quick actions: $e');
    }
  }

  /// Updates registered launcher shortcut items.
  static void setQuickActionItems(List<QuickActionItem> items) {
    if (!supportsQuickActions || _quickActions == null) return;

    try {
      final shortcutItems = items.map((item) => item.toShortcutItem()).toList();
      _quickActions!.setShortcutItems(shortcutItems);
      debugPrint('Quick actions set: ${items.length} items');
    } catch (e) {
      debugPrint('Error setting quick action items: $e');
    }
  }

  // ==================== SYSTEM UI ====================

  /// Sets edge-to-edge or manual system UI mode on mobile.
  static Future<void> setSystemUIMode({bool edgeToEdge = true}) async {
    if (!isMobile) return;

    try {
      if (edgeToEdge) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } else {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: SystemUiOverlay.values,
        );
      }
    } catch (e) {
      debugPrint('Error setting system UI mode: $e');
    }
  }

  // ==================== UTILITIES ====================

  /// Returns capability flags for the current platform.
  static Map<String, dynamic> getPlatformInfo() {
    return {
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isWeb': isWeb,
      'isAndroid': isAndroid,
      'supportsNotifications': supportsNotifications,
      'supportsQuickActions': supportsQuickActions,
      'supportsDynamicColor': supportsDynamicColor,
      'supportsScreenPrivacy': supportsScreenPrivacy,
      'supportsDisplayMode': supportsDisplayMode,
    };
  }

  /// Logs [getPlatformInfo] to the debug console.
  static void logPlatformInfo() {
    debugPrint('=== Platform Features ===');
    getPlatformInfo().forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('========================');
  }
}
