import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zest/core/constants/app_constants.dart';

/// Opens Android system Settings screens for notification channels.
///
/// [flutter_local_notifications] can create channels but cannot open their
/// system UI. This helper launches the standard Settings intents instead.
class NotificationSettingsLauncher {
  /// Android Settings action for a single notification channel.
  static const String channelSettingsAction =
      'android.settings.CHANNEL_NOTIFICATION_SETTINGS';

  /// Android Settings action for the app's notification screen.
  static const String appSettingsAction =
      'android.settings.APP_NOTIFICATION_SETTINGS';

  /// Bundle extra key for the application package name.
  static const String extraAppPackage = 'android.provider.extra.APP_PACKAGE';

  /// Bundle extra key for the notification channel id.
  static const String extraChannelId = 'android.provider.extra.CHANNEL_ID';

  /// Builds the intent used to open a channel's system settings.
  static AndroidIntent channelSettingsIntent({
    required String channelId,
    required String packageName,
  }) {
    return AndroidIntent(
      action: channelSettingsAction,
      arguments: <String, dynamic>{
        extraAppPackage: packageName,
        extraChannelId: channelId,
      },
    );
  }

  /// Builds the intent used to open the app notification settings screen.
  static AndroidIntent appSettingsIntent({required String packageName}) {
    return AndroidIntent(
      action: appSettingsAction,
      arguments: <String, dynamic>{extraAppPackage: packageName},
    );
  }

  /// Opens system settings for the channel with [channelId].
  ///
  /// No-op on non-Android. Throws if the intent plugin fails to launch.
  static Future<void> openChannelSettings(String channelId) async {
    if (!_isAndroid) return;
    await channelSettingsIntent(
      channelId: channelId,
      packageName: await _packageName(),
    ).launch();
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
