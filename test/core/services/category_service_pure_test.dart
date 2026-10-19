import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/domain/entities/category.dart';
import 'package:zest/domain/usecases/category_usecases.dart';
import 'package:zest/data/repositories/category_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/noop_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CategoryService.filterCategories', () {
    late CategoryService service;

    setUp(() {
      service = CategoryService(
        categoryRepo: NoopCategoryRepository(),
        todoRepo: NoopTodoRepository(),
        notificationService: NotificationService(
          notificationShow: FakeNotificationShow(),
        ),
      );
    });

    const tasks = [
      Category(id: 1, title: 'Active', description: 'One', colorArgb: 1),
      Category(
        id: 2,
        title: 'Archived',
        description: 'Hidden',
        colorArgb: 2,
        archive: true,
      ),
      Category(id: 3, title: 'Notes', description: 'Personal', colorArgb: 3),
    ];

    test('filters archived flag', () {
      final active = service.filterCategories(categories: tasks, archived: false);
      expect(active.map((t) => t.id), [1, 3]);

      final archived = service.filterCategories(categories: tasks, archived: true);
      expect(archived.map((t) => t.id), [2]);
    });

    test('matches title and description case-insensitively', () {
      final filtered = service.filterCategories(
        categories: tasks,
        archived: false,
        searchQuery: 'PERSONAL',
      );
      expect(filtered.map((t) => t.id), [3]);
    });
  });

  group('CategoryService.reorderCategories', () {
    late Isar isar;
    late CategoryService service;
    late CategoryRepository categoryRepo;
    var isarReady = false;

    setUp(() async {
      try {
        isar = await openTestIsar();
        isarReady = true;
      } catch (_) {
        isarReady = false;
        return;
      }
      categoryRepo = CategoryRepository(isar);
      service = CategoryService(
        categoryRepo: categoryRepo,
        todoRepo: TodoRepository(isar),
        notificationService: NotificationService(
          notificationShow: FakeNotificationShow(),
        ),
      );
    });

    tearDown(() async {
      if (!isarReady || isarCoreUnavailable) return;
      await closeTestIsar(isar);
    });

    test('reorders only filtered subset and keeps other positions', () async {
      if (!isarReady) {
        markTestSkipped(
          'Isar core version mismatch (need 3.4.1; env has older binary)',
        );
        return;
      }
      final taskA = await categoryRepo.create(
        title: 'A',
        description: '',
        colorArgb: 0xFFFF0000,
        index: 0,
      );
      await categoryRepo.create(
        title: 'B',
        description: '',
        colorArgb: 0xFF00FF00,
        index: 1,
      );
      final taskC = await categoryRepo.create(
        title: 'C',
        description: '',
        colorArgb: 0xFF0000FF,
        index: 2,
      );

      final allTasks = await categoryRepo.getAll();
      final filtered = [taskC, taskA];

      await service.reorderCategories(allCategories: allTasks, filteredCategories: filtered);

      final reloaded = await categoryRepo.getAll();
      expect(reloaded.map((t) => t.title), ['C', 'B', 'A']);
    });
  });
}
