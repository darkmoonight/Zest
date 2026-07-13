// app/ui/tasks/widgets/tasks_action.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:zest/features/tasks/application/tasks_notifier.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/core/widgets/form_dirty_tracker.dart';
import 'package:zest/core/widgets/icon_container.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/core/widgets/modal_sheet_animation_mixin.dart';
import 'package:zest/core/widgets/modal_sheet_header.dart';
import 'package:zest/core/widgets/modal_sheet_save_button.dart';
import 'package:zest/core/widgets/modal_sheet_scaffold.dart';
import 'package:zest/core/widgets/text_form.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/color_extensions.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/utils/text_utils.dart';

/// Bottom sheet form for creating or editing a task.
class TasksAction extends ConsumerStatefulWidget {
  /// Creates a [TasksAction].
  const TasksAction({
    super.key,
    required this.text,
    required this.edit,
    this.task,
    this.updateTaskName,
  });

  /// The text.
  final String text;

  /// The edit.
  final bool edit;

  /// The task.
  final Tasks? task;

  /// The update task name.
  final VoidCallback? updateTaskName;

  @override
  /// Creates the state for this widget.
  ConsumerState<TasksAction> createState() => _TasksActionState();
}

/// Widget that tasks action state.
class _TasksActionState extends ConsumerState<TasksAction>
    with SingleTickerProviderStateMixin, ModalSheetAnimationMixin {
  /// Form key.
  final _formKey = GlobalKey<FormState>();

  /// The color notifier.
  late final ValueNotifier<Color> _colorNotifier;

  /// The title controller.
  late final TextEditingController _titleController;

  /// The desc controller.
  late final TextEditingController _descController;

  /// The editing controller.
  late final _EditingController _editingController;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeEditMode();
    initModalSheetAnimations();
  }

  /// Initialize controllers.
  void _initializeControllers() {
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _colorNotifier = ValueNotifier(
      widget.edit
          ? Color(widget.task!.taskColor)
          : AppConstants.defaultTaskColor,
    );
  }

  /// Initialize edit mode.
  void _initializeEditMode() {
    if (widget.edit) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
    }

    _editingController = _EditingController(
      _titleController.text,
      _descController.text,
      _colorNotifier.value,
    );
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _colorNotifier.dispose();
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
        _titleController.clear();
        _descController.clear();
        NavigationHelper.back(context, result: true);
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back(context);
    }
  }

  /// On save pressed.
  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    if (widget.edit) {
      _updateTask();
    } else {
      _addTask();
    }

    NavigationHelper.back(context);
  }

  /// Update task.
  void _updateTask() {
    ref
        .read(tasksNotifierProvider.notifier)
        .updateTask(
          widget.task!,
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
        );
    widget.updateTaskName?.call();
  }

  /// Add task.
  void _addTask() {
    ref
        .read(tasksNotifierProvider.notifier)
        .addTask(
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
        );
    _titleController.clear();
    _descController.clear();
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
      maxHeightFractionDesktop: AppConstants.modalHeightFractionLargeDesktop,
      onPopInvokedWithResult: _onPopInvokedWithResult,
      fadeAnimation: modalSheetFadeAnimation,
      slideAnimation: modalSheetSlideAnimation,
      header: ModalSheetHeader(
        padding: padding,
        title: widget.text,
        subtitle: widget.edit ? 'editCategoryHint'.tr : 'createCategoryHint'.tr,
        leading: Hero(
          tag: widget.edit ? 'task_icon_${widget.task!.id}' : 'task_icon_new',
          child: IconContainer(
            icon: widget.edit
                ? IconsaxPlusBold.edit
                : IconsaxPlusBold.folder_add,
            iconSize: AppConstants.iconSizeLarge,
          ),
        ),
        trailing: ModalSheetSaveButton(
          canComposeListenable: _editingController.canCompose,
          onSave: _onSavePressed,
          accentColor: colorScheme.primary,
          onAccentColor: colorScheme.onPrimary,
          label: 'ready'.tr,
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
                    _buildTitleInput(),
                    SizedBox(height: padding * 1.2),
                    _buildDescriptionInput(),
                    SizedBox(height: padding * 1.5),
                    _buildColorPicker(),
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

  /// Builds the title input widget.
  Widget _buildTitleInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: _titleController,
      labelText: 'enterCategoryName'.tr,
      type: TextInputType.text,
      icon: Icon(IconsaxPlusLinear.edit, color: colorScheme.primary),
      onChanged: (value) => _editingController.title.value = value,
      autofocus: !widget.edit,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'validateName'.tr;
        }
        return null;
      },
    );
  }

  /// Builds the description input widget.
  Widget _buildDescriptionInput() {
    final colorScheme = Theme.of(context).colorScheme;

    return MyTextForm(
      elevation: 0,
      margin: EdgeInsets.zero,
      controller: _descController,
      labelText: 'enterDescription'.tr,
      type: TextInputType.multiline,
      icon: Icon(IconsaxPlusLinear.note_text, color: colorScheme.primary),
      maxLine: null,
      onChanged: (value) => _editingController.description.value = value,
    );
  }

  /// Builds the color picker widget.
  Widget _buildColorPicker() {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<Color>(
      valueListenable: _colorNotifier,
      builder: (context, color, child) {
        return AnimatedContainer(
          duration: AppConstants.shortAnimation,
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: AppConstants.borderWidthThin,
            ),
          ),
          child: Row(
            children: [
              _buildColorPreview(color, colorScheme),
              SizedBox(width: AppConstants.spacingM),
              Expanded(child: _buildColorInfo(color, colorScheme)),
              _buildChangeColorButton(),
            ],
          ),
        );
      },
    );
  }

  /// Builds the color preview widget.
  Widget _buildColorPreview(Color color, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCompact),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ],
      ),
    );
  }

  /// Builds the color info widget.
  Widget _buildColorInfo(Color color, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'selectedColor'.tr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          ),
        ),
        SizedBox(height: AppConstants.spacingXS / 2),
        Text(
          color.toHexString(),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
      ],
    );
  }

  /// Builds the change color button widget.
  Widget _buildChangeColorButton() {
    return FilledButton.tonalIcon(
      onPressed: _showColorPickerDialog,
      icon: const Icon(
        IconsaxPlusLinear.colorfilter,
        size: AppConstants.iconSizeSmall,
      ),
      label: Text(
        'change'.tr,
        style: TextStyle(
          fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  /// Void.
  Future<void> _showColorPickerDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    final Color? newColor = await showDialog<Color>(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: _colorNotifier.value,
        colorScheme: colorScheme,
        isMobile: isMobile,
      ),
    );

    if (newColor != null) {
      _colorNotifier.value = newColor;
      if (widget.edit) {
        _editingController.color.value = newColor;
      }
    }
  }
}

// ==================== Color Picker Dialog ====================

/// Widget that color picker dialog.
class _ColorPickerDialog extends StatefulWidget {
  /// The initial color.
  final Color initialColor;

  /// The color scheme.
  final ColorScheme colorScheme;

  /// The is mobile.
  final bool isMobile;

  /// Creates a [_ColorPickerDialog].
  const _ColorPickerDialog({
    required this.initialColor,
    required this.colorScheme,
    required this.isMobile,
  });

  @override
  /// Creates the state for this widget.
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

/// Widget that color picker dialog state.
class _ColorPickerDialogState extends State<_ColorPickerDialog>
    with SingleTickerProviderStateMixin {
  /// The temp color.
  late Color _tempColor;

  /// The animation controller.
  late AnimationController _animationController;

  /// The scale animation.
  late Animation<double> _scaleAnimation;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _tempColor = widget.initialColor;
    _initAnimation();
  }

  /// Init animation.
  void _initAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _animationController.forward();
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: widget.isMobile
                ? double.infinity
                : AppConstants.maxModalWidth,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusXXLarge,
              ),
              side: BorderSide(
                color: widget.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: AppConstants.borderWidthThin,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: widget.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                Flexible(child: _buildColorPicker()),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header widget.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.borderRadiusXLarge),
      child: Row(
        children: [
          IconContainer(
            icon: IconsaxPlusBold.colorfilter,
            size: 44,
            iconSize: AppConstants.iconSizeLarge,
          ),
          SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'selectColor'.tr,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.colorScheme.onSurface,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      20,
                    ),
                  ),
                ),
                SizedBox(height: AppConstants.spacingXS / 2),
                Text(
                  'selectColorHint'.tr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: widget.colorScheme.onSurfaceVariant,
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

  /// Builds the color picker widget.
  Widget _buildColorPicker() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.borderRadiusXLarge),
      child: ColorPicker(
        color: _tempColor,
        onColorChanged: (color) => setState(() => _tempColor = color),
        borderRadius: AppConstants.borderRadiusMedium,
        padding: EdgeInsets.zero,
        spacing: AppConstants.spacingS,
        runSpacing: AppConstants.spacingS,
        wheelDiameter: widget.isMobile ? 180 : 220,
        wheelWidth: AppConstants.spacingL,
        wheelSquarePadding: AppConstants.spacingS,
        wheelSquareBorderRadius: AppConstants.spacingS,
        wheelHasBorder: false,
        enableShadesSelection: false,
        enableTonalPalette: true,
        tonalColorSameSize: true,
        enableOpacity: false,
        actionButtons: const ColorPickerActionButtons(
          visualDensity: VisualDensity.compact,
          dialogActionButtons: false,
        ),
        pickersEnabled: const {
          ColorPickerType.accent: false,
          ColorPickerType.primary: true,
          ColorPickerType.wheel: false,
          ColorPickerType.both: false,
          ColorPickerType.bw: false,
          ColorPickerType.custom: false,
        },
      ),
    );
  }

  /// Builds the actions widget.
  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: widget.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: AppConstants.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => NavigationHelper.back(context),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppConstants.spacingS),
          FilledButton(
            onPressed: () => NavigationHelper.back(context, result: _tempColor),
            child: Text(
              'select'.tr,
              style: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Editing Controller ====================

/// Tracks dirty state for the task create/edit form.
class _EditingController {
  _EditingController(
    this.initialTitle,
    this.initialDescription,
    this.initialColor,
  ) {
    title.value = initialTitle;
    description.value = initialDescription;
    color.value = initialColor;

    _dirtyTracker.watch(title, _hasChanges);
    _dirtyTracker.watch(description, _hasChanges);
    _dirtyTracker.watch(color, _hasChanges);
  }

  final String? initialTitle;
  final String? initialDescription;
  final Color? initialColor;

  final title = ValueNotifier<String?>(null);
  final description = ValueNotifier<String?>(null);
  final color = ValueNotifier<Color?>(null);

  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  bool _hasChanges() =>
      title.value != initialTitle ||
      description.value != initialDescription ||
      color.value != initialColor;

  void dispose() {
    _dirtyTracker.dispose();
    title.dispose();
    description.dispose();
    color.dispose();
  }
}
