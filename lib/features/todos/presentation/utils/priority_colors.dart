import 'package:material_ui/material_ui.dart';
import 'package:zest/domain/enums/priority.dart';

/// UI chip colors for [Priority] values.
extension PriorityColors on Priority {
  /// Optional chip color for this priority.
  Color? get color => switch (this) {
    Priority.high => Colors.red,
    Priority.medium => Colors.orange,
    Priority.low => Colors.green,
    Priority.none => null,
  };
}
