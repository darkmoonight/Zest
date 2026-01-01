import 'dart:ui';

extension ColorExtensions on Color {
  String toHexString() {
    final argb = toARGB32();
    return '#${argb.toRadixString(16).substring(2).toUpperCase()}';
  }
}
