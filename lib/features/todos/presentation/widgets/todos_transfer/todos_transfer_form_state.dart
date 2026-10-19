part of '../todos_transfer.dart';

mixin _TodosTransferFormState
    on
        ConsumerState<TodosTransfer>,
        SingleTickerProviderStateMixin<TodosTransfer>,
        ModalSheetAnimationMixin<TodosTransfer>,
        _TodosTransferFields {
  @override
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
    _taskController.addListener(_onTaskTextChanged);
    _todosController.addListener(_onTodoTextChanged);
  }

  void _onTaskTextChanged() {
    final selected = _selectedTask;
    if (selected == null) return;
    if (_taskController.text == selected.title) return;
    setState(() {
      _selectedTask = null;
      _editingController.setTask(null);
    });
  }

  void _onTodoTextChanged() {
    final selected = _selectedTodo;
    if (selected == null) return;
    if (_todosController.text == selected.name) return;
    setState(() {
      _selectedTodo = null;
      _editingController.setTodo(null);
    });
  }

  @override
  void dispose() {
    _taskController.removeListener(_onTaskTextChanged);
    _todosController.removeListener(_onTodoTextChanged);
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
}

/// Tracks dirty state for the transfer form.
class _EditingController {
  _EditingController() {
    _dirtyTracker.watch(_task, _hasSelection);
    _dirtyTracker.watch(_todo, _hasSelection);
  }

  final ValueNotifier<Category?> _task = ValueNotifier(null);
  final ValueNotifier<Todo?> _todo = ValueNotifier(null);
  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  /// Whether the transfer form has a destination selected.
  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  /// Sets the destination category for the transfer.
  void setTask(Category? task) => _task.value = task;

  /// Sets the destination parent item for the transfer.
  void setTodo(Todo? todo) => _todo.value = todo;

  bool _hasSelection() => _task.value != null || _todo.value != null;

  void dispose() {
    _dirtyTracker.dispose();
    _task.dispose();
    _todo.dispose();
  }
}
