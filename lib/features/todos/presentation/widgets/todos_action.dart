import 'package:flutter/foundation.dart' hide Category;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/app_log.dart';
import 'package:zest/core/utils/date_time_format_helper.dart';
import 'package:zest/core/utils/default_category.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/core/utils/text_utils.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/core/widgets/form_dirty_tracker.dart';
import 'package:zest/core/widgets/autocomplete_options_dropdown.dart';
import 'package:zest/core/widgets/icon_container.dart';
import 'package:zest/core/widgets/modal_sheet_animation_mixin.dart';
import 'package:zest/core/widgets/modal_sheet_header.dart';
import 'package:zest/core/widgets/modal_sheet_save_button.dart';
import 'package:zest/core/widgets/modal_sheet_scaffold.dart';
import 'package:zest/core/widgets/recurrence_form_fields.dart';
import 'package:zest/core/widgets/text_form.dart';
import 'package:zest/domain/entities/entities.dart';
import 'package:zest/domain/enums/enums.dart';
import 'package:zest/features/todos/presentation/utils/priority_colors.dart';
import 'package:zest/features/todos/presentation/view/todo_todos.dart';
import 'package:zest/features/todos/presentation/widgets/due_datetime_picker.dart';
import 'package:zest/features/todos/presentation/widgets/recurrence_picker.dart';
import 'package:zest/i18n/tr.dart';

/// Bottom sheet form for creating or editing a list item.
part 'todos_action/todos_action_fields.dart';
part 'todos_action/todos_action_form_state.dart';
part 'todos_action/todos_action_save.dart';
part 'todos_action/todos_action_category.dart';
part 'todos_action/todos_action_tags.dart';
part 'todos_action/todos_action_attributes.dart';

class TodosAction extends ConsumerStatefulWidget {
  /// Creates a [TodosAction].
  const TodosAction({
    super.key,
    required this.text,
    required this.edit,
    required this.showCategory,
    this.category,
    this.todo,
  });

  /// The text.
  final String text;

  /// Prefill / scope category when creating under a category.
  final Category? category;

  /// The item.
  final Todo? todo;

  /// The edit.
  final bool edit;

  /// Whether the category picker is shown.
  final bool showCategory;

  @override
  /// Creates the state for this widget.
  ConsumerState<TodosAction> createState() => _TodosActionState();
}

/// State for [TodosAction] managing form fields and submission.
class _TodosActionState extends ConsumerState<TodosAction>
    with
        WidgetsBindingObserver,
        SingleTickerProviderStateMixin,
        ModalSheetAnimationMixin,
        _TodosActionFields,
        _TodosActionFormState,
        _TodosActionSave,
        _TodosActionCategory,
        _TodosActionTags,
        _TodosActionAttributes {
  @override
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
                    if (widget.showCategory) ...[
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
}
