import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Opens Android system Settings for this app's notifications.
///
/// [flutter_local_notifications] can create channels but cannot open their
/// system UI. This helper launches the standard Settings intent instead.
class NotificationSettingsLauncher {
  /// Android Settings action for the app's notification screen.
  static const String appSettingsAction =
      'android.settings.APP_NOTIFICATION_SETTINGS';

  /// Bundle extra key for the application package name.
  static const String extraAppPackage = 'android.provider.extra.APP_PACKAGE';

  /// Builds the intent used to open the app notification settings screen.
  static AndroidIntent appSettingsIntent({required String packageName}) {
    return AndroidIntent(
      action: appSettingsAction,
      arguments: <String, dynamic>{extraAppPackage: packageName},
    );
  }

  /// Opens system settings for this app's notifications.
  ///
  /// No-op on non-Android. Throws if the intent plugin fails to launch.
  static Future<void> openAppSettings() async {
    if (!_isAndroid) return;
    await appSettingsIntent(packageName: await _packageName()).launch();
  }

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<String> _packageName() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.packageName.isNotEmpty) return info.packageName;
    } catch (e) {
      debugPrint('PackageInfo lookup failed: $e');
    }
    return AppConstants.androidPackageName;
  }
}
