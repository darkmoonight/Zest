import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/responsive_utils.dart';
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

class _TodosTransferState extends State<TodosTransfer>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());

  final FocusNode taskFocusNode = FocusNode();
  final FocusNode todoFocusNode = FocusNode();

  TransferMode _mode = TransferMode.category;

  Tasks? selectedTask;
  Todos? selectedTodo;

  final formKeyTransfer = GlobalKey<FormState>();
  final TextEditingController transferTaskController = TextEditingController();
  final TextEditingController transferTodoController = TextEditingController();

  late final _EditingController controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = _EditingController(selectedTask, selectedTodo);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    transferTaskController.dispose();
    transferTodoController.dispose();
    taskFocusNode.dispose();
    todoFocusNode.dispose();
    controller.dispose();
    _animationController.dispose();
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
    setState(() {
      transferTaskController.text = selection.title;
      selectedTask = selection;
      controller.task.value = selectedTask;
    });
    taskFocusNode.unfocus();
  }

  void _onTodoSelected(Todos selection) {
    setState(() {
      transferTodoController.text = selection.name;
      selectedTodo = selection;
      controller.todo.value = selectedTodo;
    });
    todoFocusNode.unfocus();
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

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final maxWidth = isMobile ? double.infinity : 500.0;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight:
              MediaQuery.of(context).size.height * (isMobile ? 0.70 : 0.65),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDragHandle(colorScheme, isMobile),
            _buildHeader(colorScheme, padding),
            Divider(
              height: 1,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Flexible(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Form(
                      key: formKeyTransfer,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(padding * 1.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildInfoCard(colorScheme, padding),
                                  SizedBox(height: padding * 1.5),
                                  _buildModeSection(colorScheme, padding),
                                  SizedBox(height: padding * 1.5),
                                  _buildDestinationSection(
                                    colorScheme,
                                    padding,
                                  ),
                                  SizedBox(height: padding),
                                ],
                              ),
                            ),
                          ),
                          _buildSubmitButton(colorScheme, padding),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle(ColorScheme colorScheme, bool isMobile) {
    if (!isMobile) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 32,
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 1.5,
        vertical: padding,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconsaxPlusBold.convert,
              size: 24,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          SizedBox(width: padding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'transferTodoHint'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.info_circle,
            size: 20,
            color: colorScheme.primary,
          ),
          SizedBox(width: padding),
          Expanded(
            child: Text(
              '${'movingTodos'.tr}: ${widget.todos.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSection(ColorScheme colorScheme, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transferMode'.tr,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          ),
        ),
        SizedBox(height: padding),
        _buildModeToggle(colorScheme),
      ],
    );
  }

  Widget _buildModeToggle(ColorScheme colorScheme) {
    return SegmentedButton<TransferMode>(
      segments: [
        ButtonSegment<TransferMode>(
          value: TransferMode.category,
          label: Text('categories'.tr),
          icon: Icon(IconsaxPlusLinear.folder_2, size: 18),
        ),
        ButtonSegment<TransferMode>(
          value: TransferMode.todo,
          label: Text('todo'.tr),
          icon: Icon(IconsaxPlusLinear.task_square, size: 18),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (Set<TransferMode> newSelection) {
        final newMode = newSelection.first;
        if (_mode == newMode) return;

        setState(() {
          _mode = newMode;

          if (_mode == TransferMode.category) {
            selectedTodo = null;
            transferTodoController.clear();
            controller.todo.value = null;
            todoFocusNode.unfocus();
          } else {
            selectedTask = null;
            transferTaskController.clear();
            controller.task.value = null;
            taskFocusNode.unfocus();
          }
        });
      },
      style: ButtonStyle(visualDensity: VisualDensity.comfortable),
    );
  }

  Widget _buildDestinationSection(ColorScheme colorScheme, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              _mode == TransferMode.category
                  ? IconsaxPlusBold.folder_2
                  : IconsaxPlusBold.task_square,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'destination'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ],
        ),
        SizedBox(height: padding),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.05),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _mode == TransferMode.category
              ? _buildTaskField(context, colorScheme)
              : _buildTodoField(context, colorScheme),
        ),
      ],
    );
  }

  Widget _buildTaskField(BuildContext context, ColorScheme colorScheme) {
    return RawAutocomplete<Tasks>(
      key: const ValueKey('task'),
      focusNode: taskFocusNode,
      textEditingController: transferTaskController,
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
          _buildTaskFieldView(context, controller, focusNode, colorScheme),
      optionsBuilder: _buildTaskOptions,
      onSelected: _onTaskSelected,
      displayStringForOption: (Tasks option) => option.title,
      optionsViewBuilder: _buildTaskOptionsView,
    );
  }

  Future<Iterable<Tasks>> _buildTaskOptions(
    TextEditingValue textEditingValue,
  ) async => await getTaskAll(textEditingValue.text);

  Widget _buildTaskFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    ColorScheme colorScheme,
  ) {
    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: fieldTextEditingController,
      focusNode: fieldFocusNode,
      labelText: 'selectCategory'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.folder_2, color: colorScheme.primary),
      iconButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fieldTextEditingController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                IconsaxPlusLinear.close_circle,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  fieldTextEditingController.clear();
                  selectedTask = null;
                  controller.task.value = null;
                });
              },
            ),
          IconButton(
            icon: Icon(
              fieldFocusNode.hasFocus
                  ? IconsaxPlusLinear.arrow_up_1
                  : IconsaxPlusLinear.arrow_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              if (fieldFocusNode.hasFocus) {
                fieldFocusNode.unfocus();
              } else {
                fieldFocusNode.requestFocus();
              }
              setState(() {});
            },
          ),
        ],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'selectCategory'.tr;
        }
        return null;
      },
    );
  }

  Widget _buildTaskOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final Tasks task = options.elementAt(index);
                return InkWell(
                  onTap: () => onSelected(task),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(task.taskColor),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodoField(BuildContext context, ColorScheme colorScheme) {
    return RawAutocomplete<Todos>(
      key: const ValueKey('todo'),
      focusNode: todoFocusNode,
      textEditingController: transferTodoController,
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
          _buildTodoFieldView(context, controller, focusNode, colorScheme),
      optionsBuilder: _buildTodoOptions,
      onSelected: _onTodoSelected,
      displayStringForOption: (Todos option) => option.name,
      optionsViewBuilder: _buildTodoOptionsView,
    );
  }

  Widget _buildTodoFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    ColorScheme colorScheme,
  ) {
    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: fieldTextEditingController,
      focusNode: fieldFocusNode,
      labelText: 'selectTodoParent'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.task_square, color: colorScheme.primary),
      iconButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fieldTextEditingController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                IconsaxPlusLinear.close_circle,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  fieldTextEditingController.clear();
                  selectedTodo = null;
                  controller.todo.value = null;
                });
              },
            ),
          IconButton(
            icon: Icon(
              fieldFocusNode.hasFocus
                  ? IconsaxPlusLinear.arrow_up_1
                  : IconsaxPlusLinear.arrow_down,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {
              if (fieldFocusNode.hasFocus) {
                fieldFocusNode.unfocus();
              } else {
                fieldFocusNode.requestFocus();
              }
              setState(() {});
            },
          ),
        ],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'selectTodoParent'.tr;
        }
        return null;
      },
    );
  }

  Future<Iterable<Todos>> _buildTodoOptions(
    TextEditingValue textEditingValue,
  ) async => await getTodoAll(textEditingValue.text);

  Widget _buildTodoOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Todos> onSelected,
    Iterable<Todos> options,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final Todos todo = options.elementAt(index);
                return InkWell(
                  onTap: () => onSelected(todo),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                todo.name,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              if (todo.task.value != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  todo.task.value!.title,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (todo.task.value != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(todo.task.value!.taskColor),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.outline.withValues(
                                  alpha: 0.2,
                                ),
                                width: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(ColorScheme colorScheme, double padding) {
    return ValueListenableBuilder(
      valueListenable: controller.canCompose,
      builder: (context, canCompose, _) => Container(
        padding: EdgeInsets.all(padding * 1.5),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: MyTextButton(
            text: 'move'.tr,
            onPressed: canCompose ? onPressed : null,
          ),
        ),
      ),
    );
  }
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
