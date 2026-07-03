import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Whether app lifecycle callbacks are available.
  static bool get supportsAppLifecycle => false;

  /// Performs one-time platform initialization.
  static Future<void> initialize() async {}

  /// Enables or disables screen capture blocking.
  static Future<void> setScreenPrivacy(bool enabled) async {}

  /// Registers a callback for launcher shortcut taps.
  static void initializeQuickActions({required Function(String) onShortcut}) {}

  /// Updates registered launcher shortcut items.
  static void setQuickActionItems(List<QuickActionItem> items) {}

  /// Registers a callback invoked when the app returns to foreground.
  static void onAppResume(VoidCallback callback) {}

  /// Registers a callback invoked when the app moves to background.
  static void onAppPause(VoidCallback callback) {}

  /// Selects the highest refresh rate for the current resolution.
  static Future<void> setOptimalDisplayMode() async {}

  /// Sets edge-to-edge or manual system UI mode on mobile.
  static Future<void> setSystemUIMode({bool edgeToEdge = true}) async {}

  /// Applies status and navigation bar overlay colors.
  static Future<void> setSystemUIOverlayStyle({
    Color? statusBarColor,
    Color? navigationBarColor,
    Brightness? statusBarIconBrightness,
    Brightness? navigationBarIconBrightness,
  }) async {}

  /// Restricts allowed device orientations.
  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {}

  /// Allows all device orientations.
  static Future<void> allowAllOrientations() async {}

  /// Restricts to portrait orientations only.
  static Future<void> portraitOnly() async {}

  /// Restricts to landscape orientations only.
  static Future<void> landscapeOnly() async {}

  /// Triggers a light haptic impact.
  static Future<void> lightHaptic() async {}

  /// Triggers a medium haptic impact.
  static Future<void> mediumHaptic() async {}

  /// Triggers a heavy haptic impact.
  static Future<void> heavyHaptic() async {}

  /// Triggers a selection-click haptic.
  static Future<void> selectionHaptic() async {}

  /// Returns capability flags for the current platform.
  static Map<String, dynamic> getPlatformInfo() {
    return {
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isWeb': isWeb,
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

  /// Removes all registered launcher shortcuts.
  static void clearQuickActions() {}
}

/// Fallback dynamic color builder that supplies null schemes on unsupported platforms.
class DynamicColorBuilder extends StatelessWidget {
  /// Creates a builder invoked with null light and dark schemes.
  const DynamicColorBuilder({super.key, required this.builder});

  /// Builds UI from optional dynamic light and dark color schemes.
  /// Builds UI from optional dynamic light and dark color schemes.
  final Widget Function(ColorScheme?, ColorScheme?) builder;

  @override
  Widget build(BuildContext context) {
    return builder(null, null);
  }
}
