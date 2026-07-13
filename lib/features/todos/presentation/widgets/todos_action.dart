import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:isar_community/isar.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/view/todo_todos.dart';
import 'package:zest/core/widgets/form_dirty_tracker.dart';
import 'package:zest/core/widgets/icon_container.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/core/widgets/modal_sheet_animation_mixin.dart';
import 'package:zest/core/widgets/modal_sheet_header.dart';
import 'package:zest/core/widgets/modal_sheet_save_button.dart';
import 'package:zest/core/widgets/modal_sheet_scaffold.dart';
import 'package:zest/core/widgets/text_form.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/utils/text_utils.dart';

/// Bottom sheet form for creating or editing a todo.
class TodosAction extends ConsumerStatefulWidget {
  /// Creates a [TodosAction].
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    required this.category,
    this.task,
    this.todo,
  });

  /// The text.
  final String text;

  /// The task.
  final Tasks? task;

  /// The todo.
  final Todos? todo;

  /// The edit.
  final bool edit;

  /// The category.
  final bool category;

  @override
  /// Creates the state for this widget.
  ConsumerState<TodosAction> createState() => _TodosActionState();
}

/// State for [TodosAction] managing form fields and submission.
class _TodosActionState extends ConsumerState<TodosAction>
    with
        SingleTickerProviderStateMixin,
        WidgetsBindingObserver,
        ModalSheetAnimationMixin {
  /// Form key.
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _tagsKey = GlobalKey();
  final GlobalKey _tagsInputKey = GlobalKey();

  /// The category controller.
  late final TextEditingController _categoryController;

  /// The title controller.
  late final TextEditingController _titleController;

  /// The desc controller.
  late final TextEditingController _descController;

  /// The time controller.
  late final TextEditingController _timeController;

  /// The tags controller.
  late final TextEditingController _tagsController;

  /// The category focus node.
  late final FocusNode _categoryFocusNode;

  /// The tags focus node.
  late final FocusNode _tagsFocusNode;

  /// The scroll controller.
  late final ScrollController _scrollController;

  /// The selected task.
  Tasks? _selectedTask;

  /// Todo pinned.
  bool _todoPinned = false;

  /// Todo priority.
  Priority _todoPriority = Priority.none;

  /// String.
  List<String> _todoTags = [];

  /// The editing controller.
  late final _EditingController _editingController;

  /// Previous keyboard height.
  double _previousKeyboardHeight = 0;

  /// Tag options count.
  int _tagOptionsCount = 0;

  /// All tags collected from existing todos.
  List<String> _allKnownTags = [];

  /// Tags matching the current query, excluding already selected ones.
  List<String> _filteredTagOptions = [];

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeControllers();
    _initializeEditMode();
    _initializeEditingController();
    initModalSheetAnimations();
    _setupListeners();
    _loadAllTags();
  }

  @override
  /// Did change metrics.
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final keyboardOpened = keyboardHeight > 0 && _previousKeyboardHeight == 0;

      if (keyboardOpened && _tagsFocusNode.hasFocus && _tagOptionsCount > 0) {
        _scrollToTagsIfNeeded();
      }

      _previousKeyboardHeight = keyboardHeight;
    });
  }

  /// Initialize controllers.
  void _initializeControllers() {
    _categoryController = TextEditingController();
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _timeController = TextEditingController();
    _tagsController = TextEditingController();
    _categoryFocusNode = FocusNode();
    _tagsFocusNode = FocusNode();
    _scrollController = ScrollController();
  }

  /// Initialize edit mode.
  void _initializeEditMode() {
    if (widget.edit && widget.todo != null) {
      _selectedTask = widget.todo!.task.value;
      _categoryController.text = widget.todo!.task.value?.title ?? '';
      _titleController.text = widget.todo!.name;
      _descController.text = widget.todo!.description;
      _timeController.text = _formatDateTime(widget.todo!.todoCompletedTime);
      _todoPinned = widget.todo!.fix;
      _todoPriority = widget.todo!.priority;
      _todoTags = widget.todo!.tags;
    }
  }

  /// Initialize editing controller.
  void _initializeEditingController() {
    _editingController = _EditingController(
      _titleController.text,
      _descController.text,
      _timeController.text,
      _todoPinned,
      _selectedTask,
      _todoPriority,
      _todoTags,
    );
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _categoryController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _timeController.dispose();
    _tagsController.removeListener(_refreshFilteredTags);
    _tagsController.dispose();
    _categoryFocusNode.dispose();
    _tagsFocusNode.dispose();
    _editingController.dispose();
    disposeModalSheetAnimations();
    _scrollController.dispose();
    super.dispose();
  }

  /// Setup listeners.
  void _setupListeners() {
    _categoryFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _tagsController.addListener(_refreshFilteredTags);

    _tagsFocusNode.addListener(() {
      if (!mounted) return;

      if (_tagsFocusNode.hasFocus) {
        _loadAllTags().then((_) {
          if (mounted && _tagOptionsCount > 0) {
            _scrollToTagsIfNeeded();
          }
        });
      }

      setState(() {});
    });
  }

  /// Scroll to tags if needed.
  void _scrollToTagsIfNeeded() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final inputCtx = _tagsInputKey.currentContext;
        if (inputCtx == null) return;

        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        if (keyboardHeight == 0) return;

        final inputBox = inputCtx.findRenderObject() as RenderBox?;
        if (inputBox == null) return;

        final inputPosition = inputBox.localToGlobal(Offset.zero);
        final inputBottom = inputPosition.dy + inputBox.size.height;

        final screenHeight = MediaQuery.of(context).size.height;
        final visibleBottom = screenHeight - keyboardHeight;

        const itemHeight = 40.0;
        const listPadding = 8.0;
        const dropdownMargin = 4.0;
        const maxDropdownHeight = 400.0;

        final dropdownHeight = (_tagOptionsCount * itemHeight + listPadding)
            .clamp(0.0, maxDropdownHeight);

        final dropdownBottom = inputBottom + dropdownMargin + dropdownHeight;

        const safeMargin = 16.0;

        if (dropdownBottom <= visibleBottom - safeMargin) return;

        const scrollDuration = Duration(milliseconds: 350);
        const scrollCurve = Curves.easeOutCubic;

        if (_scrollController.hasClients) {
          try {
            Scrollable.ensureVisible(
              inputCtx,
              alignment: 0.3,
              duration: scrollDuration,
              curve: scrollCurve,
            );
          } catch (e) {
            final scrollOffset =
                _scrollController.offset +
                (dropdownBottom - visibleBottom + safeMargin);
            final clampedOffset = scrollOffset.clamp(
              0.0,
              _scrollController.position.maxScrollExtent,
            );
            _scrollController.animateTo(
              clampedOffset,
              duration: scrollDuration,
              curve: scrollCurve,
            );
          }
        }
      });
    });
  }

  /// Format date time.
  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    final appSettings = ref.watch(appSettingsProvider);
    return DateTimeFormatHelper.formatDateTime(
      dateTime,
      timeformat: appSettings.timeformat,
      languageCode: appSettings.locale.languageCode,
    );
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
        _clearControllers();
        NavigationHelper.back(context);
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back(context);
    }
  }

  /// Clear controllers.
  void _clearControllers() {
    _titleController.clear();
    _descController.clear();
    _timeController.clear();
    _categoryController.clear();
    _tagsController.clear();
    _todoTags = [];
  }

  /// On save pressed.
  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    _saveTodo();
    _clearControllers();
    NavigationHelper.back(context);
  }

  /// Save todo.
  void _saveTodo() {
    if (widget.edit) {
      _updateTodo();
    } else {
      _createTodo();
    }
  }

  /// Update todo.
  void _updateTodo() {
    ref
        .read(todosNotifierProvider.notifier)
        .updateTodo(
          todo: widget.todo!,
          task: _selectedTask!,
          title: _titleController.text,
          description: _descController.text,
          time: _timeController.text,
          pinned: _todoPinned,
          priority: _todoPriority,
          tags: _todoTags,
        );
  }

  /// Create todo.
  void _createTodo() {
    if (widget.category) {
      ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            task: _selectedTask!,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
          );
    } else if (widget.todo != null) {
      final parentTask = widget.todo!.task.value;
      if (parentTask == null) return;

      ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            task: parentTask,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
            parent: widget.todo,
          );
    } else if (widget.task != null) {
      ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            task: widget.task!,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
          );
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
      maxHeightFractionMobile: AppConstants.modalHeightFractionLargeMobile,
      maxHeightFractionDesktop:
          AppConstants.modalHeightFractionLargeDesktopWide,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      fadeAnimation: modalSheetFadeAnimation,
      slideAnimation: modalSheetSlideAnimation,
      header: ModalSheetHeader(
        padding: padding,
        title: widget.text,
        subtitle: widget.edit ? 'editTodoHint'.tr : 'createTodoHint'.tr,
        leading: IconContainer(
          icon: widget.edit
              ? IconsaxPlusBold.edit
              : IconsaxPlusBold.task_square,
          backgroundColor: colorScheme.tertiaryContainer,
          iconColor: colorScheme.onTertiaryContainer,
          iconSize: AppConstants.iconSizeLarge,
        ),
        trailing: ModalSheetSaveButton(
          canComposeListenable: _editingController.canCompose,
          onSave: _onSavePressed,
          accentColor: colorScheme.tertiary,
          onAccentColor: colorScheme.onTertiary,
          label: 'ready'.tr,
        ),
      ),
      body: _buildForm(context, padding),
    );
  }

  /// Builds the form widget.
  Widget _buildForm(BuildContext context, double padding) {
    final tagsFocused = _tagsFocusNode.hasFocus;

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
                controller: _scrollController,
                padding: EdgeInsets.all(padding * 1.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.category) ...[
                      _buildCategorySection(context),
                      SizedBox(height: padding * 1.5),
                    ],
                    _buildBasicInfoSection(context, padding),
                    SizedBox(height: padding * 1.5),
                    _buildTagsSection(context, padding),
                    if (!tagsFocused) ...[
                      SizedBox(height: padding * 1.5),
                      _buildAttributesSection(context, padding),
                      SizedBox(height: padding * 2),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the category section widget.
  Widget _buildCategorySection(BuildContext context) {
    return RawAutocomplete<Tasks>(
      focusNode: _categoryFocusNode,
      textEditingController: _categoryController,
      fieldViewBuilder: _buildCategoryFieldView,
      optionsBuilder: _buildCategoryOptions,
      onSelected: _onCategorySelected,
      displayStringForOption: (Tasks option) => option.title,
      optionsViewBuilder: _buildCategoryOptionsView,
    );
  }

  /// Builds the category field view widget.
  Widget _buildCategoryFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    VoidCallback onFieldSubmitted,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: _categoryController,
      focusNode: _categoryFocusNode,
      labelText: 'selectCategory'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.folder_2, color: colorScheme.primary),
      iconButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_categoryController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                IconsaxPlusLinear.close_square,
                size: AppConstants.iconSizeSmall,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                _categoryController.clear();
                setState(() {});
              },
            ),
          IconButton(
            icon: Icon(
              fieldFocusNode.hasFocus
                  ? IconsaxPlusLinear.arrow_up_1
                  : IconsaxPlusLinear.arrow_down,
              size: AppConstants.iconSizeSmall,
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

  /// Tasks.
  Future<Iterable<Tasks>> _buildCategoryOptions(
    TextEditingValue textEditingValue,
  ) async {
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

    final query = textEditingValue.text.toLowerCase();
    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(query);
    });
  }

  /// On category selected.
  void _onCategorySelected(Tasks selection) {
    _categoryController.text = selection.title;
    _selectedTask = selection;
    setState(() {
      if (widget.edit) _editingController.task.value = _selectedTask;
    });
    _categoryFocusNode.unfocus();
  }

  /// Builds the category options view widget.
  Widget _buildCategoryOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spacingXS),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          elevation: AppConstants.elevationHigh,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingXS,
              ),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final Tasks task = options.elementAt(index);
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
                        SizedBox(width: AppConstants.spacingM),
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

  /// Builds the basic info section widget.
  Widget _buildBasicInfoSection(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'details'.tr, IconsaxPlusBold.note_text),
        SizedBox(height: padding),
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: _titleController,
          labelText: 'enterTodoName'.tr,
          type: TextInputType.multiline,
          icon: Icon(IconsaxPlusLinear.edit, color: colorScheme.primary),
          onChanged: (value) => _editingController.title.value = value,
          autofocus: !widget.edit,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'validateName'.tr;
            }
            return null;
          },
          maxLine: null,
        ),
        SizedBox(height: padding * 1.5),
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: _descController,
          labelText: 'enterDescription'.tr,
          type: TextInputType.multiline,
          icon: Icon(IconsaxPlusLinear.note_text, color: colorScheme.primary),
          maxLine: null,
          onChanged: (value) => _editingController.description.value = value,
        ),
      ],
    );
  }

  /// Builds the tags section widget.
  Widget _buildTagsSection(BuildContext context, double padding) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      key: _tagsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextForm(
          key: _tagsInputKey,
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: _tagsController,
          labelText: 'addTags'.tr,
          type: TextInputType.text,
          icon: Icon(IconsaxPlusLinear.tag, color: colorScheme.primary),
          focusNode: _tagsFocusNode,
          onTap: () {
            if (_tagsFocusNode.hasFocus && _tagOptionsCount > 0) {
              _scrollToTagsIfNeeded();
            }
          },
          onChanged: (_) => _refreshFilteredTags(),
          onFieldSubmitted: (value) {
            _addTag(value);
            _tagsController.clear();
            _tagsFocusNode.requestFocus();
            _refreshFilteredTags();
          },
        ),
        if (_tagsFocusNode.hasFocus && _filteredTagOptions.isNotEmpty) ...[
          SizedBox(height: padding * 0.75),
          _buildInlineTagPicker(context),
        ],
        if (_todoTags.isNotEmpty) ...[
          SizedBox(height: padding),
          _buildTagsChips(context),
        ],
      ],
    );
  }

  /// Loads all unique tags from persisted todos.
  Future<void> _loadAllTags() async {
    final allTodos = await ref.read(isarProvider).todos.where().findAll();
    final tagsSet = <String>{};

    for (final todo in allTodos) {
      for (final tag in todo.tags) {
        final trimmed = tag.trim();
        if (trimmed.isNotEmpty) tagsSet.add(trimmed);
      }
    }

    if (!mounted) return;

    setState(() {
      _allKnownTags = tagsSet.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      _filteredTagOptions = _computeFilteredTags();
      _tagOptionsCount = _filteredTagOptions.length;
    });
  }

  /// Computes tags matching the query and excluding selected tags.
  List<String> _computeFilteredTags() {
    final query = _tagsController.text.trim().toLowerCase();
    final lowerCaseTodoTags = _todoTags.map((e) => e.toLowerCase()).toSet();

    return _allKnownTags
        .where((tag) => !lowerCaseTodoTags.contains(tag.toLowerCase()))
        .where((tag) => query.isEmpty || tag.toLowerCase().contains(query))
        .toList();
  }

  /// Refreshes the inline tag picker list.
  void _refreshFilteredTags() {
    if (!mounted) return;

    setState(() {
      _filteredTagOptions = _computeFilteredTags();
      _tagOptionsCount = _filteredTagOptions.length;
    });
  }

  /// Add tag.
  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _todoTags.contains(tag)) return;

    setState(() {
      _todoTags = List.from(_todoTags)..add(tag);
      _editingController.tags.value = _todoTags;
    });
  }

  /// On tag selected.
  void _onTagSelected(String tag) {
    _addTag(tag);
    _tagsController.clear();
    _refreshFilteredTags();
  }

  /// Maximum height for the tag picker before it becomes scrollable.
  double _tagPickerMaxHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;

    return (availableHeight * 0.45).clamp(120.0, 400.0);
  }

  /// Builds the inline tag picker shown while the field is focused.
  Widget _buildInlineTagPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const itemExtent = 44.0;
    const verticalPadding = AppConstants.spacingXS * 2;

    final maxHeight = _tagPickerMaxHeight(context);
    final contentHeight =
        _filteredTagOptions.length * itemExtent + verticalPadding;
    final height = contentHeight.clamp(itemExtent + verticalPadding, maxHeight);

    return Material(
      color: colorScheme.surfaceContainerHigh,
      elevation: AppConstants.elevationLow,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXS),
          itemExtent: itemExtent,
          itemCount: _filteredTagOptions.length,
          itemBuilder: (BuildContext context, int index) {
            final tag = _filteredTagOptions[index];
            return InkWell(
              onTap: () => _onTagSelected(tag),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                ),
                child: Row(
                  children: [
                    Icon(
                      IconsaxPlusLinear.tag,
                      color: colorScheme.primary,
                      size: AppConstants.iconSizeSmall,
                    ),
                    SizedBox(width: AppConstants.spacingM),
                    Expanded(
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the tags chips widget.
  Widget _buildTagsChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingXS,
      children: List.generate(
        _todoTags.length,
        (i) => InputChip(
          label: Text(_todoTags[i]),
          deleteIcon: Icon(
            IconsaxPlusLinear.close_circle,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSecondaryContainer,
          ),
          onDeleted: () {
            setState(() {
              _todoTags = List.from(_todoTags)..removeAt(i);
              _editingController.tags.value = _todoTags;
            });
            _refreshFilteredTags();
          },
          backgroundColor: colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide.none,
        ),
      ),
    );
  }

  /// Builds the attributes section widget.
  Widget _buildAttributesSection(BuildContext context, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'todoAttributes'.tr,
          IconsaxPlusBold.setting_2,
        ),
        SizedBox(height: padding),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: AppConstants.spacingS,
            children: [
              _buildSubTaskButton(context),
              _buildDateTimeButton(context),
              _buildPriorityButton(context),
              _buildPinButton(context),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the section header widget.
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: AppConstants.iconSizeSmall + 2,
          color: colorScheme.primary,
        ),
        SizedBox(width: AppConstants.spacingS),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
          ),
        ),
      ],
    );
  }

  /// Builds the sub task button widget.
  Widget _buildSubTaskButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: () => _handleSubTasksNavigation(context),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        minimumSize: const Size(0, 36),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.task_square,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: AppConstants.spacingS),
          Text(
            'subTask'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Void.
  Future<void> _handleSubTasksNavigation(BuildContext context) async {
    if (widget.edit && widget.todo != null) {
      if (_editingController.canCompose.value) {
        final bool shouldSave = await showConfirmationDialog(
          context: context,
          title: 'unsavedChanges'.tr,
          message: 'saveBeforeSubtasks'.tr,
          icon: IconsaxPlusBold.document_filter,
          confirmText: 'save'.tr,
        );

        if (!context.mounted) return;
        if (!shouldSave) return;

        if (!_formKey.currentState!.validate()) return;

        TextUtils.trimController(_titleController);
        TextUtils.trimController(_descController);
        _saveTodo();
      }

      if (!context.mounted) return;
      NavigationHelper.back(context);
      if (!context.mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TodosTodo(key: ValueKey(widget.todo!.id), todo: widget.todo!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: AppConstants.cardTapAnimation,
        ),
      );
    } else {
      await _createTodoAndNavigateToSubtasks(context);
    }
  }

  /// Void.
  Future<void> _createTodoAndNavigateToSubtasks(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    try {
      Tasks? taskToUse;

      if (widget.category) {
        taskToUse = _selectedTask;
      } else if (widget.todo != null) {
        taskToUse = widget.todo!.task.value;
      } else if (widget.task != null) {
        taskToUse = widget.task;
      }

      if (taskToUse == null) {
        throw Exception('No task selected');
      }

      final newTodo = await ref
          .read(todosNotifierProvider.notifier)
          .addTodo(
            task: taskToUse,
            title: _titleController.text,
            description: _descController.text,
            time: _timeController.text,
            pinned: _todoPinned,
            priority: _todoPriority,
            tags: _todoTags,
            parent: widget.category ? null : widget.todo,
          );

      if (!context.mounted) return;
      NavigationHelper.back(context);

      if (!context.mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              TodosTodo(key: ValueKey(newTodo.id), todo: newTodo),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
          transitionDuration: AppConstants.cardTapAnimation,
        ),
      );
    } catch (e) {
      // ignore
    }
  }

  /// Builds the date time button widget.
  Widget _buildDateTimeButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasTime = _timeController.text.isNotEmpty;

    return FilledButton.tonal(
      onPressed: _showDateTimePicker,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        minimumSize: const Size(0, 36),
        backgroundColor: hasTime
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.calendar,
            size: AppConstants.iconSizeSmall,
            color: hasTime
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          SizedBox(width: AppConstants.spacingS),
          Text(
            hasTime ? _timeController.text : 'timeComplete'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: hasTime
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          if (hasTime) ...[
            SizedBox(width: AppConstants.spacingS),
            InkWell(
              onTap: () {
                _timeController.clear();
                setState(() {
                  if (widget.edit) {
                    _editingController.time.value = _timeController.text;
                  }
                });
              },
              child: Icon(
                IconsaxPlusLinear.close_circle,
                size: AppConstants.iconSizeSmall - 2,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Void.
  Future<void> _showDateTimePicker() async {
    final now = DateTime.now();
    final DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(hours: 1)),
      lastDate: now.add(const Duration(days: 1000)),
      is24HourMode: ref.watch(appSettingsProvider).timeformat != '12',
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
    );

    if (dateTime != null) {
      setState(() {
        _timeController.text = _formatDateTime(dateTime);
        if (widget.edit) {
          _editingController.time.value = _timeController.text;
        }
      });
    }
  }

  /// Builds the priority button widget.
  Widget _buildPriorityButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    return MenuAnchor(
      alignmentOffset: isKeyboardOpen
          ? const Offset(0, -250)
          : const Offset(0, 0),

      style: MenuStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevation: WidgetStateProperty.all(8),
      ),
      menuChildren: [
        for (final priority in Priority.values)
          MenuItemButton(
            leadingIcon: Icon(
              IconsaxPlusLinear.flag,
              color: priority.color ?? colorScheme.onSurface,
            ),
            child: Text(
              priority.name.tr,
              style: TextStyle(
                fontWeight: _todoPriority == priority
                    ? FontWeight.w600
                    : FontWeight.w500,
              ),
            ),
            onPressed: () {
              setState(() {
                _todoPriority = priority;
                if (widget.edit) {
                  _editingController.priority.value = priority;
                }
              });
            },
          ),
      ],
      builder: (context, menuController, _) => FilledButton.tonal(
        onPressed: () {
          if (menuController.isOpen) {
            menuController.close();
          } else {
            menuController.open();
          }
        },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(0, 36),
          backgroundColor: _todoPriority != Priority.none
              ? _todoPriority.color?.withValues(alpha: 0.15)
              : colorScheme.secondaryContainer,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              IconsaxPlusLinear.flag,
              size: 18,
              color: _todoPriority != Priority.none
                  ? _todoPriority.color
                  : colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 8),
            Text(
              _todoPriority.name.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: _todoPriority != Priority.none
                    ? _todoPriority.color
                    : colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the pin button widget.
  Widget _buildPinButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton.tonal(
      onPressed: () {
        setState(() {
          _todoPinned = !_todoPinned;
          if (widget.edit) {
            _editingController.pinned.value = _todoPinned;
          }
        });
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 36),
        backgroundColor: _todoPinned
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _todoPinned
                ? IconsaxPlusBold.attach_square
                : IconsaxPlusLinear.attach_square,
            size: 18,
            color: _todoPinned
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'todoPined'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: _todoPinned
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tracks dirty state for the todo create/edit form.
class _EditingController {
  _EditingController(
    this._initialTitle,
    this._initialDesc,
    this._initialTime,
    this._initialPinned,
    this._initialTask,
    this._initialPriority,
    this._initialTags,
  ) {
    title.value = _initialTitle;
    description.value = _initialDesc;
    time.value = _initialTime;
    pinned.value = _initialPinned;
    task.value = _initialTask;
    priority.value = _initialPriority;
    tags.value = List.from(_initialTags);

    for (final listenable in [
      title,
      description,
      time,
      pinned,
      task,
      priority,
      tags,
    ]) {
      _dirtyTracker.watch(listenable, _hasChanges);
    }
  }

  final String _initialTitle;
  final String _initialDesc;
  final String _initialTime;
  final bool _initialPinned;
  final Tasks? _initialTask;
  final Priority _initialPriority;
  final List<String> _initialTags;

  final title = ValueNotifier<String>('');
  final description = ValueNotifier<String>('');
  final ValueNotifier<String> time = ValueNotifier<String>('');
  final ValueNotifier<bool> pinned = ValueNotifier<bool>(false);
  final ValueNotifier<Tasks?> task = ValueNotifier<Tasks?>(null);
  final ValueNotifier<Priority> priority = ValueNotifier<Priority>(
    Priority.none,
  );
  final ValueNotifier<List<String>> tags = ValueNotifier<List<String>>([]);

  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  bool _hasChanges() =>
      title.value != _initialTitle ||
      description.value != _initialDesc ||
      time.value != _initialTime ||
      pinned.value != _initialPinned ||
      task.value?.id != _initialTask?.id ||
      priority.value != _initialPriority ||
      !listEquals(tags.value, _initialTags);

  void dispose() {
    _dirtyTracker.dispose();
    title.dispose();
    description.dispose();
    time.dispose();
    pinned.dispose();
    task.dispose();
    priority.dispose();
    tags.dispose();
  }
}
