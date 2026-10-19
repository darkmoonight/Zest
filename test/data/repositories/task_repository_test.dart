import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/data/repositories/category_repository.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late CategoryRepository repo;

  setUp(() async {
    isar = await openTestIsar();
    repo = CategoryRepository(isar);
  });

  tearDown(() async {
    if (isarCoreUnavailable) return;
    await closeTestIsar(isar);
  });

  test('existsByTitle returns true after create', () async {
    await repo.create(
      title: 'Unique',
      description: '',
      colorArgb: Colors.blue.toARGB32(),
      index: 0,
    );

    expect(await repo.existsByTitle('Unique'), isTrue);
    expect(await repo.existsByTitle('Missing'), isFalse);
  });

  test('getAll returns categories sorted by index', () async {
    await repo.create(
      title: 'Second',
      description: '',
      colorArgb: Colors.blue.toARGB32(),
      index: 1,
    );
    await repo.create(
      title: 'First',
      description: '',
      colorArgb: Colors.red.toARGB32(),
      index: 0,
    );

    final categories = await repo.getAll();
    expect(categories.map((t) => t.title), ['First', 'Second']);
  });

  test('updateArchiveStatusBatch archives all categories', () async {
    final first = await repo.create(
      title: 'A',
      description: '',
      colorArgb: Colors.blue.toARGB32(),
      index: 0,
    );
    final second = await repo.create(
      title: 'B',
      description: '',
      colorArgb: Colors.green.toARGB32(),
      index: 1,
    );

    await repo.updateArchiveStatusBatch([first, second], true);

    final reloaded = await repo.getAll();
    expect(reloaded.every((category) => category.archive), isTrue);
  });

  test('updateIndexes persists order', () async {
    final first = await repo.create(
      title: 'A',
      description: '',
      colorArgb: Colors.blue.toARGB32(),
      index: 0,
    );
    final second = await repo.create(
      title: 'B',
      description: '',
      colorArgb: Colors.green.toARGB32(),
      index: 1,
    );

    await repo.updateIndexes([second, first]);

    final reloaded = await repo.getAll();
    expect(reloaded.map((t) => t.title), ['B', 'A']);
  });

  test('delete removes category', () async {
    final category = await repo.create(
      title: 'Delete',
      description: '',
      colorArgb: Colors.blue.toARGB32(),
      index: 0,
    );

    await repo.delete(category);

    expect(await repo.getById(category.id), isNull);
  });
}
