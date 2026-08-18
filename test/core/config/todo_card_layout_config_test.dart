import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/config/todo_card_layout_config.dart';

void main() {
  group('TodoCardLayoutConfig', () {
    test('default round-trips through encode and decode', () {
      final encoded = TodoCardLayoutConfig.encode(
        TodoCardLayoutConfig.defaultLayout,
      );
      final decoded = TodoCardLayoutConfig.decode(encoded);

      expect(decoded.length, TodoCardLayoutConfig.defaultLayout.length);
      for (var i = 0; i < decoded.length; i++) {
        expect(decoded[i].id, TodoCardLayoutConfig.defaultLayout[i].id);
        expect(
          decoded[i].visible,
          TodoCardLayoutConfig.defaultLayout[i].visible,
        );
      }
    });

    test('every default field is visible', () {
      expect(
        TodoCardLayoutConfig.defaultLayout.every((entry) => entry.visible),
        isTrue,
      );
      expect(
        TodoCardLayoutConfig.visibleIds(TodoCardLayoutConfig.defaultLayout),
        TodoCardFieldId.values,
      );
    });

    test('empty json uses defaults', () {
      final decoded = TodoCardLayoutConfig.decode('');
      expect(decoded, TodoCardLayoutConfig.defaultLayout);
    });

    test('invalid json uses defaults', () {
      final decoded = TodoCardLayoutConfig.decode('{not json');
      expect(decoded, TodoCardLayoutConfig.defaultLayout);
    });

    test('unknown field ids are skipped', () {
      final decoded = TodoCardLayoutConfig.decode(
        '[{"id":"unknown","visible":true},{"id":"tags","visible":false}]',
      );
      expect(decoded.first.id, TodoCardFieldId.tags);
      expect(decoded.first.visible, isFalse);
      expect(decoded.length, TodoCardLayoutConfig.defaultLayout.length);
    });

    test('missing stored fields are appended from defaults', () {
      final decoded = TodoCardLayoutConfig.decode(
        '[{"id":"tags","visible":false},{"id":"created","visible":true}]',
      );

      expect(decoded.length, TodoCardLayoutConfig.defaultLayout.length);
      expect(decoded[0].id, TodoCardFieldId.tags);
      expect(decoded[0].visible, isFalse);
      expect(decoded[1].id, TodoCardFieldId.created);
      expect(
        decoded.any((entry) => entry.id == TodoCardFieldId.completed),
        isTrue,
      );
    });

    test('duplicate stored fields keep the first occurrence', () {
      final decoded = TodoCardLayoutConfig.decode(
        '[{"id":"tags","visible":false},{"id":"tags","visible":true}]',
      );

      final tags = decoded.where((entry) => entry.id == TodoCardFieldId.tags);
      expect(tags.length, 1);
      expect(tags.single.visible, isFalse);
    });

    test('visibleIds returns only visible fields in order', () {
      final ids = TodoCardLayoutConfig.visibleIds([
        const TodoCardLayoutEntry(id: TodoCardFieldId.created, visible: false),
        const TodoCardLayoutEntry(id: TodoCardFieldId.tags, visible: true),
        const TodoCardLayoutEntry(id: TodoCardFieldId.deadline, visible: true),
      ]);
      expect(ids, [TodoCardFieldId.tags, TodoCardFieldId.deadline]);
    });

    test('mergeCategoryPriority is true when both are visible', () {
      final merged = TodoCardLayoutConfig.mergeCategoryPriority([
        const TodoCardLayoutEntry(id: TodoCardFieldId.category, visible: true),
        const TodoCardLayoutEntry(id: TodoCardFieldId.priority, visible: true),
      ]);
      expect(merged, isTrue);
    });

    test('mergeCategoryPriority is false when one is hidden', () {
      final merged = TodoCardLayoutConfig.mergeCategoryPriority([
        const TodoCardLayoutEntry(id: TodoCardFieldId.category, visible: true),
        const TodoCardLayoutEntry(id: TodoCardFieldId.priority, visible: false),
      ]);
      expect(merged, isFalse);
    });
  });
}
