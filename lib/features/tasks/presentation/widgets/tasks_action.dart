// app/ui/tasks/widgets/tasks_action.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/utils/default_category.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
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

  /// Sheet title shown in the modal header.
  final String text;

  /// Whether this sheet edits an existing task (`true`) or creates one.
  final bool edit;

  /// Existing task when [edit] is true; null when creating.
  final Tasks? task;

  /// Optional callback after the task title is saved (e.g. refresh parent UI).
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

  /// Whether this category should be the user default.
  late final ValueNotifier<bool> _isDefaultNotifier;

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
    final settings = ref.read(settingsProvider);
    _isDefaultNotifier = ValueNotifier(
      widget.edit && settings.defaultCategoryId == widget.task!.id,
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
      _isDefaultNotifier.value,
    );
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _colorNotifier.dispose();
    _isDefaultNotifier.dispose();
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
  Future<void> _onSavePressed() async {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    if (widget.edit) {
      await _updateTask();
    } else {
      await _addTask();
    }

    if (mounted) NavigationHelper.back(context);
  }

  /// Update task.
  Future<void> _updateTask() async {
    await ref
        .read(tasksNotifierProvider.notifier)
        .updateTask(
          widget.task!,
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
        );
    await _applyDefaultPreference(widget.task!);
    widget.updateTaskName?.call();
  }

  /// Add task.
  Future<void> _addTask() async {
    final created = await ref
        .read(tasksNotifierProvider.notifier)
        .addTask(
          _titleController.text,
          _descController.text,
          _colorNotifier.value,
        );
    if (created != null) {
      await _applyDefaultPreference(created);
    }
    _titleController.clear();
    _descController.clear();
  }

  /// Persists or clears the user default category for [task].
  Future<void> _applyDefaultPreference(Tasks task) async {
    final wantDefault = _isDefaultNotifier.value;
    final currentId = ref.read(settingsProvider).defaultCategoryId;
    final isCurrentlyDefault = currentId == task.id;

    if (wantDefault && !isCurrentlyDefault) {
      await setDefaultCategory(ref, task: task);
      if (mounted) showSnackBar('defaultCategorySet'.tr);
    } else if (!wantDefault && isCurrentlyDefault) {
      await setDefaultCategory(ref, task: null);
      if (mounted) showSnackBar('defaultCategoryCleared'.tr);
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
                    SizedBox(height: padding * 1.2),
                    _buildDefaultToggle(),
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

  /// Toggle to mark this category as the user default for new todos.
  Widget _buildDefaultToggle() {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<bool>(
      valueListenable: _isDefaultNotifier,
      builder: (context, isDefault, _) {
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
              _buildDefaultPreview(isDefault, colorScheme),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(child: _buildDefaultInfo(isDefault, colorScheme)),
              _buildDefaultActionButton(isDefault, colorScheme),
            ],
          ),
        );
      },
    );
  }

  /// 44×44 preview matching the color swatch layout.
  Widget _buildDefaultPreview(bool isDefault, ColorScheme colorScheme) {
    final accent = isDefault
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isDefault
            ? colorScheme.primary.withValues(alpha: 0.18)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusCompact),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Icon(
        isDefault ? IconsaxPlusBold.star : IconsaxPlusLinear.star,
        color: accent,
        size: AppConstants.iconSizeMedium,
      ),
    );
  }

  /// Label + status, same typography as the color info column.
  Widget _buildDefaultInfo(bool isDefault, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'setDefaultCategory'.tr,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
          ),
        ),
        SizedBox(height: AppConstants.spacingXS / 2),
        Text(
          isDefault
              ? 'defaultCategoryStatusOn'.tr
              : 'defaultCategoryStatusOff'.tr,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
          ),
        ),
      ],
    );
  }

  /// Tonal action button matching the color "Change" control.
  Widget _buildDefaultActionButton(bool isDefault, ColorScheme colorScheme) {
    return FilledButton.tonalIcon(
      onPressed: () {
        final next = !isDefault;
        _isDefaultNotifier.value = next;
        _editingController.isDefault.value = next;
      },
      icon: Icon(
        isDefault ? IconsaxPlusBold.star : IconsaxPlusLinear.star,
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
        backgroundColor: isDefault
            ? colorScheme.primary.withValues(alpha: 0.15)
            : null,
        foregroundColor: isDefault ? colorScheme.primary : null,
      ),
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
    this.initialIsDefault,
  ) {
    title.value = initialTitle;
    description.value = initialDescription;
    color.value = initialColor;
    isDefault.value = initialIsDefault;

    _dirtyTracker.watch(title, _hasChanges);
    _dirtyTracker.watch(description, _hasChanges);
    _dirtyTracker.watch(color, _hasChanges);
    _dirtyTracker.watch(isDefault, _hasChanges);
  }

  final String? initialTitle;
  final String? initialDescription;
  final Color? initialColor;
  final bool initialIsDefault;

  final title = ValueNotifier<String?>(null);
  final description = ValueNotifier<String?>(null);
  final color = ValueNotifier<Color?>(null);
  final isDefault = ValueNotifier<bool>(false);

  final FormDirtyTracker _dirtyTracker = FormDirtyTracker();

  /// Whether the task form has unsaved changes.
  ValueListenable<bool> get canCompose => _dirtyTracker.canCompose;

  bool _hasChanges() =>
      title.value != initialTitle ||
      description.value != initialDescription ||
      color.value != initialColor ||
      isDefault.value != initialIsDefault;

  void dispose() {
    _dirtyTracker.dispose();
    title.dispose();
    description.dispose();
    color.dispose();
    isDefault.dispose();
  }
}
