import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/main.dart';

class ThemeController extends GetxController {
  ThemeMode get theme => _getThemeMode();

  Future<void> saveOledTheme(bool isOled) async =>
      await _updateSetting((settings) => settings.amoledTheme = isOled);

  Future<void> saveMaterialTheme(bool isMaterial) async =>
      await _updateSetting((settings) => settings.materialColor = isMaterial);

  Future<void> saveTheme(String themeMode) async =>
      await _updateSetting((settings) => settings.theme = themeMode);

  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  void changeThemeMode(ThemeMode themeMode) => Get.changeThemeMode(themeMode);

  ThemeMode _getThemeMode() {
    switch (settings.theme) {
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> _updateSetting(void Function(Settings) update) async {
    update(settings);
    await isar.writeTxn(() => isar.settings.put(settings));
  }
}
