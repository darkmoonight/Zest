import 'dart:ui';

/// Color serialization helpers.
extension ColorExtensions on Color {
  /// Returns this color as an uppercase `#RRGGBB` hex string.
  String toHexString() {
    final argb = toARGB32();
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }
}
