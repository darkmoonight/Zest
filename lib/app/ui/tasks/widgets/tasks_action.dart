// app/ui/tasks/widgets/tasks_action.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/tasks/widgets/common_container.dart';
import 'package:zest/app/ui/widgets/confirmation_dialog.dart';
import 'package:zest/app/ui/widgets/text_form.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/color_extensions.dart';
import 'package:zest/app/utils/navigation_helper.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/text_utils.dart';

class TasksAction extends StatefulWidget {
  const TasksAction({
    super.key,
    required this.text,
    required this.edit,
    this.task,
    this.updateTaskName,
  });

  final String text;
  final bool edit;
  final Tasks? task;
  final VoidCallback? updateTaskName;

  @override
  State<TasksAction> createState() => _TasksActionState();
}

class _TasksActionState extends State<TasksAction>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TodoController _todoController = Get.find<TodoController>();
  late final ValueNotifier<Color> _colorNotifier;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final _EditingController _editingController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeEditMode();
    _initAnimations();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descController = TextEditingController();
    _colorNotifier = ValueNotifier(
      widget.edit ? Color(widget.task!.taskColor) : const Color(0xFF2196F3),
    );
  }

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

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _colorNotifier.dispose();
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
        _titleController.clear();
        _descController.clear();
        NavigationHelper.back(result: true);
      },
    );

    if (shouldPop == true && mounted) {
      NavigationHelper.back();
    }
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;

    TextUtils.trimController(_titleController);
    TextUtils.trimController(_descController);

    if (widget.edit) {
      _updateTask();
    } else {
      _addTask();
    }

    NavigationHelper.back();
  }

  void _updateTask() {
    _todoController.updateTask(
      widget.task!,
      _titleController.text,
      _descController.text,
      _colorNotifier.value,
    );
    widget.updateTaskName?.call();
  }

  void _addTask() {
    _todoController.addTask(
      _titleController.text,
      _descController.text,
      _colorNotifier.value,
    );
    _titleController.clear();
    _descController.clear();
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
              MediaQuery.of(context).size.height * (isMobile ? 0.95 : 0.85),
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
          Hero(
            tag: widget.edit ? 'task_icon_${widget.task!.id}' : 'task_icon_new',
            child: IconContainer(
              icon: widget.edit
                  ? IconsaxPlusBold.edit
                  : IconsaxPlusBold.folder_add,
              size: 44,
              iconSize: AppConstants.iconSizeLarge,
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
                  widget.edit ? 'editCategoryHint'.tr : 'createCategoryHint'.tr,
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
                ? colorScheme.primary
                : colorScheme.surfaceContainerHigh,
            elevation: canCompose ? AppConstants.elevationLow : 0,
            shadowColor: colorScheme.primary.withValues(alpha: 0.3),
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
                          ? colorScheme.onPrimary
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
                            ? colorScheme.onPrimary
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

  Widget _buildColorPreview(Color color, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: AppConstants.shortAnimation,
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall + 2),
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

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ColorScheme colorScheme;
  final bool isMobile;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.colorScheme,
    required this.isMobile,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog>
    with SingleTickerProviderStateMixin {
  late Color _tempColor;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tempColor = widget.initialColor;
    _initAnimation();
  }

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
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
            onPressed: () => NavigationHelper.back(),
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
            onPressed: () => NavigationHelper.back(result: _tempColor),
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

class _EditingController extends ChangeNotifier {
  _EditingController(
    this.initialTitle,
    this.initialDescription,
    this.initialColor,
  ) {
    _initializeListeners();
  }

  final String? initialTitle;
  final String? initialDescription;
  final Color? initialColor;

  final title = ValueNotifier<String?>(null);
  final description = ValueNotifier<String?>(null);
  final color = ValueNotifier<Color?>(null);
  final _canCompose = ValueNotifier<bool>(false);

  ValueListenable<bool> get canCompose => _canCompose;

  void _initializeListeners() {
    title.value = initialTitle;
    description.value = initialDescription;
    color.value = initialColor;

    title.addListener(_updateCanCompose);
    description.addListener(_updateCanCompose);
    color.addListener(_updateCanCompose);
  }

  void _updateCanCompose() {
    _canCompose.value =
        title.value != initialTitle ||
        description.value != initialDescription ||
        color.value != initialColor;
  }

  @override
  void dispose() {
    title.removeListener(_updateCanCompose);
    description.removeListener(_updateCanCompose);
    color.removeListener(_updateCanCompose);
    title.dispose();
    description.dispose();
    color.dispose();
    _canCompose.dispose();
    super.dispose();
  }
}
