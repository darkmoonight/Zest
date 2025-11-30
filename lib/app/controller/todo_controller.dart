import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/utils/notification.dart';
import 'package:zest/main.dart';

class TodoController extends GetxController {
  final tasks = <Tasks>[].obs;
  final todos = <Todos>[].obs;

  final selectedTask = <Tasks>[].obs;
  final isMultiSelectionTask = false.obs;

  final selectedTodo = <Todos>[].obs;
  final isMultiSelectionTodo = false.obs;

  final isPop = true.obs;

  final duration = const Duration(milliseconds: 500);
  DateTime now = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    loadTasksAndTodos();
  }

  // ------------------------
  // Load
  // ------------------------
  void loadTasksAndTodos() {
    tasks.assignAll(isar.tasks.where().sortByIndex().findAllSync());
    todos.assignAll(isar.todos.where().sortByIndex().findAllSync());
    tasks.refresh();
    todos.refresh();
  }

  // ------------------------
  // Tasks
  // ------------------------
  Future<void> addTask(String title, String desc, Color myColor) async {
    if (await isTaskDuplicate(title)) {
      EasyLoading.showError('duplicateCategory'.tr, duration: duration);
      return;
    }

    final taskCreate = Tasks(
      title: title,
      description: desc,
      taskColor: myColor.value32bit,
      index: tasks.length,
    );

    isar.writeTxnSync(() => isar.tasks.putSync(taskCreate));

    tasks.add(taskCreate);
    tasks.refresh();

    EasyLoading.showSuccess('createCategory'.tr, duration: duration);
  }

  Future<bool> isTaskDuplicate(String title) async {
    final searchTask = isar.tasks.filter().titleEqualTo(title).findAllSync();
    return searchTask.isNotEmpty;
  }

  Future<void> updateTask(
    Tasks task,
    String title,
    String desc,
    Color myColor,
  ) async {
    isar.writeTxnSync(() {
      task.title = title;
      task.description = desc;
      task.taskColor = myColor.value32bit;
      isar.tasks.putSync(task);
    });

    refreshTask(task);
    EasyLoading.showSuccess('editCategory'.tr, duration: duration);
  }

  void refreshTask(Tasks task) {
    final idx = tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      tasks[idx] = task;
      tasks.refresh();
    } else {
      loadTasksAndTodos();
    }
    todos.refresh();
  }

  Future<void> deleteTask(List<Tasks> taskList) async {
    final copy = List<Tasks>.from(taskList);

    for (final t in copy) {
      await cancelNotificationsForTask(t);
      await deleteTodosForTask(t);
      deleteTaskFromDB(t);
    }

    reindexTasks();
    EasyLoading.showSuccess(
      'categoryDelete'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> cancelNotificationsForTask(Tasks task) async {
    final getTodo = isar.todos
        .filter()
        .task((q) => q.idEqualTo(task.id))
        .findAllSync();
    for (var todo in getTodo) {
      if (todo.todoCompletedTime != null &&
          todo.todoCompletedTime!.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.cancel(todo.id);
      }
    }
  }

  Future<void> deleteTodosForTask(Tasks task) async {
    final list = isar.todos
        .filter()
        .task((q) => q.idEqualTo(task.id))
        .findAllSync();

    for (var todo in list) {
      if (todo.todoCompletedTime != null &&
          todo.todoCompletedTime!.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.cancel(todo.id);
      }
    }

    for (var root in list) {
      await _deleteTodoRecursive(root);
    }

    loadTasksAndTodos();
  }

  void deleteTaskFromDB(Tasks task) {
    tasks.removeWhere((t) => t.id == task.id);
    isar.writeTxnSync(() => isar.tasks.deleteSync(task.id));
  }

  Future<void> archiveTask(List<Tasks> taskList) async {
    final copy = List<Tasks>.from(taskList);
    for (var task in copy) {
      await cancelNotificationsForTask(task);
      archiveTaskInDB(task);
    }
    loadTasksAndTodos();
    EasyLoading.showSuccess(
      'categoryArchive'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  void archiveTaskInDB(Tasks task) {
    isar.writeTxnSync(() {
      task.archive = true;
      isar.tasks.putSync(task);
    });
    tasks.refresh();
    todos.refresh();
  }

  Future<void> noArchiveTask(List<Tasks> taskList) async {
    final copy = List<Tasks>.from(taskList);
    for (var task in copy) {
      await createNotificationsForTask(task);
      noArchiveTaskInDB(task);
    }
    loadTasksAndTodos();
    EasyLoading.showSuccess(
      'noCategoryArchive'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> createNotificationsForTask(Tasks task) async {
    final getTodo = isar.todos
        .filter()
        .task((q) => q.idEqualTo(task.id))
        .findAllSync();
    for (var todo in getTodo) {
      if (todo.todoCompletedTime != null &&
          todo.todoCompletedTime!.isAfter(now)) {
        NotificationShow().showNotification(
          todo.id,
          todo.name,
          todo.description,
          todo.todoCompletedTime,
        );
      }
    }
  }

  void noArchiveTaskInDB(Tasks task) {
    isar.writeTxnSync(() {
      task.archive = false;
      isar.tasks.putSync(task);
    });
    tasks.refresh();
    todos.refresh();
  }

  // ------------------------
  // Todos
  // ------------------------
  Future<Todos?> addTodo(
    Tasks task,
    String title,
    String desc,
    String time,
    bool pined,
    Priority priority,
    List<String> tags, {
    Todos? parent,
  }) async {
    final date = parseDate(time);

    final todoCreate = Todos(
      name: title,
      description: desc,
      todoCompletedTime: date,
      fix: pined,
      createdTime: DateTime.now(),
      priority: priority,
      tags: tags,
      index: todos.length,
    )..task.value = task;

    if (parent != null) {
      todoCreate.parent.value = parent;
    }

    isar.writeTxnSync(() {
      isar.todos.putSync(todoCreate);
      todoCreate.task.saveSync();
      if (parent != null) {
        todoCreate.parent.saveSync();
      }
    });

    todos.add(todoCreate);
    todos.refresh();

    if (date != null && now.isBefore(date)) {
      NotificationShow().showNotification(
        todoCreate.id,
        todoCreate.name,
        todoCreate.description,
        date,
      );
    }

    EasyLoading.showSuccess('todoCreate'.tr, duration: duration);
    return todoCreate;
  }

  DateTime? parseDate(String time) {
    if (time.isEmpty) return null;
    return timeformat.value == '12'
        ? DateFormat.yMMMEd(locale.languageCode).add_jm().parse(time)
        : DateFormat.yMMMEd(locale.languageCode).add_Hm().parse(time);
  }

  Future<bool> isTodoDuplicate(Tasks task, String title, DateTime? date) async {
    final getTodos = isar.todos
        .filter()
        .nameEqualTo(title)
        .task((q) => q.idEqualTo(task.id))
        .todoCompletedTimeEqualTo(date)
        .findAllSync();
    return getTodos.isNotEmpty;
  }

  Future<void> updateTodoCheck(Todos todo) async {
    if (todo.done) {
      await _setDoneForSubtree(todo, true);
    } else {
      await _setDoneSingle(todo, false);
    }
  }

  Future<void> _setDoneForSubtree(Todos root, bool done) async {
    final ids = <int>{};
    final stack = <Todos>[root];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (!ids.add(node.id)) continue;
      final children = isar.todos
          .filter()
          .parent((q) => q.idEqualTo(node.id))
          .findAllSync();
      for (var c in children) {
        if (!ids.contains(c.id)) stack.add(c);
      }
    }

    if (ids.isEmpty) return;

    final nowLocal = DateTime.now();
    final toCancel = <int>[];

    isar.writeTxnSync(() {
      for (var id in ids) {
        final t = isar.todos.getSync(id);
        if (t == null) continue;
        t.done = done;
        isar.todos.putSync(t);
        if (t.todoCompletedTime != null &&
            t.todoCompletedTime!.isAfter(nowLocal)) {
          toCancel.add(t.id);
        }
      }
    });

    todos.assignAll(isar.todos.where().sortByIndex().findAllSync());
    todos.refresh();

    for (var id in toCancel) {
      await flutterLocalNotificationsPlugin.cancel(id);
    }
  }

  Future<void> _setDoneSingle(Todos todo, bool done) async {
    final nowLocal = DateTime.now();
    isar.writeTxnSync(() {
      todo.done = done;
      isar.todos.putSync(todo);
    });

    todos.assignAll(isar.todos.where().sortByIndex().findAllSync());
    todos.refresh();

    if (todo.todoCompletedTime != null &&
        todo.todoCompletedTime!.isAfter(nowLocal)) {
      if (done) {
        await flutterLocalNotificationsPlugin.cancel(todo.id);
      } else {
        if (!todo.done) {
          NotificationShow().showNotification(
            todo.id,
            todo.name,
            todo.description,
            todo.todoCompletedTime,
          );
        }
      }
    }
  }

  Future<void> updateTodo(
    Todos todo,
    Tasks task,
    String title,
    String desc,
    String time,
    bool pined,
    Priority priority,
    List<String> tags,
  ) async {
    final date = parseDate(time);
    isar.writeTxnSync(() {
      todo.name = title;
      todo.description = desc;
      todo.todoCompletedTime = date;
      todo.fix = pined;
      todo.priority = priority;
      todo.tags = tags;
      todo.task.value = task;
      isar.todos.putSync(todo);
      todo.task.saveSync();
    });

    refreshTodo(todo);

    if (date != null && now.isBefore(date)) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
      NotificationShow().showNotification(
        todo.id,
        todo.name,
        todo.description,
        date,
      );
    } else {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  void refreshTodo(Todos todo) {
    final idx = todos.indexWhere((t) => t.id == todo.id);
    if (idx != -1) {
      todos[idx] = todo;
      todos.refresh();
    } else {
      loadTasksAndTodos();
    }
  }

  Future<void> moveTodos(List<Todos> todoList, Tasks task) async {
    final copy = List<Todos>.from(todoList);

    final idsToUpdate = <int>{};

    for (final root in copy) {
      final stack = <Todos>[root];

      while (stack.isNotEmpty) {
        final node = stack.removeLast();
        if (!idsToUpdate.add(node.id)) continue;

        final children = isar.todos
            .filter()
            .parent((q) => q.idEqualTo(node.id))
            .findAllSync();

        for (var c in children) {
          if (!idsToUpdate.contains(c.id)) {
            stack.add(c);
          }
        }
      }
    }

    if (idsToUpdate.isEmpty) return;

    isar.writeTxnSync(() {
      for (var id in idsToUpdate) {
        final t = isar.todos.getSync(id);
        if (t == null) continue;
        t.task.value = task;
        isar.todos.putSync(t);
        t.task.saveSync();
      }
    });

    loadTasksAndTodos();

    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  Future<void> moveTodosToParent(List<Todos> rootList, Todos? newParent) async {
    final copy = List<Todos>.from(rootList);
    final idsToUpdate = <int>{};

    final Tasks? newTask = newParent?.task.value;

    for (final root in copy) {
      final stack = <Todos>[root];
      while (stack.isNotEmpty) {
        final node = stack.removeLast();
        if (!idsToUpdate.add(node.id)) continue;
        final children = isar.todos
            .filter()
            .parent((q) => q.idEqualTo(node.id))
            .findAllSync();
        for (var c in children) {
          if (!idsToUpdate.contains(c.id)) stack.add(c);
        }
      }
    }

    if (idsToUpdate.isEmpty) return;

    isar.writeTxnSync(() {
      for (var id in idsToUpdate) {
        final t = isar.todos.getSync(id);
        if (t == null) continue;

        if (copy.any((r) => r.id == id)) {
          t.parent.value = newParent;
        }

        if (newTask != null) {
          t.task.value = newTask;
        }

        isar.todos.putSync(t);

        t.task.saveSync();
        if (t.parent.value != null) t.parent.saveSync();
      }
    });

    loadTasksAndTodos();
    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  Future<void> deleteTodo(List<Todos> todoList) async {
    final copy = List<Todos>.from(todoList);

    for (var todo in copy) {
      await cancelNotificationForTodo(todo);
      await _deleteTodoRecursive(todo);
    }

    reindexTodos();
    EasyLoading.showSuccess(
      'todoDelete'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> cancelNotificationForTodo(Todos todo) async {
    if (todo.todoCompletedTime != null &&
        todo.todoCompletedTime!.isAfter(DateTime.now())) {
      await flutterLocalNotificationsPlugin.cancel(todo.id);
    }
  }

  Future<void> _deleteTodoRecursive(Todos root) async {
    final idsToDelete = <int>{};
    final stack = <Todos>[root];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      idsToDelete.add(node.id);

      final children = isar.todos
          .filter()
          .parent((q) => q.idEqualTo(node.id))
          .findAllSync();
      for (var c in children) {
        if (!idsToDelete.contains(c.id)) stack.add(c);
      }
    }

    for (var id in idsToDelete) {
      final t = isar.todos.getSync(id);
      if (t != null &&
          t.todoCompletedTime != null &&
          t.todoCompletedTime!.isAfter(DateTime.now())) {
        await flutterLocalNotificationsPlugin.cancel(t.id);
      }
    }

    isar.writeTxnSync(() {
      for (var id in idsToDelete) {
        isar.todos.deleteSync(id);
      }
    });

    todos.removeWhere((t) => idsToDelete.contains(t.id));
    todos.refresh();
  }

  void deleteTodoFromDB(Todos todo) {
    todos.removeWhere((t) => t.id == todo.id);
    isar.writeTxnSync(() => isar.todos.deleteSync(todo.id));
  }

  // ------------------------
  // Counters / Helpers
  // ------------------------
  int createdAllTodos() =>
      todos.where((todo) => todo.task.value?.archive == false).length;

  int completedAllTodos() => todos
      .where((todo) => todo.task.value?.archive == false && todo.done == true)
      .length;

  int createdAllTodosTask(Tasks task) =>
      todos.where((todo) => todo.task.value?.id == task.id).length;

  int completedAllTodosTask(Tasks task) => todos
      .where((todo) => todo.task.value?.id == task.id && todo.done == true)
      .length;

  int countTotalTodosCalendar(DateTime date) => todos
      .where(
        (todo) =>
            todo.done == false &&
            todo.todoCompletedTime != null &&
            todo.task.value?.archive == false &&
            isSameDay(date, todo.todoCompletedTime!),
      )
      .length;

  int createdAllTodosTodo(Todos parent) =>
      todos.where((child) => child.parent.value?.id == parent.id).length;

  int completedAllTodosTodo(Todos parent) => todos
      .where((child) => child.parent.value?.id == parent.id && child.done)
      .length;

  bool isSameDay(DateTime date1, DateTime date2) =>
      date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;

  // ------------------------
  // Reindex helpers
  // ------------------------
  void reindexTasks() {
    final all = tasks.toList();
    isar.writeTxnSync(() {
      for (int i = 0; i < all.length; i++) {
        all[i].index = i;
        isar.tasks.putSync(all[i]);
      }
    });
    tasks.assignAll(all);
    tasks.refresh();
  }

  void reindexTodos() {
    final all = todos.toList();
    isar.writeTxnSync(() {
      for (int i = 0; i < all.length; i++) {
        all[i].index = i;
        isar.todos.putSync(all[i]);
      }
    });
    todos.assignAll(all);
    todos.refresh();
  }

  // ------------------------
  // Multi-selection helpers
  // ------------------------
  void doMultiSelectionTask(Tasks task) {
    if (isMultiSelectionTask.isTrue) {
      isPop.value = false;
      if (selectedTask.contains(task)) {
        selectedTask.remove(task);
      } else {
        selectedTask.add(task);
      }

      if (selectedTask.isEmpty) {
        isMultiSelectionTask.value = false;
        isPop.value = true;
      }
    }
  }

  void doMultiSelectionTaskClear() {
    selectedTask.clear();
    isMultiSelectionTask.value = false;
    isPop.value = true;
  }

  void doMultiSelectionTodo(Todos todo) {
    if (isMultiSelectionTodo.isTrue) {
      isPop.value = false;
      if (selectedTodo.contains(todo)) {
        selectedTodo.remove(todo);
      } else {
        selectedTodo.add(todo);
      }

      if (selectedTodo.isEmpty) {
        isMultiSelectionTodo.value = false;
        isPop.value = true;
      }
    }
  }

  void doMultiSelectionTodoClear() {
    selectedTodo.clear();
    isMultiSelectionTodo.value = false;
    isPop.value = true;
  }
}
