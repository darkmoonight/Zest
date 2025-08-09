import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
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
  var now = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    loadTasksAndTodos();
  }

  void loadTasksAndTodos() {
    tasks.assignAll(isar.tasks.where().findAllSync());
    todos.assignAll(isar.todos.where().findAllSync());
  }

  // Tasks
  Future<void> addTask(String title, String desc, Color myColor) async {
    if (await isTaskDuplicate(title)) {
      EasyLoading.showError('duplicateCategory'.tr, duration: duration);
      return;
    }

    final taskCreate = Tasks(
      title: title,
      description: desc,
      taskColor: myColor.value32bit,
    );

    tasks.add(taskCreate);
    isar.writeTxnSync(() => isar.tasks.putSync(taskCreate));
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
    int oldIdx = tasks.indexOf(task);
    tasks[oldIdx] = task;
    tasks.refresh();
    todos.refresh();
  }

  Future<void> deleteTask(List<Tasks> taskList) async {
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      await cancelNotificationsForTask(task);
      deleteTodosForTask(task);
      deleteTaskFromDB(task);
    }
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

  void deleteTodosForTask(Tasks task) {
    todos.removeWhere((todo) => todo.task.value?.id == task.id);
    isar.writeTxnSync(
      () =>
          isar.todos.filter().task((q) => q.idEqualTo(task.id)).deleteAllSync(),
    );
  }

  void deleteTaskFromDB(Tasks task) {
    tasks.remove(task);
    isar.writeTxnSync(() => isar.tasks.deleteSync(task.id));
  }

  Future<void> archiveTask(List<Tasks> taskList) async {
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      await cancelNotificationsForTask(task);
      archiveTaskInDB(task);
    }
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
    List<Tasks> taskListCopy = List.from(taskList);

    for (var task in taskListCopy) {
      await createNotificationsForTask(task);
      noArchiveTaskInDB(task);
    }
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

  // Todos
  Future<void> addTodo(
    Tasks task,
    String title,
    String desc,
    String time,
    bool pined,
    Priority priority,
    List<String> tags,
  ) async {
    final date = parseDate(time);
    if (await isTodoDuplicate(task, title, date)) {
      EasyLoading.showError('duplicateTodo'.tr, duration: duration);
      return;
    }

    final todosCreate = Todos(
      name: title,
      description: desc,
      todoCompletedTime: date,
      fix: pined,
      createdTime: DateTime.now(),
      priority: priority,
      tags: tags,
    )..task.value = task;

    todos.add(todosCreate);
    isar.writeTxnSync(() {
      isar.todos.putSync(todosCreate);
      todosCreate.task.saveSync();
    });

    if (date != null && now.isBefore(date)) {
      NotificationShow().showNotification(
        todosCreate.id,
        todosCreate.name,
        todosCreate.description,
        date,
      );
    }
    EasyLoading.showSuccess('todoCreate'.tr, duration: duration);
  }

  DateTime? parseDate(String time) {
    if (time.isEmpty) return null;
    return timeformat == '12'
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
    isar.writeTxnSync(() => isar.todos.putSync(todo));
    todos.refresh();
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
    int oldIdx = todos.indexOf(todo);
    todos[oldIdx] = todo;
    todos.refresh();
  }

  Future<void> transferTodos(List<Todos> todoList, Tasks task) async {
    for (var todo in todoList) {
      isar.writeTxnSync(() {
        todo.task.value = task;
        isar.todos.putSync(todo);
        todo.task.saveSync();
      });
      refreshTodo(todo);
    }
    todos.refresh();
    tasks.refresh();
    EasyLoading.showSuccess('updateTodo'.tr, duration: duration);
  }

  Future<void> deleteTodo(List<Todos> todoList) async {
    List<Todos> todoListCopy = List.from(todoList);

    for (var todo in todoListCopy) {
      await cancelNotificationForTodo(todo);
      deleteTodoFromDB(todo);
    }
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

  void deleteTodoFromDB(Todos todo) {
    todos.remove(todo);
    isar.writeTxnSync(() => isar.todos.deleteSync(todo.id));
  }

  int createdAllTodos() {
    return todos.where((todo) => todo.task.value?.archive == false).length;
  }

  int completedAllTodos() {
    return todos
        .where((todo) => todo.task.value?.archive == false && todo.done == true)
        .length;
  }

  int createdAllTodosTask(Tasks task) {
    return todos.where((todo) => todo.task.value?.id == task.id).length;
  }

  int completedAllTodosTask(Tasks task) {
    return todos
        .where((todo) => todo.task.value?.id == task.id && todo.done == true)
        .length;
  }

  int countTotalTodosCalendar(DateTime date) {
    return todos
        .where(
          (todo) =>
              todo.done == false &&
              todo.todoCompletedTime != null &&
              todo.task.value?.archive == false &&
              isSameDay(date, todo.todoCompletedTime!),
        )
        .length;
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

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
