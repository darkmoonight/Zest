import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/caldav/caldav_pending_delete.dart';
import 'package:zest/core/caldav/vtodo_mapper.dart';
import 'package:zest/core/caldav/vtodo_record.dart';
import 'package:zest/data/models/db.dart';

void main() {
  group('VtodoMapper', () {
    test('maps priority both ways', () {
      expect(VtodoMapper.priorityToIcal(Priority.high), 1);
      expect(VtodoMapper.priorityToIcal(Priority.medium), 5);
      expect(VtodoMapper.priorityToIcal(Priority.low), 9);
      expect(VtodoMapper.priorityToIcal(Priority.none), 0);

      expect(VtodoMapper.priorityFromIcal(1), Priority.high);
      expect(VtodoMapper.priorityFromIcal(5), Priority.medium);
      expect(VtodoMapper.priorityFromIcal(9), Priority.low);
      expect(VtodoMapper.priorityFromIcal(0), Priority.none);
      expect(VtodoMapper.priorityFromIcal(null), Priority.none);
    });

    test('maps status both ways', () {
      expect(VtodoMapper.statusToIcal(TodoStatus.active), 'NEEDS-ACTION');
      expect(VtodoMapper.statusToIcal(TodoStatus.done), 'COMPLETED');
      expect(VtodoMapper.statusToIcal(TodoStatus.cancelled), 'CANCELLED');

      expect(VtodoMapper.statusFromIcal('COMPLETED'), TodoStatus.done);
      expect(VtodoMapper.statusFromIcal('cancelled'), TodoStatus.cancelled);
      expect(VtodoMapper.statusFromIcal('IN-PROCESS'), TodoStatus.active);
      expect(VtodoMapper.statusFromIcal('NEEDS-ACTION'), TodoStatus.active);
    });

    test('toRecord and applyToTodo round-trip due, tags, and completion', () {
      final due = DateTime.utc(2026, 8, 18, 12, 0);
      final completed = DateTime.utc(2026, 8, 18, 13, 0);
      final todo = Todos(
        id: 7,
        name: 'Buy milk',
        description: '2%',
        createdTime: DateTime.utc(2026, 1, 1),
        todoCompletedTime: due,
        todoCompletionTime: completed,
        priority: Priority.high,
        status: TodoStatus.done,
        tags: const ['groceries', 'home'],
      )..caldavUid = 'uid-1';

      final record = VtodoMapper.toRecord(todo);
      expect(record.uid, 'uid-1');
      expect(record.summary, 'Buy milk');
      expect(record.description, '2%');
      expect(record.due, due);
      expect(record.completed, completed);
      expect(record.priority, 1);
      expect(record.status, 'COMPLETED');
      expect(record.categories, ['groceries', 'home']);

      final other = Todos(
        id: 8,
        name: 'old',
        createdTime: DateTime.utc(2026, 1, 2),
      );
      VtodoMapper.applyToTodo(other, record);
      expect(other.name, 'Buy milk');
      expect(other.description, '2%');
      expect(other.dueAt, due);
      expect(other.completedAt, completed);
      expect(other.priority, Priority.high);
      expect(other.status, TodoStatus.done);
      expect(other.tags, ['groceries', 'home']);
      expect(other.caldavDirty, isFalse);
    });

    test('categoriesFromIcs reads CATEGORIES', () {
      const ics = 'BEGIN:VTODO\nSUMMARY:X\nCATEGORIES:a,b,c\nEND:VTODO';
      expect(VtodoMapper.categoriesFromIcs(ics), ['a', 'b', 'c']);
      expect(VtodoMapper.categoriesFromIcs(null), isEmpty);
    });

    test('allocateUid is stable once set', () {
      final todo = Todos(
        id: 3,
        name: 'n',
        createdTime: DateTime.utc(2020, 1, 1),
      );
      final first = VtodoMapper.allocateUid(todo);
      todo.caldavUid = first;
      expect(VtodoMapper.allocateUid(todo), first);
      expect(first, startsWith('zest-3-'));
    });
  });

  group('CalDavPendingDelete', () {
    test('round-trips JSON', () {
      const items = [
        CalDavPendingDelete(uid: 'a', href: 'https://x/a.ics', etag: 'e'),
        CalDavPendingDelete(uid: 'b', href: 'https://x/b.ics'),
      ];
      final encoded = CalDavPendingDelete.encode(items);
      final decoded = CalDavPendingDelete.decode(encoded);
      expect(decoded, hasLength(2));
      expect(decoded.first.uid, 'a');
      expect(decoded.first.etag, 'e');
      expect(decoded.last.href, 'https://x/b.ics');
      expect(CalDavPendingDelete.decode('not-json'), isEmpty);
    });
  });

  group('VtodoRecord', () {
    test('copyWith replaces selected fields', () {
      const original = VtodoRecord(uid: 'a', summary: 's');
      final copy = original.copyWith(summary: 't', etag: 'e');
      expect(copy.uid, 'a');
      expect(copy.summary, 't');
      expect(copy.etag, 'e');
    });
  });
}
