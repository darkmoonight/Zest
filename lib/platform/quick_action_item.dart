/// Launcher shortcut item registered with the platform quick-actions API.
class QuickActionItem {
  /// Creates a quick-action shortcut definition.
  const QuickActionItem({
    required this.type,
    required this.localizedTitle,
    required this.icon,
  });

  /// Stable action type id passed to shortcut handlers.
  final String type;

  /// User-visible shortcut title in the current locale.
  final String localizedTitle;

  /// Platform drawable resource name for the shortcut icon.
  final String icon;

  @override
  /// Whether this item represents the same [type] as [other].
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickActionItem &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  /// Hash code based on [type].
  int get hashCode => type.hashCode;
}
