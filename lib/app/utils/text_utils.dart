import 'package:flutter/material.dart';

class TextUtils {
  static void trimController(TextEditingController controller) {
    controller.text = _normalizeSpaces(controller.text);
  }

  static String trimText(String text) {
    return _normalizeSpaces(text);
  }

  static String _normalizeSpaces(String text) {
    final lines = text.split('\n');

    final normalizedLines = lines.map((line) {
      return line.trim().replaceAll(RegExp(r'[ \t]+'), ' ');
    }).toList();

    while (normalizedLines.isNotEmpty && normalizedLines.first.isEmpty) {
      normalizedLines.removeAt(0);
    }
    while (normalizedLines.isNotEmpty && normalizedLines.last.isEmpty) {
      normalizedLines.removeLast();
    }

    return normalizedLines.join('\n');
  }
}
