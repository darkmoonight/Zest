import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/features/settings/presentation/widgets/settings_list_dialog_shell.dart';
import 'package:zest/i18n/tr.dart';

/// Outcome of the due date/time picker.
sealed class DueDateTimeResult {
  const DueDateTimeResult();
}

/// User picked a concrete [dateTime].
class DueDateTimePicked extends DueDateTimeResult {
  /// Creates a picked result.
  const DueDateTimePicked(this.dateTime);

  /// Selected date and time.
  final DateTime dateTime;
}

/// User cleared the deadline.
class DueDateTimeCleared extends DueDateTimeResult {
  /// Creates a cleared result.
  const DueDateTimeCleared();
}

/// Shows a classical due date/time dialog (same shell style as recurrence).
///
/// Returns null when dismissed without a choice.
Future<DueDateTimeResult?> showDueDateTimePicker({
  required BuildContext context,
  DateTime? current,
  required bool use24h,
  Duration selectableRange = AppConstants.calendarSelectableRange,
}) async {
  return NavigationHelper.showAppDialog<DueDateTimeResult>(
    context: context,
    child: _DueDateTimeDialog(
      current: current,
      use24h: use24h,
      selectableRange: selectableRange,
    ),
  );
}

class _DueDateTimeDialog extends StatelessWidget {
  const _DueDateTimeDialog({
    required this.current,
    required this.use24h,
    required this.selectableRange,
  });

  final DateTime? current;
  final bool use24h;
  final Duration selectableRange;

  @override
  Widget build(BuildContext context) {
    return SettingsListDialogShell(
      header: SettingsListDialogHeader(
        title: 'timeComplete'.tr,
        icon: IconsaxPlusBold.calendar_1,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsDialogListTile(
            title: 'dueDateTimePick'.tr,
            isSelected: current != null,
            onTap: () => _pickDateTime(context),
          ),
          SettingsDialogListTile(
            title: 'dueDateNone'.tr,
            isSelected: current == null,
            onTap: () => NavigationHelper.back(
              context,
              result: const DueDateTimeCleared(),
            ),
          ),
        ],
      ),
      footer: const SettingsListDialogDismissAction(labelKey: 'cancel'),
    );
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final initial = current ?? now;
    final firstDate = now.subtract(const Duration(days: 1));
    final lastDate = now.add(selectableRange);

    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate)
          ? firstDate
          : (initial.isAfter(lastDate) ? lastDate : initial),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24h),
          child: child!,
        );
      },
    );
    if (time == null || !context.mounted) return;

    NavigationHelper.back(
      context,
      result: DueDateTimePicked(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
    );
  }
}
