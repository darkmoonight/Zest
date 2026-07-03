import 'package:flutter/material.dart';

/// Trims and normalizes user-entered text in form fields.
class TextUtils {
  /// Normalizes whitespace in [controller] text in place.
  static void trimController(TextEditingController controller) {
    controller.text = _normalizeSpaces(controller.text);
  }

  /// Returns [text] with normalized line and inline whitespace.
  static String trimText(String text) {
    return _normalizeSpaces(text);
  }

  /// Collapses runs of spaces/tabs and trims empty leading/trailing lines.
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
