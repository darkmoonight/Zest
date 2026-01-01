import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickActionItem {
  final String type;
  final String localizedTitle;
  final String icon;

  const QuickActionItem({
    required this.type,
    required this.localizedTitle,
    required this.icon,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickActionItem &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;
}

abstract class PlatformFeatures {
  static bool get isMobile => false;
  static bool get isDesktop => false;
  static bool get isWeb => false;

  static bool get supportsNotifications => false;
  static bool get supportsQuickActions => false;
  static bool get supportsDynamicColor => false;
  static bool get supportsScreenPrivacy => false;
  static bool get supportsDisplayMode => false;
  static bool get supportsAppLifecycle => false;

  static Future<void> initialize() async {}

  static Future<void> setScreenPrivacy(bool enabled) async {}

  static void initializeQuickActions({required Function(String) onShortcut}) {}

  static void setQuickActionItems(List<QuickActionItem> items) {}

  static void onAppResume(VoidCallback callback) {}
  static void onAppPause(VoidCallback callback) {}

  static Future<void> setOptimalDisplayMode() async {}
  static Future<void> setSystemUIMode({bool edgeToEdge = true}) async {}

  static Future<void> setSystemUIOverlayStyle({
    Color? statusBarColor,
    Color? navigationBarColor,
    Brightness? statusBarIconBrightness,
    Brightness? navigationBarIconBrightness,
  }) async {}

  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {}

  static Future<void> allowAllOrientations() async {}
  static Future<void> portraitOnly() async {}
  static Future<void> landscapeOnly() async {}

  static Future<void> lightHaptic() async {}
  static Future<void> mediumHaptic() async {}
  static Future<void> heavyHaptic() async {}
  static Future<void> selectionHaptic() async {}

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

  static void logPlatformInfo() {
    debugPrint('=== Platform Features ===');
    getPlatformInfo().forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('========================');
  }

  static void clearQuickActions() {}
}

class DynamicColorBuilder extends StatelessWidget {
  final Widget Function(ColorScheme?, ColorScheme?) builder;

  const DynamicColorBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(null, null);
  }
}
