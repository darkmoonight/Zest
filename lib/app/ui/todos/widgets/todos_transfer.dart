import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/utils/show_dialog.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/main.dart';

enum TransferMode { category, todo }

class TodosTransfer extends StatefulWidget {
  const TodosTransfer({super.key, required this.text, required this.todos});
  final String text;
  final List<Todos> todos;

  @override
  State<TodosTransfer> createState() => _TodosTransferState();
}

class _TodosTransferState extends State<TodosTransfer> {
  final todoController = Get.put(TodoController());
  final FocusNode focusNode = FocusNode();

  TransferMode _mode = TransferMode.category;

  Tasks? selectedTask;
  Todos? selectedTodo;

  final formKeyTransfer = GlobalKey<FormState>();
  final TextEditingController transferTaskController = TextEditingController();
  final TextEditingController transferTodoController = TextEditingController();

  late final _EditingController controller;

  @override
  void initState() {
    super.initState();
    controller = _EditingController(selectedTask, selectedTodo);
  }

  @override
  void dispose() {
    transferTaskController.dispose();
    transferTodoController.dispose();
    controller.dispose();
    super.dispose();
  }

  Future<void> onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) return;
    if (!controller.canCompose.value) {
      Get.back();
      return;
    }

    final shouldPop = await showAdaptiveDialogTextIsNotEmpty(
      context: context,
      onPressed: () {
        transferTaskController.clear();
        transferTodoController.clear();
        Get.back(result: true);
      },
    );

    if (shouldPop == true && mounted) Get.back();
  }

  Future<List<Tasks>> getTaskAll(String pattern) async {
    final getTask = isar.tasks.filter().archiveEqualTo(false).findAllSync();
    return getTask.where((element) {
      final title = element.title.toLowerCase();
      final query = pattern.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  Set<int> _collectExcludedIds() {
    final excluded = <int>{};
    final roots = widget.todos;
    final stack = <Todos>[];
    for (var r in roots) {
      if (!excluded.contains(r.id)) {
        stack.add(r);
      }
      while (stack.isNotEmpty) {
        final node = stack.removeLast();
        if (!excluded.add(node.id)) continue;
        final children = isar.todos
            .filter()
            .parent((q) => q.idEqualTo(node.id))
            .findAllSync();
        for (var c in children) {
          if (!excluded.contains(c.id)) stack.add(c);
        }
      }
    }
    return excluded;
  }

  Future<List<Todos>> getTodoAll(String pattern) async {
    final all = isar.todos.where().findAllSync();
    final query = pattern.toLowerCase();
    final excluded = _collectExcludedIds();
    return all.where((t) {
      if (excluded.contains(t.id)) return false;
      final name = t.name.toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _onTaskSelected(Tasks selection) {
    transferTaskController.text = selection.title;
    selectedTask = selection;
    controller.task.value = selectedTask;
    setState(() {});
    focusNode.unfocus();
  }

  void _onTodoSelected(Todos selection) {
    transferTodoController.text = selection.name;
    selectedTodo = selection;
    controller.todo.value = selectedTodo;
    setState(() {});
    focusNode.unfocus();
  }

  void onPressed() {
    if (!formKeyTransfer.currentState!.validate()) return;

    if (_mode == TransferMode.category) {
      if (selectedTask != null) {
        todoController.moveTodos(widget.todos, selectedTask!);
        todoController.doMultiSelectionTodoClear();
        transferTaskController.clear();
        Get.back();
      }
    } else {
      if (selectedTodo != null) {
        todoController.moveTodosToParent(widget.todos, selectedTodo);
        todoController.doMultiSelectionTodoClear();
        transferTodoController.clear();
        Get.back();
      }
    }
  }

  Widget _buildModeToggle() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    child: Row(
      spacing: 8,
      children: [
        ChoiceChip(
          label: Text('categories'.tr),
          selected: _mode == TransferMode.category,
          onSelected: (s) {
            setState(() {
              _mode = TransferMode.category;
              selectedTodo = null;
              transferTodoController.clear();
              controller.todo.value = null;
            });
          },
        ),
        ChoiceChip(
          label: Text('todo'.tr),
          selected: _mode == TransferMode.todo,
          onSelected: (s) {
            setState(() {
              _mode = TransferMode.todo;
              selectedTask = null;
              transferTaskController.clear();
              controller.task.value = null;
            });
          },
        ),
      ],
    ),
  );

  Widget _buildTaskField(BuildContext context) => RawAutocomplete<Tasks>(
    focusNode: focusNode,
    optionsViewOpenDirection: OptionsViewOpenDirection.up,
    textEditingController: transferTaskController,
    fieldViewBuilder: _buildTaskFieldView,
    optionsBuilder: _buildTaskOptions,
    onSelected: _onTaskSelected,
    displayStringForOption: (Tasks option) => option.title,
    optionsViewBuilder: _buildTaskOptionsView,
  );

  Widget _buildTaskFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    VoidCallback onFieldSubmitted,
  ) => MyTextForm(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    controller: transferTaskController,
    focusNode: focusNode,
    labelText: 'selectCategory'.tr,
    type: TextInputType.text,
    icon: const Icon(IconsaxPlusLinear.folder_2),
    iconButton: transferTaskController.text.isNotEmpty
        ? IconButton(
            icon: const Icon(IconsaxPlusLinear.close_square, size: 18),
            onPressed: () {
              transferTaskController.clear();
              selectedTask = null;
              controller.task.value = null;
              setState(() {});
            },
          )
        : null,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'selectCategory'.tr;
      }
      return null;
    },
  );

  Future<Iterable<Tasks>> _buildTaskOptions(
    TextEditingValue textEditingValue,
  ) async => await getTaskAll(textEditingValue.text);

  Widget _buildTaskOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            final Tasks task = options.elementAt(index);
            return InkWell(
              onTap: () => onSelected(task),
              child: ListTile(
                title: Text(task.title, style: context.textTheme.labelLarge),
                trailing: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(task.taskColor),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _buildTodoField(BuildContext context) => RawAutocomplete<Todos>(
    focusNode: focusNode,
    optionsViewOpenDirection: OptionsViewOpenDirection.up,
    textEditingController: transferTodoController,
    fieldViewBuilder: _buildTodoFieldView,
    optionsBuilder: _buildTodoOptions,
    onSelected: _onTodoSelected,
    displayStringForOption: (Todos option) => option.name,
    optionsViewBuilder: _buildTodoOptionsView,
  );

  Widget _buildTodoFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    VoidCallback onFieldSubmitted,
  ) => MyTextForm(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    controller: transferTodoController,
    focusNode: focusNode,
    labelText: 'selectTodoParent'.tr,
    type: TextInputType.text,
    icon: const Icon(IconsaxPlusLinear.task_square),
    iconButton: transferTodoController.text.isNotEmpty
        ? IconButton(
            icon: const Icon(IconsaxPlusLinear.close_square, size: 18),
            onPressed: () {
              transferTodoController.clear();
              selectedTodo = null;
              controller.todo.value = null;
              setState(() {});
            },
          )
        : null,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'selectTodoParent'.tr;
      }
      return null;
    },
  );

  Future<Iterable<Todos>> _buildTodoOptions(
    TextEditingValue textEditingValue,
  ) async => await getTodoAll(textEditingValue.text);

  Widget _buildTodoOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Todos> onSelected,
    Iterable<Todos> options,
  ) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 4,
        child: ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: options.length,
          itemBuilder: (BuildContext context, int index) {
            final Todos todo = options.elementAt(index);
            return InkWell(
              onTap: () => onSelected(todo),
              child: ListTile(
                title: Text(todo.name, style: context.textTheme.labelLarge),
                subtitle: todo.task.value != null
                    ? Text(
                        todo.task.value!.title,
                        style: context.textTheme.bodySmall,
                      )
                    : null,
                trailing: todo.task.value != null
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Color(todo.task.value!.taskColor),
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    ),
  );

  Widget _buildSubmitButton(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller.canCompose,
    builder: (context, canCompose, _) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: MyTextButton(
        text: 'ready'.tr,
        onPressed: canCompose ? onPressed : null,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: onPopInvokedWithResult,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Form(
        key: formKeyTransfer,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 7),
                  child: Text(
                    widget.text,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                _buildModeToggle(),
                if (_mode == TransferMode.category) _buildTaskField(context),
                if (_mode == TransferMode.todo) _buildTodoField(context),
                _buildSubmitButton(context),
                const Gap(10),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _EditingController extends ChangeNotifier {
  _EditingController(Tasks? initialTask, Todos? initialTodo) {
    task.value = initialTask;
    todo.value = initialTodo;
    task.addListener(_updateCanCompose);
    todo.addListener(_updateCanCompose);
  }

  final task = ValueNotifier<Tasks?>(null);
  final todo = ValueNotifier<Todos?>(null);
  final _canCompose = ValueNotifier(false);

  ValueListenable<bool> get canCompose => _canCompose;

  void _updateCanCompose() =>
      _canCompose.value = (task.value != null) || (todo.value != null);

  @override
  void dispose() {
    task.removeListener(_updateCanCompose);
    todo.removeListener(_updateCanCompose);
    super.dispose();
  }
}
