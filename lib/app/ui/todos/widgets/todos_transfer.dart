import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/widgets/confirmation_dialog.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/responsive_utils.dart';
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
  late final TodoController _todoController = Get.find<TodoController>();

  late final TextEditingController _taskController;
  late final TextEditingController _todosController;
  late final FocusNode _taskFocusNode;
  late final FocusNode _todoFocusNode;
  late final GlobalKey<FormState> _formKey;

  TransferMode _mode = TransferMode.category;
  Tasks? _selectedTask;
  Todos? _selectedTodo;

  late final _EditingController _editingController;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _taskController = TextEditingController();
    _todosController = TextEditingController();
    _taskFocusNode = FocusNode();
    _todoFocusNode = FocusNode();
    _formKey = GlobalKey<FormState>();
    _editingController = _EditingController();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
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
    _taskController.dispose();
    _todosController.dispose();
    _taskFocusNode.dispose();
    _todoFocusNode.dispose();
    _editingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) return;

    if (!_editingController.canCompose.value) {
      NavigationHelper.back();
      return;
    }

    final shouldPop = await showClearTextConfirmation(
      context: context,
      onConfirm: () {
        _taskController.clear();
        _todosController.clear();
        NavigationHelper.back();
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back();
    }
  }

  Future<Set<int>> _collectExcludedIds() async {
    final excluded = <int>{};
    final stack = <Todos>[...widget.todos];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (!excluded.add(node.id)) continue;

      final children = await isar.todos
          .filter()
          .parent((q) => q.idEqualTo(node.id))
          .findAll();

      for (final child in children) {
        if (!excluded.contains(child.id)) {
          stack.add(child);
        }
      }
    }

    return excluded;
  }

  Future<Iterable<Tasks>> _getAvailableTasks(String pattern) async {
    final tasks = await isar.tasks.filter().archiveEqualTo(false).findAll();

    tasks.sort((a, b) {
      final aIndex = a.index ?? double.maxFinite.toInt();
      final bIndex = b.index ?? double.maxFinite.toInt();
      return aIndex.compareTo(bIndex);
    });

    final query = pattern.toLowerCase();

    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(query);
    });
  }

  Future<Iterable<Todos>> _getAvailableTodos(String pattern) async {
    final allTodos = await isar.todos.where().findAll();
    final excludedIds = await _collectExcludedIds();
    final query = pattern.toLowerCase();

    return allTodos.where((todo) {
      if (excludedIds.contains(todo.id)) return false;
      if (query.isEmpty) return true;
      return todo.name.toLowerCase().contains(query);
    });
  }

  void _onTaskSelected(Tasks selection) {
    setState(() {
      _taskController.text = selection.title;
      _selectedTask = selection;
      _editingController.setTask(selection);
    });
    _taskFocusNode.unfocus();
  }

  void _onTodoSelected(Todos selection) {
    setState(() {
      _todosController.text = selection.name;
      _selectedTodo = selection;
      _editingController.setTodo(selection);
    });
    _todoFocusNode.unfocus();
  }

  void _onModeChanged(TransferMode newMode) {
    if (_mode == newMode) return;

    setState(() {
      _mode = newMode;

      if (_mode == TransferMode.category) {
        _selectedTodo = null;
        _todosController.clear();
        _editingController.setTodo(null);
        _todoFocusNode.unfocus();
      } else {
        _selectedTask = null;
        _taskController.clear();
        _editingController.setTask(null);
        _taskFocusNode.unfocus();
      }
    });
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    if (_mode == TransferMode.category && _selectedTask != null) {
      _todoController.moveTodos(widget.todos, _selectedTask!);
      _todoController.doMultiSelectionTodoClear();
      NavigationHelper.back();
    } else if (_mode == TransferMode.todo && _selectedTodo != null) {
      _todoController.moveTodosToParent(widget.todos, _selectedTodo);
      _todoController.doMultiSelectionTodoClear();
      NavigationHelper.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : AppConstants.maxModalWidth,
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
                  child: _buildForm(context, padding),
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
      margin: const EdgeInsets.only(
        top: AppConstants.spacingM,
        bottom: AppConstants.spacingS,
      ),
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
            padding: const EdgeInsets.all(AppConstants.spacingS + 2),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Icon(
              IconsaxPlusBold.convert,
              size: AppConstants.iconSizeLarge,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          SizedBox(width: padding * 1.2),
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
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXS),
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
          SizedBox(width: padding * 0.8),
          _buildSaveButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return ValueListenableBuilder<bool>(
      valueListenable: _editingController.canCompose,
      builder: (context, canCompose, _) {
        return AnimatedScale(
          scale: canCompose ? 1.0 : 0.92,
          duration: AppConstants.longAnimation,
          curve: Curves.easeOutCubic,
          child: Material(
            color: canCompose
                ? colorScheme.secondary
                : colorScheme.surfaceContainerHigh,
            elevation: canCompose ? AppConstants.elevationLow : 0,
            shadowColor: colorScheme.secondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusXLarge,
            ),
            child: InkWell(
              onTap: canCompose ? _onSavePressed : null,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusXLarge,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppConstants.spacingS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusBold.tick_circle,
                      size: AppConstants.iconSizeSmall,
                      color: canCompose
                          ? colorScheme.onSecondary
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppConstants.spacingXS + 2),
                    Text(
                      'move'.tr,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          13,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: canCompose
                            ? colorScheme.onSecondary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, double padding) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(context, padding),
                    SizedBox(height: padding * 1.5),
                    _buildModeToggle(context),
                    SizedBox(height: padding * 1.5),
                    _buildDestinationSection(context),
                    SizedBox(height: padding * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: AppConstants.borderWidthThin,
        ),
      ),
      child: Row(
        children: [
          Icon(
            IconsaxPlusLinear.info_circle,
            size: AppConstants.iconSizeMedium,
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

  Widget _buildModeToggle(BuildContext context) {
    return SegmentedButton<TransferMode>(
      segments: [
        ButtonSegment<TransferMode>(
          value: TransferMode.category,
          label: Text('categories'.tr),
          icon: Icon(
            IconsaxPlusLinear.folder_2,
            size: AppConstants.iconSizeSmall,
          ),
        ),
        ButtonSegment<TransferMode>(
          value: TransferMode.todo,
          label: Text('todo'.tr),
          icon: Icon(
            IconsaxPlusLinear.task_square,
            size: AppConstants.iconSizeSmall,
          ),
        ),
      ],
      selected: {_mode},
      onSelectionChanged: (Set<TransferMode> newSelection) {
        _onModeChanged(newSelection.first);
      },
      style: ButtonStyle(visualDensity: VisualDensity.comfortable),
    );
  }

  Widget _buildDestinationSection(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppConstants.shortAnimation,
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
          ? _buildTaskAutocomplete(context)
          : _buildTodoAutocomplete(context),
    );
  }

  Widget _buildTaskAutocomplete(BuildContext context) {
    return RawAutocomplete<Tasks>(
      key: const ValueKey('task'),
      focusNode: _taskFocusNode,
      textEditingController: _taskController,
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
          _buildTaskField(context, controller, focusNode),
      optionsBuilder: (textEditingValue) =>
          _getAvailableTasks(textEditingValue.text),
      onSelected: _onTaskSelected,
      displayStringForOption: (Tasks option) => option.title,
      optionsViewBuilder: _buildTaskOptionsView,
    );
  }

  Widget _buildTaskField(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: controller,
      focusNode: focusNode,
      labelText: 'selectCategory'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.folder_2, color: colorScheme.primary),
      iconButton: _buildFieldActions(
        controller: controller,
        focusNode: focusNode,
        onClear: () {
          setState(() {
            controller.clear();
            _selectedTask = null;
            _editingController.setTask(null);
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'selectCategory'.tr;
        }
        return null;
      },
    );
  }

  Widget _buildTodoAutocomplete(BuildContext context) {
    return RawAutocomplete<Todos>(
      key: const ValueKey('todo'),
      focusNode: _todoFocusNode,
      textEditingController: _todosController,
      optionsViewOpenDirection: OptionsViewOpenDirection.up,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
          _buildTodoField(context, controller, focusNode),
      optionsBuilder: (textEditingValue) =>
          _getAvailableTodos(textEditingValue.text),
      onSelected: _onTodoSelected,
      displayStringForOption: (Todos option) => option.name,
      optionsViewBuilder: _buildTodoOptionsView,
    );
  }

  Widget _buildTodoField(
    BuildContext context,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: controller,
      focusNode: focusNode,
      labelText: 'selectTodoParent'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.task_square, color: colorScheme.primary),
      iconButton: _buildFieldActions(
        controller: controller,
        focusNode: focusNode,
        onClear: () {
          setState(() {
            controller.clear();
            _selectedTodo = null;
            _editingController.setTodo(null);
          });
        },
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'selectTodoParent'.tr;
        }
        return null;
      },
    );
  }

  Widget _buildFieldActions({
    required TextEditingController controller,
    required FocusNode focusNode,
    required VoidCallback onClear,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.text.isNotEmpty)
          IconButton(
            icon: Icon(
              IconsaxPlusLinear.close_circle,
              size: AppConstants.iconSizeSmall,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: onClear,
          ),
        IconButton(
          icon: Icon(
            focusNode.hasFocus
                ? IconsaxPlusLinear.arrow_up_1
                : IconsaxPlusLinear.arrow_down,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            if (focusNode.hasFocus) {
              focusNode.unfocus();
            } else {
              focusNode.requestFocus();
            }
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildTaskOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingXS),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          elevation: AppConstants.elevationHigh,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingXS,
              ),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final task = options.elementAt(index);
                return InkWell(
                  onTap: () => onSelected(task),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                      vertical: AppConstants.spacingM,
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
                        const SizedBox(width: AppConstants.spacingM),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Color(task.taskColor),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.2),
                              width: AppConstants.borderWidthThin,
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

  Widget _buildTodoOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Todos> onSelected,
    Iterable<Todos> options,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          elevation: AppConstants.elevationHigh,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingXS,
              ),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final todo = options.elementAt(index);
                todo.task.loadSync();
                return InkWell(
                  onTap: () => onSelected(todo),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                      vertical: AppConstants.spacingM,
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
                                const SizedBox(
                                  height: AppConstants.spacingXS / 2,
                                ),
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
                          const SizedBox(width: AppConstants.spacingM),
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
                                width: AppConstants.borderWidthThin,
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
}

class _EditingController {
  _EditingController() {
    _task.addListener(_updateCanCompose);
    _todo.addListener(_updateCanCompose);
  }

  final ValueNotifier<Tasks?> _task = ValueNotifier(null);
  final ValueNotifier<Todos?> _todo = ValueNotifier(null);
  final ValueNotifier<bool> _canCompose = ValueNotifier(false);

  ValueListenable<bool> get canCompose => _canCompose;

  void setTask(Tasks? task) => _task.value = task;
  void setTodo(Todos? todo) => _todo.value = todo;

  void _updateCanCompose() {
    _canCompose.value = _task.value != null || _todo.value != null;
  }

  void dispose() {
    _task.removeListener(_updateCanCompose);
    _todo.removeListener(_updateCanCompose);
    _task.dispose();
    _todo.dispose();
    _canCompose.dispose();
  }
}
