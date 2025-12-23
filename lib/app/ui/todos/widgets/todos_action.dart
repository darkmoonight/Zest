import 'package:flutter/foundation.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/ui/responsive_utils.dart';
import 'package:zest/app/ui/todos/view/todo_todos.dart';
import 'package:zest/app/utils/show_dialog.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final formKey = GlobalKey<FormState>();
  final todoController = Get.put(TodoController());
  Tasks? selectedTask;
  List<Tasks>? task;
  final FocusNode categoryFocusNode = FocusNode();
  final FocusNode tagsFocusNode = FocusNode();
  final TextEditingController textTodoController = TextEditingController();
  final TextEditingController titleTodoEdit = TextEditingController();
  final TextEditingController descTodoEdit = TextEditingController();
  final TextEditingController timeTodoEdit = TextEditingController();
  final TextEditingController tagsTodoEdit = TextEditingController();

  bool todoPined = false;
  Priority todoPriority = Priority.none;
  List<String> todoTags = [];

  late final _EditingController controller;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      _initializeEditMode();
    }

    controller = _EditingController(
      titleTodoEdit.text,
      descTodoEdit.text,
      timeTodoEdit.text,
      todoPined,
      selectedTask,
      todoPriority,
      todoTags,
    );

    categoryFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

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

  void _initializeEditMode() {
    selectedTask = widget.todo!.task.value;
    textTodoController.text = widget.todo!.task.value!.title;
    titleTodoEdit.text = widget.todo!.name;
    descTodoEdit.text = widget.todo!.description;
    timeTodoEdit.text = _formatDateTime(widget.todo!.todoCompletedTime);
    todoPined = widget.todo!.fix;
    todoPriority = widget.todo!.priority;
    todoTags = widget.todo!.tags;
  }

  String _formatDateTime(DateTime? dateTime) => dateTime != null
      ? timeformat.value == '12'
            ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(dateTime)
            : DateFormat.yMMMEd(locale.languageCode).add_Hm().format(dateTime)
      : '';

  Future<void> onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) {
      return;
    } else if (!controller.canCompose.value) {
      Get.back();
      return;
    }

    final shouldPop = await showAdaptiveDialogTextIsNotEmpty(
      context: context,
      onPressed: () {
        _clearControllers();
        Get.back(result: true);
      },
    );

    if (shouldPop == true && mounted) {
      Get.back();
    }
  }

  void _clearControllers() {
    titleTodoEdit.clear();
    descTodoEdit.clear();
    timeTodoEdit.clear();
    textTodoController.clear();
    tagsTodoEdit.clear();
    todoTags = [];
  }

  void onPressed() {
    if (formKey.currentState!.validate()) {
      _trimControllers();
      _saveTodo();
      _clearControllers();
      Get.back();
    }
  }

  void _trimControllers() {
    titleTodoEdit.text = titleTodoEdit.text.trim();
    descTodoEdit.text = descTodoEdit.text.trim();
  }

  void _saveTodo() {
    if (widget.edit) {
      todoController.updateTodo(
        widget.todo!,
        selectedTask!,
        titleTodoEdit.text,
        descTodoEdit.text,
        timeTodoEdit.text,
        todoPined,
        todoPriority,
        todoTags,
      );
    } else {
      if (widget.category) {
        todoController.addTodo(
          selectedTask!,
          titleTodoEdit.text,
          descTodoEdit.text,
          timeTodoEdit.text,
          todoPined,
          todoPriority,
          todoTags,
        );
      } else if (widget.todo != null) {
        final parentTodo = widget.todo!;
        final parentTask = parentTodo.task.value;
        if (parentTask == null) {
          return;
        }

        todoController.addTodo(
          parentTask,
          titleTodoEdit.text,
          descTodoEdit.text,
          timeTodoEdit.text,
          todoPined,
          todoPriority,
          todoTags,
          parent: parentTodo,
        );
      } else {
        todoController.addTodo(
          widget.task!,
          titleTodoEdit.text,
          descTodoEdit.text,
          timeTodoEdit.text,
          todoPined,
          todoPriority,
          todoTags,
        );
      }
    }
  }

  @override
  void dispose() {
    textTodoController.dispose();
    titleTodoEdit.dispose();
    descTodoEdit.dispose();
    timeTodoEdit.dispose();
    tagsTodoEdit.dispose();
    controller.dispose();
    categoryFocusNode.dispose();
    tagsFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<List<Tasks>> getTaskAll(String pattern) async {
    final getTask = isar.tasks.filter().archiveEqualTo(false).findAllSync();
    return getTask.where((element) {
      final title = element.title.toLowerCase();
      final query = pattern.toLowerCase();
      return title.contains(query);
    }).toList();
  }

  Iterable<String> _getAllTags(String pattern) {
    final allTodos = isar.todos.where().findAllSync();
    final Set<String> tagsSet = {};
    for (final t in allTodos) {
      for (final tag in t.tags) {
        final trimmed = tag.trim();
        if (trimmed.isNotEmpty) tagsSet.add(trimmed);
      }
    }

    final List<String> tagsList = tagsSet.toList();
    if (pattern.trim().isEmpty) return tagsList;
    final q = pattern.toLowerCase();
    return tagsList.where((e) => e.toLowerCase().contains(q));
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isEmpty) return;
    if (!todoTags.contains(tag)) {
      setState(() {
        todoTags = List.from(todoTags)..add(tag);
        controller.tags.value = todoTags;
      });
    }
  }

  void _onTagSelected(String tag) {
    _addTag(tag);
    tagsTodoEdit.clear();
    tagsFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final isMobile = ResponsiveUtils.isMobile(context);
    final maxWidth = isMobile ? double.infinity : 600.0;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
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
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(padding * 1.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (widget.category) ...[
                                    _buildCategorySection(colorScheme),
                                    SizedBox(height: padding * 1.5),
                                  ],
                                  _buildBasicInfoSection(colorScheme, padding),
                                  SizedBox(height: padding * 1.5),
                                  _buildTagsSection(colorScheme, padding),
                                  SizedBox(height: padding * 1.5),
                                  _buildAttributesSection(colorScheme, padding),
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
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              widget.edit ? IconsaxPlusBold.edit : IconsaxPlusBold.task_square,
              size: 24,
              color: colorScheme.onTertiaryContainer,
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
        ],
      ),
    );
  }

  Widget _buildCategorySection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              IconsaxPlusBold.folder_2,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'category'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RawAutocomplete<Tasks>(
          focusNode: categoryFocusNode,
          textEditingController: textTodoController,
          fieldViewBuilder: _buildCategoryFieldView,
          optionsBuilder: _buildCategoryOptions,
          onSelected: _onCategorySelected,
          displayStringForOption: (Tasks option) => option.title,
          optionsViewBuilder: _buildCategoryOptionsView,
        ),
      ],
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
      controller: textTodoController,
      focusNode: categoryFocusNode,
      labelText: 'selectCategory'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.folder_2, color: colorScheme.primary),
      iconButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (textTodoController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                IconsaxPlusLinear.close_square,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                textTodoController.clear();
                setState(() {});
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
                setState(() {});
              }
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

  Future<List<Tasks>> _buildCategoryOptions(
    TextEditingValue textEditingValue,
  ) async => await getTaskAll(textEditingValue.text);

  void _onCategorySelected(Tasks selection) {
    textTodoController.text = selection.title;
    selectedTask = selection;
    setState(() {
      if (widget.edit) controller.task.value = selectedTask;
    });
    categoryFocusNode.unfocus();
  }

  Widget _buildCategoryOptionsView(
    BuildContext context,
    AutocompleteOnSelected<Tasks> onSelected,
    Iterable<Tasks> options,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          elevation: 8,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
          color: colorScheme.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
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

  Widget _buildBasicInfoSection(ColorScheme colorScheme, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              IconsaxPlusBold.note_text,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'basicInfo'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ],
        ),
        SizedBox(height: padding),
        Text(
          'name'.tr,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
        const SizedBox(height: 8),
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: titleTodoEdit,
          labelText: 'enterTodoName'.tr,
          type: TextInputType.multiline,
          icon: Icon(IconsaxPlusLinear.edit, color: colorScheme.primary),
          onChanged: (value) => controller.title.value = value,
          autofocus: !widget.edit,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'validateName'.tr;
            }
            return null;
          },
          maxLine: null,
        ),
        SizedBox(height: padding * 1.2),
        Text(
          'description'.tr,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
        const SizedBox(height: 8),
        MyTextForm(
          elevation: 0,
          margin: EdgeInsets.zero,
          controller: descTodoEdit,
          labelText: 'enterDescription'.tr,
          type: TextInputType.multiline,
          icon: Icon(IconsaxPlusLinear.note_text, color: colorScheme.primary),
          maxLine: null,
          onChanged: (value) => controller.description.value = value,
        ),
      ],
    );
  }

  Widget _buildTagsSection(ColorScheme colorScheme, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(IconsaxPlusBold.tag, size: 18, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'tags'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RawAutocomplete<String>(
          focusNode: tagsFocusNode,
          textEditingController: tagsTodoEdit,
          fieldViewBuilder: _buildTagsFieldView,
          optionsBuilder: _buildTagOptions,
          onSelected: (String selection) => _onTagSelected(selection),
          optionsViewBuilder: _buildTagOptionsView,
        ),
        if (todoTags.isNotEmpty) ...[
          SizedBox(height: padding),
          _buildChips(colorScheme),
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
      focusNode: tagsFocusNode,
      onFieldSubmitted: (value) {
        _addTag(value);
        fieldTextEditingController.clear();
        tagsFocusNode.requestFocus();
      },
    );
  }

  Future<Iterable<String>> _buildTagOptions(
    TextEditingValue textEditingValue,
  ) async => _getAllTags(textEditingValue.text);

  Widget _buildTagOptionsView(
    BuildContext context,
    AutocompleteOnSelected<String> onSelected,
    Iterable<String> options,
  ) {
    final list = options.toList();
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.topCenter,
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
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                final tag = list[index];
                return InkWell(
                  onTap: () => onSelected(tag),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          IconsaxPlusLinear.tag,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
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

  Widget _buildChips(ColorScheme colorScheme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        todoTags.length,
        (i) => InputChip(
          label: Text(todoTags[i]),
          deleteIcon: Icon(
            IconsaxPlusLinear.close_circle,
            size: 18,
            color: colorScheme.onSecondaryContainer,
          ),
          onDeleted: () => setState(() {
            todoTags = List.from(todoTags)..removeAt(i);
            controller.tags.value = todoTags;
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

  Widget _buildAttributesSection(ColorScheme colorScheme, double padding) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              IconsaxPlusBold.setting_2,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'todoAttributes'.tr,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              ),
            ),
          ],
        ),
        SizedBox(height: padding),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 10,
            children: [
              if (widget.edit) _buildSubTask(colorScheme),
              _buildDateTimeWidget(colorScheme),
              _buildPriorityWidget(colorScheme),
              _buildFixedWidget(colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubTask(ColorScheme colorScheme) {
    return FilledButton.tonal(
      onPressed: () {
        Get.back();
        Get.key.currentState!.push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                TodosTodo(key: ValueKey(widget.todo!.id), todo: widget.todo!),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.task_square,
            size: 18,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'subTask'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeWidget(ColorScheme colorScheme) {
    final hasTime = timeTodoEdit.text.isNotEmpty;
    return FilledButton.tonal(
      onPressed: _showDateTimePicker,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: hasTime
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.calendar,
            size: 18,
            color: hasTime
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            hasTime ? timeTodoEdit.text : 'timeComplete'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              color: hasTime
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSecondaryContainer,
            ),
          ),
          if (hasTime) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                timeTodoEdit.clear();
                setState(() {
                  if (widget.edit) controller.time.value = timeTodoEdit.text;
                });
              },
              child: Icon(
                IconsaxPlusLinear.close_circle,
                size: 16,
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
      minutesInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      transitionDuration: const Duration(milliseconds: 200),
    );

    if (dateTime != null) {
      final String formattedDate = timeformat.value == '12'
          ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(dateTime)
          : DateFormat.yMMMEd(locale.languageCode).add_Hm().format(dateTime);
      timeTodoEdit.text = formattedDate;
      setState(() {
        if (widget.edit) controller.time.value = formattedDate;
      });
    }
  }

  Widget _buildPriorityWidget(ColorScheme colorScheme) {
    return MenuAnchor(
      alignmentOffset: const Offset(0, -10),
      style: MenuStyle(
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        elevation: WidgetStateProperty.all(8),
        alignment: AlignmentDirectional.bottomStart,
      ),
      menuChildren: [
        for (final priority in Priority.values)
          MenuItemButton(
            leadingIcon: Icon(IconsaxPlusLinear.flag, color: priority.color),
            child: Text(priority.name.tr),
            onPressed: () {
              setState(() {
                todoPriority = priority;
                controller.priority.value = priority;
              });
            },
          ),
      ],
      builder: (context, menuController, _) => ValueListenableBuilder(
        valueListenable: controller.priority,
        builder: (context, priority, _) => FilledButton.tonal(
          onPressed: () {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(IconsaxPlusLinear.flag, size: 18, color: priority.color),
              const SizedBox(width: 8),
              Text(
                priority.name.tr,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixedWidget(ColorScheme colorScheme) {
    return FilterChip(
      avatar: Icon(
        todoPined
            ? IconsaxPlusBold.attach_square
            : IconsaxPlusLinear.attach_square,
        size: 18,
        color: todoPined
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSecondaryContainer,
      ),
      label: Text(
        'todoPined'.tr,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        ),
      ),
      selected: todoPined,
      onSelected: (value) => setState(() {
        todoPined = value;
        if (widget.edit) controller.pined.value = value;
      }),
      backgroundColor: colorScheme.secondaryContainer,
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: todoPined
            ? colorScheme.onPrimaryContainer
            : colorScheme.onSecondaryContainer,
      ),
      side: BorderSide.none,
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
            text: 'ready'.tr,
            onPressed: canCompose ? onPressed : null,
          ),
        ),
      ),
    );
  }
}

class _EditingController extends ChangeNotifier {
  _EditingController(
    this.initialTitle,
    this.initialDescription,
    this.initialTime,
    this.initialPined,
    this.initialTask,
    this.initialPriority,
    this.initialTags,
  ) {
    title.value = initialTitle;
    description.value = initialDescription;
    time.value = initialTime;
    pined.value = initialPined;
    task.value = initialTask;
    priority.value = initialPriority;
    tags.value = initialTags;

    title.addListener(_updateCanCompose);
    description.addListener(_updateCanCompose);
    time.addListener(_updateCanCompose);
    pined.addListener(_updateCanCompose);
    task.addListener(_updateCanCompose);
    priority.addListener(_updateCanCompose);
    tags.addListener(_updateCanCompose);
  }

  final String? initialTitle;
  final String? initialDescription;
  final String? initialTime;
  final bool? initialPined;
  final Tasks? initialTask;
  final Priority initialPriority;
  final List<String>? initialTags;

  final title = ValueNotifier<String?>(null);
  final description = ValueNotifier<String?>(null);
  final time = ValueNotifier<String?>(null);
  final pined = ValueNotifier<bool?>(null);
  final task = ValueNotifier<Tasks?>(null);
  final priority = ValueNotifier<Priority>(Priority.none);
  final tags = ValueNotifier<List<String>?>(null);

  final _canCompose = ValueNotifier(false);
  ValueListenable<bool> get canCompose => _canCompose;

  void _updateCanCompose() => _canCompose.value =
      (title.value != initialTitle) ||
      (description.value != initialDescription) ||
      (time.value != initialTime) ||
      (pined.value != initialPined) ||
      (task.value != initialTask) ||
      (priority.value != initialPriority) ||
      (tags.value != initialTags);

  @override
  void dispose() {
    title.removeListener(_updateCanCompose);
    description.removeListener(_updateCanCompose);
    time.removeListener(_updateCanCompose);
    pined.removeListener(_updateCanCompose);
    task.removeListener(_updateCanCompose);
    priority.removeListener(_updateCanCompose);
    tags.removeListener(_updateCanCompose);
    super.dispose();
  }
}
