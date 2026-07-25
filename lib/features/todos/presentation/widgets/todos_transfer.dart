import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/core/widgets/form_dirty_tracker.dart';
import 'package:zest/core/widgets/autocomplete_options_dropdown.dart';
import 'package:zest/core/widgets/icon_container.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/core/widgets/modal_sheet_animation_mixin.dart';
import 'package:zest/core/widgets/modal_sheet_header.dart';
import 'package:zest/core/widgets/modal_sheet_save_button.dart';
import 'package:zest/core/widgets/modal_sheet_scaffold.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/text_form.dart';

/// Transfer target mode: category or parent todo.
enum TransferMode { category, todo }

/// Dialog for moving todos to another category or parent.
class TodosTransfer extends ConsumerStatefulWidget {
  /// Creates a [TodosTransfer].
  const TodosTransfer({super.key, required this.text, required this.todos});

  /// Dialog title describing the transfer action.
  final String text;

  /// Todos being moved to the chosen destination.
  final List<Todos> todos;

  @override
  /// Creates the state for this widget.
  ConsumerState<TodosTransfer> createState() => _TodosTransferState();
}

/// State for [TodosTransfer] handling transfer mode and selection.
class _TodosTransferState extends ConsumerState<TodosTransfer>
    with SingleTickerProviderStateMixin, ModalSheetAnimationMixin {
  /// The task controller.
  late final TextEditingController _taskController;

  /// The todos controller.
  late final TextEditingController _todosController;

  /// The task focus node.
  late final FocusNode _taskFocusNode;

  /// The todo focus node.
  late final FocusNode _todoFocusNode;

  /// The form key.
  late final GlobalKey<FormState> _formKey;

  /// Mode.
  TransferMode _mode = TransferMode.category;

  /// The selected task.
  Tasks? _selectedTask;

  /// The selected todo.
  Todos? _selectedTodo;

  /// The editing controller.
  late final _EditingController _editingController;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _initializeControllers();
    initModalSheetAnimations(duration: AppConstants.animationDuration);
  }

  /// Initialize controllers.
  void _initializeControllers() {
    _taskController = TextEditingController();
    _todosController = TextEditingController();
    _taskFocusNode = FocusNode();
    _todoFocusNode = FocusNode();
    _formKey = GlobalKey<FormState>();
    _editingController = _EditingController();
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _taskController.dispose();
    _todosController.dispose();
    _taskFocusNode.dispose();
    _todoFocusNode.dispose();
    _editingController.dispose();
    disposeModalSheetAnimations();
    super.dispose();
  }

  /// Void.
  Future<void> _onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) return;

    if (!_editingController.canCompose.value) {
      NavigationHelper.back(context);
      return;
    }

    final shouldPop = await showClearTextConfirmation(
      context: context,
      onConfirm: () {
        _taskController.clear();
        _todosController.clear();
        NavigationHelper.back(context);
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back(context);
    }
  }

  /// Int.
  Future<Set<int>> _collectExcludedIds() async {
    final excluded = <int>{};
    final stack = <Todos>[...widget.todos];

    while (stack.isNotEmpty) {
      final node = stack.removeLast();
      if (!excluded.add(node.id)) continue;

      final children = await ref
          .read(isarProvider)
          .todos
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

  /// Tasks.
  Future<Iterable<Tasks>> _getAvailableTasks(String pattern) async {
    final tasks = await ref
        .read(isarProvider)
        .tasks
        .filter()
        .archiveEqualTo(false)
        .findAll();

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

  /// Todos.
  Future<Iterable<Todos>> _getAvailableTodos(String pattern) async {
    final allTodos = await ref.read(isarProvider).todos.where().findAll();
    final excludedIds = await _collectExcludedIds();
    final query = pattern.toLowerCase();

    return allTodos.where((todo) {
      if (excludedIds.contains(todo.id)) return false;
      if (query.isEmpty) return true;
      return todo.name.toLowerCase().contains(query);
    });
  }

  /// On task selected.
  void _onTaskSelected(Tasks selection) {
    setState(() {
      _taskController.text = selection.title;
      _selectedTask = selection;
      _editingController.setTask(selection);
    });
    _taskFocusNode.unfocus();
  }

  /// On todo selected.
  void _onTodoSelected(Todos selection) {
    setState(() {
      _todosController.text = selection.name;
      _selectedTodo = selection;
      _editingController.setTodo(selection);
    });
    _todoFocusNode.unfocus();
  }

  /// On mode changed.
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

  /// On save pressed.
  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    if (_mode == TransferMode.category && _selectedTask != null) {
      ref
          .read(todosNotifierProvider.notifier)
          .moveTodos(widget.todos, _selectedTask!);
      ref.read(todosNotifierProvider.notifier).doMultiSelectionTodoClear();
      NavigationHelper.back(context);
    } else if (_mode == TransferMode.todo && _selectedTodo != null) {
      ref
          .read(todosNotifierProvider.notifier)
          .moveTodosToParent(widget.todos, _selectedTodo);
      ref.read(todosNotifierProvider.notifier).doMultiSelectionTodoClear();
      NavigationHelper.back(context);
    }
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ModalSheetScaffold(
      isMobile: isMobile,
      maxHeightFractionMobile: AppConstants.modalHeightFractionMediumMobile,
      maxHeightFractionDesktop: AppConstants.modalHeightFractionMediumDesktop,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      fadeAnimation: modalSheetFadeAnimation,
      slideAnimation: modalSheetSlideAnimation,
      header: ModalSheetHeader(
        padding: padding,
        title: widget.text,
        subtitle: 'transferTodoHint'.tr,
        leading: IconContainer(
          icon: IconsaxPlusBold.convert,
          backgroundColor: colorScheme.secondaryContainer,
          iconColor: colorScheme.onSecondaryContainer,
          iconSize: AppConstants.iconSizeLarge,
        ),
        trailing: ModalSheetSaveButton(
          canComposeListenable: _editingController.canCompose,
          onSave: _onSavePressed,
          accentColor: colorScheme.secondary,
          onAccentColor: colorScheme.onSecondary,
          label: 'move'.tr,
        ),
      ),
      body: _buildForm(context, padding),
    );
  }

  /// Builds the form widget.
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

  /// Builds the info card widget.
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
              'movingTodosCount'.trFormat({'count': widget.todos.length}),
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

  /// Builds the mode toggle widget.
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

  /// Builds the destination section widget.
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

  /// Builds the task autocomplete widget.
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

  /// Builds the task field widget.
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

  /// Builds the todo autocomplete widget.
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

  /// Builds the todo field widget.
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

  /// Builds the field actions widget.
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

  /// Builds the task options view widget.
  Widget _buildTaskOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) {
    return AutocompleteOptionsDropdown<Tasks>(
      options: options,
      onSelected: onSelected,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingXS),
      maxHeight: 200,
      itemBuilder: (context, task) {
        return Row(
          children: [
            Expanded(
              child: Text(
                task.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            AutocompleteColorSwatch(color: Color(task.taskColor)),
          ],
        );
      },
    );
  }

  /// Builds the todo options view widget.
  Widget _buildTodoOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Todos> onSelected,
    Iterable<Todos> options,
  ) {
    return AutocompleteOptionsDropdown<Todos>(
      options: options,
      onSelected: onSelected,
      alignment: Alignment.bottomCenter,
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      maxHeight: 200,
      itemBuilder: (context, todo) {
        todo.task.loadSync();
        final colorScheme = Theme.of(context).colorScheme;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    todo.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (todo.task.value != null) ...[
                    const SizedBox(height: AppConstants.spacingXS / 2),
                    Text(
                      todo.task.value!.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (todo.task.value != null) ...[
              const SizedBox(width: AppConstants.spacingM),
              AutocompleteColorSwatch(color: Color(todo.task.value!.taskColor)),
            ],
          ],
        );
      },
    );
  }
}

/// Tracks dirty state for the transfer form.
class _EditingController {
  _EditingController() {
    _dirtyTracker.watch(_task, _hasSelection);
    _dirtyTracker.watch(_todo, _hasSelection);
  }

  final ValueNotifier<Tasks?> _task = ValueNotifier(null);
  final ValueNotifier<Todos?> _todo = ValueNotifier(null);
  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  /// Whether the transfer form has a destination selected.
  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  /// Sets the destination category for the transfer.
  void setTask(Tasks? task) => _task.value = task;

  /// Sets the destination parent todo for the transfer.
  void setTodo(Todos? todo) => _todo.value = todo;

  bool _hasSelection() => _task.value != null || _todo.value != null;

  void dispose() {
    _dirtyTracker.dispose();
    _task.dispose();
    _todo.dispose();
  }
}
