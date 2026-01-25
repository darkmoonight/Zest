import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/todos/view/todo_todos.dart';
import 'package:zest/app/ui/widgets/confirmation_dialog.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/text_utils.dart';
import 'package:zest/main.dart';

class TodosAction extends StatefulWidget {
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    required this.category,
    this.task,
    this.todo,
  });

  final String text;
  final Tasks? task;
  final Todos? todo;
  final bool edit;
  final bool category;

  @override
  State<TodosAction> createState() => _TodosActionState();
}

class _TodosActionState extends State<TodosAction>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _tagsKey = GlobalKey();
  late final TodoController _todoController = Get.find<TodoController>();

  late final TextEditingController _categoryController;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _timeController;
  late final TextEditingController _tagsController;

  late final FocusNode _categoryFocusNode;
  late final FocusNode _tagsFocusNode;

  late final ScrollController _scrollController;

  Tasks? _selectedTask;
  bool _todoPinned = false;
  Priority _todoPriority = Priority.none;
  List<String> _todoTags = [];

  late final _EditingController _editingController;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeEditMode();
    _initializeEditingController();
    _initAnimations();
    _setupListeners();
  }

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

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  void _setupListeners() {
    _categoryFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    _tagsFocusNode.addListener(() {
      if (_tagsFocusNode.hasFocus) {
        _buildTagOptions(_tagsController.value).then((options) {
          if (options.isNotEmpty) {
            _scrollToTags();
          }
        });
      }
    });
  }

  void _scrollToTags() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final ctx = _tagsKey.currentContext;
        if (ctx == null) return;

        if (_scrollController.hasClients) {
          try {
            Scrollable.ensureVisible(
              ctx,
              alignment: 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          } catch (e) {
            final max = _scrollController.position.maxScrollExtent;
            _scrollController.animateTo(
              max,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        } else {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _timeController.dispose();
    _tagsController.dispose();
    _categoryFocusNode.dispose();
    _tagsFocusNode.dispose();
    _editingController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';

    return timeformat.value == '12'
        ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(dateTime)
        : DateFormat.yMMMEd(locale.languageCode).add_Hm().format(dateTime);
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
        _clearControllers();
        NavigationHelper.back();
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back();
    }
  }

  void _clearControllers() {
    _titleController.clear();
    _descController.clear();
    _timeController.clear();
    _categoryController.clear();
    _tagsController.clear();
    _todoTags = [];
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    _saveTodo();
    _clearControllers();
    NavigationHelper.back();
  }

  void _saveTodo() {
    if (widget.edit) {
      _updateTodo();
    } else {
      _createTodo();
    }
  }

  void _updateTodo() {
    _todoController.updateTodo(
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

  void _createTodo() {
    if (widget.category) {
      _todoController.addTodo(
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

      _todoController.addTodo(
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
      _todoController.addTodo(
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
              MediaQuery.of(context).size.height * (isMobile ? 0.95 : 0.90),
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
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
            ),
            child: Icon(
              widget.edit ? IconsaxPlusBold.edit : IconsaxPlusBold.task_square,
              size: AppConstants.iconSizeLarge,
              color: colorScheme.onTertiaryContainer,
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
                SizedBox(height: AppConstants.spacingXS),
                Text(
                  widget.edit ? 'editTodoHint'.tr : 'createTodoHint'.tr,
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
                ? colorScheme.tertiary
                : colorScheme.surfaceContainerHigh,
            elevation: canCompose ? AppConstants.elevationLow : 0,
            shadowColor: colorScheme.tertiary.withValues(alpha: 0.3),
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
                          ? colorScheme.onTertiary
                          : colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: AppConstants.spacingXS + 2),
                    Text(
                      'ready'.tr,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          13,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: canCompose
                            ? colorScheme.onTertiary
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
                    SizedBox(height: padding * 1.5),
                    _buildAttributesSection(context, padding),
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

  Future<Iterable<Tasks>> _buildCategoryOptions(
    TextEditingValue textEditingValue,
  ) async {
    final tasks = isar.tasks.filter().archiveEqualTo(false).findAllSync();

    final query = textEditingValue.text.toLowerCase();
    if (query.isEmpty) return tasks;

    return tasks.where((task) {
      return task.title.toLowerCase().contains(query);
    });
  }

  void _onCategorySelected(Tasks selection) {
    _categoryController.text = selection.title;
    _selectedTask = selection;
    setState(() {
      if (widget.edit) _editingController.task.value = _selectedTask;
    });
    _categoryFocusNode.unfocus();
  }

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

  Widget _buildTagsSection(BuildContext context, double padding) {
    return Column(
      key: _tagsKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RawAutocomplete<String>(
          focusNode: _tagsFocusNode,
          textEditingController: _tagsController,
          fieldViewBuilder: _buildTagsFieldView,
          optionsBuilder: _buildTagOptions,
          onSelected: _onTagSelected,
          optionsViewBuilder: _buildTagOptionsView,
        ),
        if (_todoTags.isNotEmpty) ...[
          SizedBox(height: padding),
          _buildTagsChips(context),
        ],
      ],
    );
  }

  Widget _buildTagsFieldView(
    BuildContext context,
    TextEditingController fieldTextEditingController,
    FocusNode fieldFocusNode,
    VoidCallback onFieldSubmitted,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: fieldTextEditingController,
      labelText: 'addTags'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.tag, color: colorScheme.primary),
      focusNode: _tagsFocusNode,
      onFieldSubmitted: (value) {
        _addTag(value);
        fieldTextEditingController.clear();
        _tagsFocusNode.requestFocus();
      },
    );
  }

  Future<Iterable<String>> _buildTagOptions(
    TextEditingValue textEditingValue,
  ) async {
    final allTodos = isar.todos.where().findAllSync();
    final Set<String> tagsSet = {};

    for (final todo in allTodos) {
      for (final tag in todo.tags) {
        final trimmed = tag.trim();
        if (trimmed.isNotEmpty) tagsSet.add(trimmed);
      }
    }

    final List<String> tagsList = tagsSet.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final query = textEditingValue.text.trim().toLowerCase();

    List<String> filteredTags = query.isEmpty
        ? tagsList
        : tagsList.where((tag) => tag.toLowerCase().contains(query)).toList();

    filteredTags = filteredTags
        .where((tag) => !_todoTags.contains(tag))
        .toList();

    if (filteredTags.isNotEmpty) {
      _scrollToTags();
    }

    return filteredTags;
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty || _todoTags.contains(tag)) return;

    setState(() {
      _todoTags = List.from(_todoTags)..add(tag);
      _editingController.tags.value = _todoTags;
    });
  }

  void _onTagSelected(String tag) {
    _addTag(tag);
    _tagsController.clear();
    _tagsFocusNode.unfocus();
  }

  Widget _buildTagOptionsView(
    BuildContext context,
    AutocompleteOnSelected<String> onSelected,
    Iterable<String> options,
  ) {
    final list = options.toList();
    final colorScheme = Theme.of(context).colorScheme;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        top: AppConstants.spacingXS,
        bottom: keyboardHeight > 0 ? keyboardHeight + AppConstants.spacingM : 0,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
          elevation: AppConstants.elevationHigh,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingXS,
              ),
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                final tag = list[index];
                return InkWell(
                  onTap: () => onSelected(tag),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingL,
                      vertical: AppConstants.spacingS,
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
        ),
      ),
    );
  }

  Widget _buildTagsChips(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppConstants.spacingS,
      runSpacing: AppConstants.spacingS,
      children: List.generate(
        _todoTags.length,
        (i) => InputChip(
          label: Text(_todoTags[i]),
          deleteIcon: Icon(
            IconsaxPlusLinear.close_circle,
            size: AppConstants.iconSizeSmall,
            color: colorScheme.onSecondaryContainer,
          ),
          onDeleted: () => setState(() {
            _todoTags = List.from(_todoTags)..removeAt(i);
            _editingController.tags.value = _todoTags;
          }),
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

        if (!shouldSave) return;

        if (!_formKey.currentState!.validate()) return;

        TextUtils.trimController(_titleController);
        TextUtils.trimController(_descController);
        _saveTodo();
      }

      NavigationHelper.back();
      Get.key.currentState!.push(
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
          transitionDuration: const Duration(milliseconds: 240),
        ),
      );
    } else {
      await _createTodoAndNavigateToSubtasks(context);
    }
  }

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

      final newTodo = await _todoController.addTodo(
        task: taskToUse,
        title: _titleController.text,
        description: _descController.text,
        time: _timeController.text,
        pinned: _todoPinned,
        priority: _todoPriority,
        tags: _todoTags,
        parent: widget.category ? null : widget.todo,
      );

      NavigationHelper.back();

      await Get.key.currentState!.push(
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
          transitionDuration: const Duration(milliseconds: 240),
        ),
      );
    } catch (e) {
      // ignore
    }
  }

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

  Future<void> _showDateTimePicker() async {
    final DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 1000)),
      is24HourMode: timeformat.value != '12',
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

class _EditingController extends ChangeNotifier {
  _EditingController(
    this._initialTitle,
    this._initialDesc,
    this._initialTime,
    this._initialPinned,
    this._initialTask,
    this._initialPriority,
    this._initialTags,
  ) {
    _initializeListeners();
  }

  final String _initialTitle;
  final String _initialDesc;
  final String _initialTime;
  final bool _initialPinned;
  final Tasks? _initialTask;
  final Priority _initialPriority;
  final List<String> _initialTags;

  final ValueNotifier<String> title = ValueNotifier<String>('');
  final ValueNotifier<String> description = ValueNotifier<String>('');
  final ValueNotifier<String> time = ValueNotifier<String>('');
  final ValueNotifier<bool> pinned = ValueNotifier<bool>(false);
  final ValueNotifier<Tasks?> task = ValueNotifier<Tasks?>(null);
  final ValueNotifier<Priority> priority = ValueNotifier<Priority>(
    Priority.none,
  );
  final ValueNotifier<List<String>> tags = ValueNotifier<List<String>>([]);
  final ValueNotifier<bool> _canCompose = ValueNotifier<bool>(false);

  ValueListenable<bool> get canCompose => _canCompose;

  void _initializeListeners() {
    title.value = _initialTitle;
    description.value = _initialDesc;
    time.value = _initialTime;
    pinned.value = _initialPinned;
    task.value = _initialTask;
    priority.value = _initialPriority;
    tags.value = List.from(_initialTags);

    title.addListener(_updateCanCompose);
    description.addListener(_updateCanCompose);
    time.addListener(_updateCanCompose);
    pinned.addListener(_updateCanCompose);
    task.addListener(_updateCanCompose);
    priority.addListener(_updateCanCompose);
    tags.addListener(_updateCanCompose);
  }

  void _updateCanCompose() {
    final hasChanges =
        title.value != _initialTitle ||
        description.value != _initialDesc ||
        time.value != _initialTime ||
        pinned.value != _initialPinned ||
        task.value?.id != _initialTask?.id ||
        priority.value != _initialPriority ||
        !listEquals(tags.value, _initialTags);

    _canCompose.value = hasChanges;
  }

  @override
  void dispose() {
    title.removeListener(_updateCanCompose);
    description.removeListener(_updateCanCompose);
    time.removeListener(_updateCanCompose);
    pinned.removeListener(_updateCanCompose);
    task.removeListener(_updateCanCompose);
    priority.removeListener(_updateCanCompose);
    tags.removeListener(_updateCanCompose);

    title.dispose();
    description.dispose();
    time.dispose();
    pinned.dispose();
    task.dispose();
    priority.dispose();
    tags.dispose();
    _canCompose.dispose();
    super.dispose();
  }
}
