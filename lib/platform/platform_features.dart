import 'package:flutter/foundation.dart';
import 'package:zest/platform/quick_action_item.dart';

export 'package:zest/platform/quick_action_item.dart';

/// No-op platform feature stubs for web and unsupported targets.
abstract class PlatformFeatures {
  /// Whether the runtime is a mobile OS.
  static bool get isMobile => false;

  /// Whether the runtime is a desktop OS.
  static bool get isDesktop => false;

  /// Whether the runtime is web.
  static bool get isWeb => false;

  /// Whether the runtime is Android.
  static bool get isAndroid => false;

  /// Whether local notifications are available.
  static bool get supportsNotifications => false;

  /// Whether home-screen quick actions are available.
  static bool get supportsQuickActions => false;

  /// Whether Material You dynamic color is available.
  static bool get supportsDynamicColor => false;

  /// Whether FLAG_SECURE screen privacy is available.
  static bool get supportsScreenPrivacy => false;

  /// Whether display refresh-rate selection is available.
  static bool get supportsDisplayMode => false;

  /// Performs one-time platform initialization.
  static Future<void> initialize() async {}

  /// Enables or disables screen capture blocking.
  static Future<void> setScreenPrivacy(bool enabled) async {}

  /// Registers a callback for launcher shortcut taps.
  static void initializeQuickActions({required Function(String) onShortcut}) {}

  /// Updates registered launcher shortcut items.
  static void setQuickActionItems(List<QuickActionItem> items) {}

  /// Selects the highest refresh rate for the current resolution.
  static Future<void> setOptimalDisplayMode() async {}

  /// Sets edge-to-edge or manual system UI mode on mobile.
  static Future<void> setSystemUIMode({bool edgeToEdge = true}) async {}

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
