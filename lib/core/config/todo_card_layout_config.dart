import 'dart:convert';

/// Metadata field ids shown below the title on a todo list card.
enum TodoCardFieldId {
  /// Item description text.
  description,

  /// Category chip for task lists.
  category,

  /// Created timestamp row.
  created,

  /// Deadline / due date row.
  deadline,

  /// Priority chip.
  priority,

  /// Tag chips row.
  tags,

  /// When the item was marked done or cancelled.
  completed,
}

/// Visibility and position of one todo card metadata field.
class TodoCardLayoutEntry {
  /// Creates a layout entry.
  const TodoCardLayoutEntry({required this.id, required this.visible});

  /// Field identifier.
  final TodoCardFieldId id;

  /// Whether the field is shown when applicable.
  final bool visible;

  /// Returns a copy with selected fields replaced.
  TodoCardLayoutEntry copyWith({TodoCardFieldId? id, bool? visible}) {
    return TodoCardLayoutEntry(
      id: id ?? this.id,
      visible: visible ?? this.visible,
    );
  }
}

/// Encodes and decodes [Settings.todoCardLayout] JSON.
abstract final class TodoCardLayoutConfig {
  /// Default order with every metadata field visible.
  static const List<TodoCardLayoutEntry> defaultLayout = [
    TodoCardLayoutEntry(id: TodoCardFieldId.description, visible: true),
    TodoCardLayoutEntry(id: TodoCardFieldId.category, visible: true),
    TodoCardLayoutEntry(id: TodoCardFieldId.created, visible: true),
    TodoCardLayoutEntry(id: TodoCardFieldId.deadline, visible: true),
    TodoCardLayoutEntry(id: TodoCardFieldId.priority, visible: true),
    TodoCardLayoutEntry(id: TodoCardFieldId.tags, visible: true),
    TodoCardLayoutEntry(id: TodoCardFieldId.completed, visible: true),
  ];

  /// Default JSON stored on fresh installs and invalid restores.
  static String get defaultJson => encode(defaultLayout);

  /// Parses [json], preserving stored order for known fields.
  ///
  /// Invalid input falls back to [defaultLayout]. Missing newer fields are
  /// appended from [defaultLayout] so existing users automatically pick them up.
  static List<TodoCardLayoutEntry> decode(String json) {
    if (json.trim().isEmpty) return List.of(defaultLayout);
    try {
      final parsed = jsonDecode(json);
      if (parsed is! List || parsed.isEmpty) return List.of(defaultLayout);
      final entries = <TodoCardLayoutEntry>[];
      final seen = <TodoCardFieldId>{};
      for (final item in parsed) {
        if (item is! Map) continue;
        final id = _parseId(item['id']);
        if (id == null || seen.contains(id)) continue;
        seen.add(id);
        entries.add(
          TodoCardLayoutEntry(
            id: id,
            visible: item['visible'] as bool? ?? true,
          ),
        );
      }
      if (entries.isEmpty) return List.of(defaultLayout);
      for (final entry in defaultLayout) {
        if (seen.add(entry.id)) entries.add(entry);
      }
      return entries;
    } catch (_) {
      return List.of(defaultLayout);
    }
  }

  /// Serializes [entries] for [Settings.todoCardLayout].
  static String encode(List<TodoCardLayoutEntry> entries) {
    return jsonEncode([
      for (final entry in entries)
        {'id': entry.id.name, 'visible': entry.visible},
    ]);
  }

  /// Visible fields in display order.
  static List<TodoCardFieldId> visibleIds(List<TodoCardLayoutEntry> entries) {
    return [
      for (final entry in entries)
        if (entry.visible) entry.id,
    ];
  }

  /// Whether the card renderer should combine category and priority into one row.
  static bool mergeCategoryPriority(List<TodoCardLayoutEntry> entries) {
    var category = false;
    var priority = false;
    for (final entry in entries) {
      if (!entry.visible) continue;
      if (entry.id == TodoCardFieldId.category) category = true;
      if (entry.id == TodoCardFieldId.priority) priority = true;
    }
    return category && priority;
  }

  static TodoCardFieldId? _parseId(Object? value) {
    if (value is! String) return null;
    for (final id in TodoCardFieldId.values) {
      if (id.name == value) return id;
    }
    return null;
  }
}
