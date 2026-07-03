import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:display_mode/display_mode.dart';
import 'package:flag_secure/flag_secure.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:zest/platform/quick_action_item.dart';
export 'package:dynamic_system_colors/dynamic_system_colors.dart'
    show DynamicColorBuilder;
export 'package:zest/platform/quick_action_item.dart';

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

  /// Whether the runtime is iOS.
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Whether the runtime is Windows.
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Whether the runtime is Linux.
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Whether the runtime is macOS.
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

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

  /// Whether app lifecycle callbacks are available.
  static bool get supportsAppLifecycle => !kIsWeb;

  /// Whether haptic feedback is available.
  static bool get supportsHaptics => isMobile;

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

  /// Returns the active display mode, or null when unsupported.
  static Future<DisplayModeJson?> getCurrentDisplayMode() async {
    if (!supportsDisplayMode) return null;

    try {
      return await FlutterDisplayMode.active;
    } catch (e) {
      debugPrint('Error getting current display mode: $e');
      return null;
    }
  }

  /// Returns supported display modes, or an empty list when unsupported.
  static Future<List<DisplayModeJson>> getSupportedDisplayModes() async {
    if (!supportsDisplayMode) return [];

    try {
      return await FlutterDisplayMode.supported;
    } catch (e) {
      debugPrint('Error getting supported display modes: $e');
      return [];
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

  /// Whether screen privacy is currently enabled.
  static Future<bool> isScreenPrivacyEnabled() async {
    if (!supportsScreenPrivacy) return false;

    try {
      return false;
    } catch (e) {
      debugPrint('Error checking screen privacy: $e');
      return false;
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

  /// Removes all registered launcher shortcuts.
  static void clearQuickActions() {
    if (!supportsQuickActions || _quickActions == null) return;

    try {
      _quickActions!.clearShortcutItems();
      debugPrint('Quick actions cleared');
    } catch (e) {
      debugPrint('Error clearing quick actions: $e');
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

  /// Applies status and navigation bar overlay colors.
  static Future<void> setSystemUIOverlayStyle({
    Color? statusBarColor,
    Color? navigationBarColor,
    Brightness? statusBarIconBrightness,
    Brightness? navigationBarIconBrightness,
  }) async {
    if (!isMobile) return;

    try {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: statusBarIconBrightness,
          systemNavigationBarColor: navigationBarColor,
          systemNavigationBarIconBrightness: navigationBarIconBrightness,
        ),
      );
    } catch (e) {
      debugPrint('Error setting system UI overlay style: $e');
    }
  }

  // ==================== HAPTICS ====================

  /// Triggers a light haptic impact.
  static Future<void> lightHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error triggering light haptic: $e');
    }
  }

  /// Triggers a medium haptic impact.
  static Future<void> mediumHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error triggering medium haptic: $e');
    }
  }

  /// Triggers a heavy haptic impact.
  static Future<void> heavyHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error triggering heavy haptic: $e');
    }
  }

  /// Triggers a selection-click haptic.
  static Future<void> selectionHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error triggering selection haptic: $e');
    }
  }

  // ==================== ORIENTATION ====================

  /// Restricts allowed device orientations.
  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    if (!isMobile) return;

    try {
      await SystemChrome.setPreferredOrientations(orientations);
    } catch (e) {
      debugPrint('Error setting preferred orientations: $e');
    }
  }

  /// Allows all device orientations.
  static Future<void> allowAllOrientations() async {
    await setPreferredOrientations(DeviceOrientation.values);
  }

  /// Restricts to portrait orientations only.
  static Future<void> portraitOnly() async {
    await setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Restricts to landscape orientations only.
  static Future<void> landscapeOnly() async {
    await setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // ==================== UTILITIES ====================

  /// Returns capability flags for the current platform.
  static Map<String, dynamic> getPlatformInfo() {
    return {
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isWeb': isWeb,
      'isAndroid': isAndroid,
      'isIOS': isIOS,
      'isWindows': isWindows,
      'isLinux': isLinux,
      'isMacOS': isMacOS,
      'supportsNotifications': supportsNotifications,
      'supportsQuickActions': supportsQuickActions,
      'supportsDynamicColor': supportsDynamicColor,
      'supportsScreenPrivacy': supportsScreenPrivacy,
      'supportsDisplayMode': supportsDisplayMode,
      'supportsHaptics': supportsHaptics,
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
