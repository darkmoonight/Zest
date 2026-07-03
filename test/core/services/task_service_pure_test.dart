import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/services/notification_service.dart';
import 'package:zest/core/services/task_service.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/data/repositories/task_repository.dart';
import 'package:zest/data/repositories/todo_repository.dart';

import '../../helpers/fake_notification_show.dart';
import '../../helpers/isar_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Isar isar;
  late TaskService service;
  late TaskRepository taskRepo;

  setUp(() async {
    isar = await openTestIsar();
    taskRepo = TaskRepository(isar);
    service = TaskService(
      taskRepo: taskRepo,
      todoRepo: TodoRepository(isar),
      notificationService: NotificationService(
        notificationShow: FakeNotificationShow(),
      ),
    );
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  group('TaskService.filterTasks', () {
    final tasks = [
      Tasks(id: 1, title: 'Active', description: 'One', taskColor: 1),
      Tasks(
        id: 2,
        title: 'Archived',
        description: 'Hidden',
        taskColor: 2,
        archive: true,
      ),
      Tasks(id: 3, title: 'Notes', description: 'Personal', taskColor: 3),
    ];

    test('filters archived flag', () {
      final active = service.filterTasks(tasks: tasks, archived: false);
      expect(active.map((t) => t.id), [1, 3]);

      final archived = service.filterTasks(tasks: tasks, archived: true);
      expect(archived.map((t) => t.id), [2]);
    });

    test('matches title and description case-insensitively', () {
      final filtered = service.filterTasks(
        tasks: tasks,
        archived: false,
        searchQuery: 'PERSONAL',
      );
      expect(filtered.map((t) => t.id), [3]);
    });
  });

  group('TaskService.reorderTasks', () {
    test('reorders only filtered subset and keeps other positions', () async {
      final taskA = await taskRepo.create(
        title: 'A',
        description: '',
        color: Colors.red,
        index: 0,
      );
      await taskRepo.create(
        title: 'B',
        description: '',
        color: Colors.green,
        index: 1,
      );
      final taskC = await taskRepo.create(
        title: 'C',
        description: '',
        color: Colors.blue,
        index: 2,
      );

      final allTasks = await taskRepo.getAll();
      final filtered = [taskC, taskA];

      await service.reorderTasks(allTasks: allTasks, filteredTasks: filtered);

      final reloaded = await taskRepo.getAll();
      expect(reloaded.map((t) => t.title), ['C', 'B', 'A']);
    });
  });
}
