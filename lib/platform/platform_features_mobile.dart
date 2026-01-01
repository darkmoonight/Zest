import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:display_mode/display_mode.dart';
import 'package:flag_secure/flag_secure.dart';
import 'package:quick_actions/quick_actions.dart';
export 'package:dynamic_color/dynamic_color.dart' show DynamicColorBuilder;

class QuickActionItem {
  final String type;
  final String localizedTitle;
  final String icon;

  const QuickActionItem({
    required this.type,
    required this.localizedTitle,
    required this.icon,
  });

  ShortcutItem toShortcutItem() {
    return ShortcutItem(type: type, localizedTitle: localizedTitle, icon: icon);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickActionItem &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

class PlatformFeatures {
  static QuickActions? _quickActions;

  // ==================== PLATFORM CHECKS ====================

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  static bool get isWeb => kIsWeb;

  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  static bool get isIOS => !kIsWeb && Platform.isIOS;

  static bool get isWindows => !kIsWeb && Platform.isWindows;

  static bool get isLinux => !kIsWeb && Platform.isLinux;

  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  // ==================== FEATURE SUPPORT ====================

  static bool get supportsNotifications => !kIsWeb;

  static bool get supportsQuickActions => isMobile;

  static bool get supportsDynamicColor => isMobile;

  static bool get supportsScreenPrivacy => isMobile;

  static bool get supportsDisplayMode => isAndroid;

  static bool get supportsAppLifecycle => !kIsWeb;

  static bool get supportsHaptics => isMobile;

  // ==================== INITIALIZATION ====================

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

  static Future<DisplayModeJson?> getCurrentDisplayMode() async {
    if (!supportsDisplayMode) return null;

    try {
      return await FlutterDisplayMode.active;
    } catch (e) {
      debugPrint('Error getting current display mode: $e');
      return null;
    }
  }

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

  static Future<void> lightHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('Error triggering light haptic: $e');
    }
  }

  static Future<void> mediumHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error triggering medium haptic: $e');
    }
  }

  static Future<void> heavyHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint('Error triggering heavy haptic: $e');
    }
  }

  static Future<void> selectionHaptic() async {
    if (!supportsHaptics) return;

    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      debugPrint('Error triggering selection haptic: $e');
    }
  }

  // ==================== ORIENTATION ====================

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

  static Future<void> allowAllOrientations() async {
    await setPreferredOrientations(DeviceOrientation.values);
  }

  static Future<void> portraitOnly() async {
    await setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  static Future<void> landscapeOnly() async {
    await setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // ==================== UTILITIES ====================

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

  static void logPlatformInfo() {
    debugPrint('=== Platform Features ===');
    getPlatformInfo().forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('========================');
  }
}
