import 'package:flutter/material.dart';

class TextUtils {
  static void trimController(TextEditingController controller) {
    controller.text = _normalizeSpaces(controller.text);
  }

  static String trimText(String text) {
    return _normalizeSpaces(text);
  }

  static String _normalizeSpaces(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
