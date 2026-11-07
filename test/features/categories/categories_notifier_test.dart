import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/data/repositories/category_repository.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/provider_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late ProviderContainer container;
  late CategoryRepository categoryRepo;
  late FakeNotificationShow fakeNotifications;

  setUp(() async {
    isar = await openTestIsar();
    categoryRepo = CategoryRepository(isar);
    fakeNotifications = FakeNotificationShow();
    container = createTestContainer(
      isar: isar,
      fakeNotifications: fakeNotifications,
    );
    await readTodosNotifier(container);
  });

  tearDown(() async {
    if (isarCoreUnavailable) return;
    container.dispose();
    await closeTestIsar(isar);
  });

  Future<CategoriesNotifier> notifier() => readCategoriesNotifier(container);

  test('archiveTask clears multi-selection', () async {
    final category = await createTestTask(isar, title: 'Archive');
    await createTestTodo(
      isar,
      category: category,
      name: 'Todo',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    final categoriesNotifier = await notifier();

    categoriesNotifier.toggleMultiSelectionCategory();
    categoriesNotifier.doMultiSelectionCategory(category);

    await categoriesNotifier.archiveCategories([category]);

    final state = container.read(categoriesNotifierProvider);
    expect(state.isMultiSelectionCategory, isFalse);
    expect(state.selectedCategories, isEmpty);
    expect(state.categories.first.archive, isTrue);
  });

  test('selectAllCategories selects filtered tasks', () async {
    await createTestTask(isar, title: 'A');
    await createTestTask(isar, title: 'B');
    final categoriesNotifier = await notifier();

    categoriesNotifier.selectAllCategories(select: true, archived: false);

    final state = container.read(categoriesNotifierProvider);
    expect(state.selectedCategories.length, 2);
    expect(state.selectedCategoryIds.length, 2);
    expect(
      categoriesNotifier.areAllCategoriesSelected(archived: false),
      isTrue,
    );
  });

  test('multi-selection survives reload by id', () async {
    final category = await createTestTask(isar, title: 'Keep');
    await createTestTask(isar, title: 'Other');
    final categoriesNotifier = await notifier();

    categoriesNotifier.toggleMultiSelectionCategory();
    categoriesNotifier.doMultiSelectionCategory(category);
    final selectedId = category.id;

    await categoriesNotifier.reloadCategories();

    final state = container.read(categoriesNotifierProvider);
    expect(state.selectedCategoryIds, {selectedId});
    expect(state.selectedCategories.map((t) => t.id), [selectedId]);
    expect(state.isMultiSelectionCategory, isTrue);
  });

  test('reorderCategories persists new order', () async {
    final first = await createTestTask(isar, title: 'A', index: 0);
    final second = await createTestTask(isar, title: 'B', index: 1);
    final categoriesNotifier = await notifier();

    await categoriesNotifier.reorderCategories(
      filteredCategories: [second, first],
      archived: false,
    );

    expect(
      container.read(categoriesNotifierProvider).categories.map((t) => t.title),
      ['B', 'A'],
    );
  });

  test('doMultiSelectionCategory exits when last item is deselected', () async {
    final category = await createTestTask(isar, title: 'Only');
    final categoriesNotifier = await notifier();

    categoriesNotifier.toggleMultiSelectionCategory();
    categoriesNotifier.doMultiSelectionCategory(category);
    categoriesNotifier.doMultiSelectionCategory(category);

    final state = container.read(categoriesNotifierProvider);
    expect(state.isMultiSelectionCategory, isFalse);
    expect(state.selectedCategories, isEmpty);
  });

  test('noArchiveTask unarchives task and clears selection', () async {
    final category = await createTestTask(
      isar,
      title: 'Archived',
      archive: true,
    );
    final categoriesNotifier = await notifier();

    categoriesNotifier.toggleMultiSelectionCategory();
    categoriesNotifier.doMultiSelectionCategory(category);

    await categoriesNotifier.unarchiveCategories([category]);

    final state = container.read(categoriesNotifierProvider);
    expect(state.isMultiSelectionCategory, isFalse);
    expect(state.categories.first.archive, isFalse);
  });

  test('deleteTask removes task and reindexes remaining tasks', () async {
    final first = await createTestTask(isar, title: 'A', index: 0);
    final second = await createTestTask(isar, title: 'B', index: 1);
    final categoriesNotifier = await notifier();

    await categoriesNotifier.deleteCategories([first]);

    final titles = container
        .read(categoriesNotifierProvider)
        .categories
        .map((category) => category.title)
        .toList();
    expect(titles, ['B']);
    expect(
      container.read(categoriesNotifierProvider).categories.first.index,
      0,
    );
    expect(await categoryRepo.getById(second.id), isNotNull);
  });

  test('archiveTask clears defaultCategoryId when archived', () async {
    final category = await createTestTask(isar, title: 'Default Inbox');
    final live = container.read(liveSettingsProvider);
    live.defaultCategoryId = category.id;

    final categoriesNotifier = await notifier();
    await categoriesNotifier.archiveCategories([category]);

    expect(container.read(liveSettingsProvider).defaultCategoryId, isNull);
  });

  test('deleteTask clears defaultCategoryId when deleted', () async {
    final category = await createTestTask(isar, title: 'Default Inbox');
    final live = container.read(liveSettingsProvider);
    live.defaultCategoryId = category.id;

    final categoriesNotifier = await notifier();
    await categoriesNotifier.deleteCategories([category]);

    expect(container.read(liveSettingsProvider).defaultCategoryId, isNull);
  });
}
