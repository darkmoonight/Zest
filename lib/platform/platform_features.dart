import 'package:flutter/material.dart';

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
  static bool get isMobile => false;
  static bool get isDesktop => false;
  static bool get supportsNotifications => false;
  static bool get supportsQuickActions => false;
  static bool get supportsDynamicColor => false;
  static bool get supportsScreenPrivacy => false;
  static bool get supportsDisplayMode => false;

  static Future<void> initialize() async {}

  static Future<void> setScreenPrivacy(bool enabled) async {}

  static void initializeQuickActions({required Function(String) onShortcut}) {}

  static void setQuickActionItems(List<QuickActionItem> items) {}
}

class DynamicColorBuilder extends StatelessWidget {
  final Widget Function(ColorScheme?, ColorScheme?) builder;

  const DynamicColorBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return builder(null, null);
  }
}

typedef DynamicColorScheme = ColorScheme;
