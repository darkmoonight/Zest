import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/features/tasks/application/tasks_notifier.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';
import '../../helpers/provider_overrides.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late ProviderContainer container;
  late TaskRepository taskRepo;
  late FakeNotificationShow fakeNotifications;

  setUp(() async {
    isar = await openTestIsar();
    taskRepo = TaskRepository(isar);
    fakeNotifications = FakeNotificationShow();
    container = createTestContainer(
      isar: isar,
      fakeNotifications: fakeNotifications,
    );
    await readTodosNotifier(container);
  });

  tearDown(() async {
    container.dispose();
    await closeTestIsar(isar);
  });

  Future<TasksNotifier> notifier() => readTasksNotifier(container);

  test('archiveTask clears multi-selection', () async {
    final task = await createTestTask(isar, title: 'Archive');
    await createTestTodo(
      isar,
      task: task,
      name: 'Todo',
      completedTime: DateTime.now().add(const Duration(hours: 1)),
    );
    final tasksNotifier = await notifier();

    tasksNotifier.toggleMultiSelectionTask();
    tasksNotifier.doMultiSelectionTask(task);

    await tasksNotifier.archiveTask([task]);

    final state = container.read(tasksNotifierProvider);
    expect(state.isMultiSelectionTask, isFalse);
    expect(state.selectedTask, isEmpty);
    expect(state.tasks.first.archive, isTrue);
  });

  test('selectAllTasks selects filtered tasks', () async {
    await createTestTask(isar, title: 'A');
    await createTestTask(isar, title: 'B');
    final tasksNotifier = await notifier();

    tasksNotifier.selectAllTasks(select: true, archived: false);

    final state = container.read(tasksNotifierProvider);
    expect(state.selectedTask.length, 2);
    expect(tasksNotifier.areAllTasksSelected(archived: false), isTrue);
  });

  test('reorderTasks persists new order', () async {
    final first = await createTestTask(isar, title: 'A', index: 0);
    final second = await createTestTask(isar, title: 'B', index: 1);
    final tasksNotifier = await notifier();

    await tasksNotifier.reorderTasks(
      filteredTasks: [second, first],
      archived: false,
    );

    expect(container.read(tasksNotifierProvider).tasks.map((t) => t.title), [
      'B',
      'A',
    ]);
  });

  test('doMultiSelectionTask exits when last item is deselected', () async {
    final task = await createTestTask(isar, title: 'Only');
    final tasksNotifier = await notifier();

    tasksNotifier.toggleMultiSelectionTask();
    tasksNotifier.doMultiSelectionTask(task);
    tasksNotifier.doMultiSelectionTask(task);

    final state = container.read(tasksNotifierProvider);
    expect(state.isMultiSelectionTask, isFalse);
    expect(state.selectedTask, isEmpty);
  });

  test('noArchiveTask unarchives task and clears selection', () async {
    final task = await createTestTask(isar, title: 'Archived', archive: true);
    final tasksNotifier = await notifier();

    tasksNotifier.toggleMultiSelectionTask();
    tasksNotifier.doMultiSelectionTask(task);

    await tasksNotifier.noArchiveTask([task]);

    final state = container.read(tasksNotifierProvider);
    expect(state.isMultiSelectionTask, isFalse);
    expect(state.tasks.first.archive, isFalse);
  });

  test('deleteTask removes task and reindexes remaining tasks', () async {
    final first = await createTestTask(isar, title: 'A', index: 0);
    final second = await createTestTask(isar, title: 'B', index: 1);
    final tasksNotifier = await notifier();

    await tasksNotifier.deleteTask([first]);

    final titles = container
        .read(tasksNotifierProvider)
        .tasks
        .map((task) => task.title)
        .toList();
    expect(titles, ['B']);
    expect(container.read(tasksNotifierProvider).tasks.first.index, 0);
    expect(await taskRepo.getById(second.id), isNotNull);
  });

  test('archiveTask clears defaultCategoryId when archived', () async {
    final task = await createTestTask(isar, title: 'Default Inbox');
    final settings = container.read(settingsProvider);
    settings.defaultCategoryId = task.id;
    await container.read(settingsRepositoryProvider).save(settings);

    final tasksNotifier = await notifier();
    await tasksNotifier.archiveTask([task]);

    expect(container.read(settingsProvider).defaultCategoryId, isNull);
  });

  test('deleteTask clears defaultCategoryId when deleted', () async {
    final task = await createTestTask(isar, title: 'Default Inbox');
    final settings = container.read(settingsProvider);
    settings.defaultCategoryId = task.id;
    await container.read(settingsRepositoryProvider).save(settings);

    final tasksNotifier = await notifier();
    await tasksNotifier.deleteTask([task]);

    expect(container.read(settingsProvider).defaultCategoryId, isNull);
  });
}
