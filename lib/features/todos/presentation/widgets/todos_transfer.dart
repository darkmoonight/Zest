import 'package:flutter/foundation.dart' hide Category;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/domain/entities/entities.dart';
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
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/core/widgets/text_form.dart';

part 'todos_transfer/todos_transfer_fields.dart';
part 'todos_transfer/todos_transfer_form_state.dart';
part 'todos_transfer/todos_transfer_submit.dart';

/// Transfer target mode: category or parent item.
enum TransferMode { category, todo }

/// Dialog for moving items to another category or parent.
class TodosTransfer extends ConsumerStatefulWidget {
  /// Creates a [TodosTransfer].
  const TodosTransfer({super.key, required this.text, required this.todos});

  /// Dialog title describing the transfer action.
  final String text;

  /// Items being moved to the chosen destination.
  final List<Todo> todos;

  @override
  /// Creates the state for this widget.
  ConsumerState<TodosTransfer> createState() => _TodosTransferState();
}

/// State for [TodosTransfer] handling transfer mode and selection.
class _TodosTransferState extends ConsumerState<TodosTransfer>
    with
        SingleTickerProviderStateMixin,
        ModalSheetAnimationMixin,
        _TodosTransferFields,
        _TodosTransferFormState,
        _TodosTransferSubmit {
  @override
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
}
