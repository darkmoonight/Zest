import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Cached Android device capabilities used for theme and layout decisions.
class DeviceFeature {
  DeviceFeature._internal();

  static final DeviceFeature _singleton = DeviceFeature._internal();

  /// Returns the shared [DeviceFeature] instance.
  factory DeviceFeature() => _singleton;

  final _deviceInfoPlugin = DeviceInfoPlugin();
  AndroidDeviceInfo? _androidDeviceInfo;
  bool? _isEdgeToEdgeAvailableCache;

  /// Loads Android device info and edge-to-edge support once at startup.
  Future<void> init() async {
    try {
      _androidDeviceInfo = await _deviceInfoPlugin.androidInfo;
      _isEdgeToEdgeAvailableCache =
          _androidDeviceInfo != null && _androidDeviceInfo!.version.sdkInt > 28;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing device info: $e');
      }
      _isEdgeToEdgeAvailableCache = false;
    }
  }

  /// Whether transparent navigation bars are supported on this device.
  bool isEdgeToEdgeAvailable() => _isEdgeToEdgeAvailableCache ?? false;
}
