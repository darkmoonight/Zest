import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/data/repositories/task_repository.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late TaskRepository repo;

  setUp(() async {
    isar = await openTestIsar();
    repo = TaskRepository(isar);
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('existsByTitle returns true after create', () async {
    await repo.create(
      title: 'Unique',
      description: '',
      color: Colors.blue,
      index: 0,
    );

    expect(await repo.existsByTitle('Unique'), isTrue);
    expect(await repo.existsByTitle('Missing'), isFalse);
  });

  test('getAll returns tasks sorted by index', () async {
    await repo.create(
      title: 'Second',
      description: '',
      color: Colors.blue,
      index: 1,
    );
    await repo.create(
      title: 'First',
      description: '',
      color: Colors.red,
      index: 0,
    );

    final tasks = await repo.getAll();
    expect(tasks.map((t) => t.title), ['First', 'Second']);
  });

  test('updateArchiveStatusBatch archives all tasks', () async {
    final first = await repo.create(
      title: 'A',
      description: '',
      color: Colors.blue,
      index: 0,
    );
    final second = await repo.create(
      title: 'B',
      description: '',
      color: Colors.green,
      index: 1,
    );

    await repo.updateArchiveStatusBatch([first, second], true);

    final reloaded = await repo.getAll();
    expect(reloaded.every((task) => task.archive), isTrue);
  });

  test('updateIndexes persists order', () async {
    final first = await repo.create(
      title: 'A',
      description: '',
      color: Colors.blue,
      index: 0,
    );
    final second = await repo.create(
      title: 'B',
      description: '',
      color: Colors.green,
      index: 1,
    );

    await repo.updateIndexes([second, first]);

    final reloaded = await repo.getAll();
    expect(reloaded.map((t) => t.title), ['B', 'A']);
  });

  test('delete removes task', () async {
    final task = await repo.create(
      title: 'Delete',
      description: '',
      color: Colors.blue,
      index: 0,
    );

    await repo.delete(task);

    expect(await repo.getById(task.id), isNull);
  });
}
