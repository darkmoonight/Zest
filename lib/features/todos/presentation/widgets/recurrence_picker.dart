import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/settings/presentation/widgets/selection_dialog.dart';
import 'package:zest/features/settings/presentation/widgets/settings_list_dialog_shell.dart';
import 'package:zest/i18n/tr.dart';

/// i18n keys for Monday…Sunday ([DateTime.weekday] 1–7).
const kWeekdayI18nKeys = [
  'monday',
  'tuesday',
  'wednesday',
  'thursday',
  'friday',
  'saturday',
  'sunday',
];

/// Sentinel meaning "keep current / no change" was cancelled at mode step.
const _cancelledMinute = -2;

/// Result of a recurrence picker session.
class RecurrenceSelection {
  /// Creates a selection with frequency, mode, weekdays, and optional time.
  const RecurrenceSelection({
    required this.frequency,
    this.weekdays = const [],
    this.mode = RecurrenceMode.clone,
    this.minuteOfDay,
  });

  /// Chosen frequency.
  final RecurrenceFrequency frequency;

  /// Weekdays 1–7 when [frequency] is weekly.
  final List<int> weekdays;

  /// Clone (new copy) vs reopen the same list item.
  final RecurrenceMode mode;

  /// Reminder time as minutes from midnight; null = no forced time.
  final int? minuteOfDay;
}

/// Localized label for a recurrence [frequency].
String recurrenceFrequencyLabel(RecurrenceFrequency frequency) =>
    frequency == RecurrenceFrequency.none
    ? 'recurrenceNone'.tr
    : frequency.name.tr;

/// Localized label for a recurrence [mode].
String recurrenceModeLabel(RecurrenceMode mode) => switch (mode) {
  RecurrenceMode.clone => 'recurrenceModeClone'.tr,
  RecurrenceMode.reopen => 'recurrenceModeReopen'.tr,
};

/// Formats [minuteOfDay] as `H:mm` / localized 12h using [languageCode].
String? formatRecurrenceMinuteOfDay(
  int? minuteOfDay, {
  bool use24h = true,
  String? languageCode,
}) {
  if (minuteOfDay == null) return null;
  final clamped = minuteOfDay.clamp(0, 24 * 60 - 1);
  final hour = clamped ~/ 60;
  final minute = clamped % 60;
  final locale = languageCode ?? LocaleSettings.currentLocale.languageCode;
  final at = DateTime(2000, 1, 1, hour, minute);
  if (use24h) {
    return DateFormat.Hm(locale).format(at);
  }
  return DateFormat.jm(locale).format(at);
}

/// Chip label: frequency, optionally with reminder time.
String recurrenceChipLabel(
  RecurrenceFrequency frequency, {
  int? minuteOfDay,
  bool use24h = true,
}) {
  if (frequency == RecurrenceFrequency.none) return 'recurrence'.tr;
  final time = formatRecurrenceMinuteOfDay(minuteOfDay, use24h: use24h);
  final base = recurrenceFrequencyLabel(frequency);
  return time == null ? base : '$base · $time';
}

/// Subtitle for category card: frequency + mode (+ time).
String recurrenceSummaryLabel({
  required RecurrenceFrequency frequency,
  required RecurrenceMode mode,
  int? minuteOfDay,
  bool use24h = true,
}) {
  if (!RecurrenceService.isRecurring(frequency)) {
    return recurrenceFrequencyLabel(frequency);
  }
  final parts = <String>[
    recurrenceFrequencyLabel(frequency),
    recurrenceModeLabel(mode),
  ];
  final time = formatRecurrenceMinuteOfDay(minuteOfDay, use24h: use24h);
  if (time != null) parts.add(time);
  return parts.join(' · ');
}

/// Shows frequency, mode, weekdays, and optional time; null if cancelled.
///
/// When [allowCloneMode] is false (category habits), mode is forced to reopen
/// and the mode step is skipped — clone spawning is item-level only.
Future<RecurrenceSelection?> showRecurrencePicker({
  required BuildContext context,
  required RecurrenceFrequency current,
  required List<int> currentWeekdays,
  RecurrenceMode currentMode = RecurrenceMode.clone,
  int? currentMinuteOfDay,
  bool use24h = true,
  bool allowCloneMode = true,
}) async {
  RecurrenceFrequency? pickedFrequency;
  await showSelectionDialog<RecurrenceFrequency>(
    context: context,
    title: 'recurrence'.tr,
    icon: IconsaxPlusBold.repeat,
    items: RecurrenceFrequency.values,
    currentValue: current,
    itemBuilder: recurrenceFrequencyLabel,
    onSelected: (value) => pickedFrequency = value,
  );
  final frequency = pickedFrequency;
  if (frequency == null || !context.mounted) return null;

  if (frequency == RecurrenceFrequency.none) {
    return const RecurrenceSelection(frequency: RecurrenceFrequency.none);
  }

  var weekdays = List<int>.from(currentWeekdays);
  if (frequency == RecurrenceFrequency.weekly) {
    final pickedWeekdays = await _showWeeklyRecurrenceDialog(
      context: context,
      initial: weekdays.isEmpty ? <int>[DateTime.now().weekday] : weekdays,
    );
    if (!context.mounted) return null;
    if (pickedWeekdays != null) {
      weekdays = pickedWeekdays;
    }
  }

  late final RecurrenceMode mode;
  if (!allowCloneMode) {
    mode = RecurrenceMode.reopen;
  } else {
    RecurrenceMode? pickedMode;
    await showSelectionDialog<RecurrenceMode>(
      context: context,
      title: 'recurrenceMode'.tr,
      icon: IconsaxPlusBold.repeat,
      items: RecurrenceMode.values,
      currentValue: currentMode,
      itemBuilder: recurrenceModeLabel,
      onSelected: (value) => pickedMode = value,
    );
    if (pickedMode == null || !context.mounted) return null;
    mode = pickedMode!;
  }

  final minute = await _showRecurrenceTimeDialog(
    context: context,
    currentMinuteOfDay: currentMinuteOfDay,
    use24h: use24h,
  );
  if (!context.mounted) return null;
  if (minute == _cancelledMinute) return null;

  return RecurrenceSelection(
    frequency: frequency,
    weekdays: weekdays,
    mode: mode,
    minuteOfDay: minute,
  );
}

Future<List<int>?> _showWeeklyRecurrenceDialog({
  required BuildContext context,
  required List<int> initial,
}) async {
  return NavigationHelper.showAppDialog<List<int>>(
    context: context,
    child: _WeeklyRecurrenceDialog(initial: initial),
  );
}

/// Returns minutes, null for none, or [_cancelledMinute] if dismissed.
Future<int?> _showRecurrenceTimeDialog({
  required BuildContext context,
  required int? currentMinuteOfDay,
  required bool use24h,
}) async {
  final result = await NavigationHelper.showAppDialog<Object>(
    context: context,
    child: _RecurrenceTimeDialog(
      currentMinuteOfDay: currentMinuteOfDay,
      use24h: use24h,
    ),
  );
  if (result == null) return _cancelledMinute;
  if (result == _RecurrenceTimeDialog.none) return null;
  if (result is int) return result;
  return _cancelledMinute;
}

class _RecurrenceTimeDialog extends StatelessWidget {
  const _RecurrenceTimeDialog({
    required this.currentMinuteOfDay,
    required this.use24h,
  });

  static const none = Object();

  final int? currentMinuteOfDay;
  final bool use24h;

  @override
  Widget build(BuildContext context) {
    return SettingsListDialogShell(
      header: SettingsListDialogHeader(
        title: 'recurrenceTime'.tr,
        icon: IconsaxPlusBold.clock,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingM,
              0,
              AppConstants.spacingM,
              AppConstants.spacingS,
            ),
            child: Text(
              'recurrenceTimeHint'.tr,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SettingsDialogListTile(
            title: 'recurrenceTimeNone'.tr,
            isSelected: currentMinuteOfDay == null,
            onTap: () => NavigationHelper.back(context, result: none),
          ),
          SettingsDialogListTile(
            title: currentMinuteOfDay == null
                ? 'recurrenceTimePick'.tr
                : '${'recurrenceTimePick'.tr} · ${formatRecurrenceMinuteOfDay(currentMinuteOfDay, use24h: use24h)}',
            isSelected: currentMinuteOfDay != null,
            onTap: () async {
              final initial = currentMinuteOfDay != null
                  ? TimeOfDay(
                      hour: currentMinuteOfDay! ~/ 60,
                      minute: currentMinuteOfDay! % 60,
                    )
                  : TimeOfDay.now();
              final time = await showTimePicker(
                context: context,
                initialTime: initial,
                builder: (context, child) {
                  return MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(alwaysUse24HourFormat: use24h),
                    child: child!,
                  );
                },
              );
              if (!context.mounted) return;
              if (time == null) {
                // Keep previous choice instead of aborting the whole picker.
                NavigationHelper.back(
                  context,
                  result: currentMinuteOfDay ?? none,
                );
                return;
              }
              NavigationHelper.back(
                context,
                result: time.hour * 60 + time.minute,
              );
            },
          ),
        ],
      ),
      footer: const SettingsListDialogDismissAction(labelKey: 'cancel'),
    );
  }
}

class _WeeklyRecurrenceDialog extends StatefulWidget {
  const _WeeklyRecurrenceDialog({required this.initial});

  final List<int> initial;

  @override
  State<_WeeklyRecurrenceDialog> createState() =>
      _WeeklyRecurrenceDialogState();
}

class _WeeklyRecurrenceDialogState extends State<_WeeklyRecurrenceDialog> {
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial.toSet();
  }

  void _toggle(int weekday) {
    setState(() {
      if (_selected.contains(weekday)) {
        if (_selected.length > 1) _selected.remove(weekday);
      } else {
        _selected.add(weekday);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsListDialogShell(
      header: SettingsListDialogHeader(
        title: 'recurrenceWeekdays'.tr,
        icon: IconsaxPlusBold.calendar_1,
      ),
      body: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
        itemCount: kWeekdayI18nKeys.length,
        itemBuilder: (context, index) {
          final weekday = index + 1;
          return SettingsDialogListTile(
            title: kWeekdayI18nKeys[index].tr,
            isSelected: _selected.contains(weekday),
            onTap: () => _toggle(weekday),
          );
        },
      ),
      footer: SettingsListDialogActionsFooter(
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
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingS),
            SettingsListDialogTonalButton(
              labelKey: 'save',
              onPressed: () => NavigationHelper.back(
                context,
                result: _selected.toList()..sort(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tonal chip matching DateTime / Priority attribute buttons.
class RecurrenceChipButton extends StatelessWidget {
  /// Creates a recurrence chip for [frequency].
  const RecurrenceChipButton({
    super.key,
    required this.frequency,
    required this.onPressed,
    this.minuteOfDay,
    this.use24h = true,
  });

  /// Current frequency.
  final RecurrenceFrequency frequency;

  /// Optional fixed reminder minutes from midnight.
  final int? minuteOfDay;

  /// Whether to format [minuteOfDay] in 24-hour style.
  final bool use24h;

  /// Opens the picker.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final active = RecurrenceService.isRecurring(frequency);
    final fg = active
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSecondaryContainer;

    return FilledButton.tonal(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingL,
          vertical: AppConstants.spacingS,
        ),
        minimumSize: const Size(0, 36),
        backgroundColor: active
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.repeat,
            size: AppConstants.iconSizeSmall,
            color: fg,
          ),
          SizedBox(width: AppConstants.spacingS),
          Text(
            recurrenceChipLabel(
              frequency,
              minuteOfDay: minuteOfDay,
              use24h: use24h,
            ),
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
