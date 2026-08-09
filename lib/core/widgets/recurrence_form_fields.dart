import 'package:flutter/foundation.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/widgets/recurrence_picker.dart';

/// Dirty-tracking notifiers for recurrence picker fields shared by forms.
class RecurrenceFormFields {
  /// Seeds notifiers from the current (initial) recurrence values.
  RecurrenceFormFields({
    required RecurrenceFrequency frequency,
    required List<int> weekdays,
    required RecurrenceMode mode,
    required int? minuteOfDay,
  }) : _initialFrequency = frequency,
       _initialWeekdays = List<int>.from(weekdays),
       _initialMode = mode,
       _initialMinuteOfDay = minuteOfDay {
    this.frequency.value = frequency;
    this.weekdays.value = List<int>.from(weekdays);
    this.mode.value = mode;
    this.minuteOfDay.value = minuteOfDay;
  }

  final RecurrenceFrequency _initialFrequency;
  final List<int> _initialWeekdays;
  final RecurrenceMode _initialMode;
  final int? _initialMinuteOfDay;

  /// Selected recurrence frequency.
  final frequency = ValueNotifier<RecurrenceFrequency>(
    RecurrenceFrequency.none,
  );

  /// Weekdays 1–7 for weekly rules.
  final weekdays = ValueNotifier<List<int>>([]);

  /// Clone vs reopen behavior.
  final mode = ValueNotifier<RecurrenceMode>(RecurrenceMode.clone);

  /// Reminder minutes from midnight; null = no fixed time.
  final minuteOfDay = ValueNotifier<int?>(null);

  /// Listenables to register with [FormDirtyTracker].
  List<Listenable> get listenables => [frequency, weekdays, mode, minuteOfDay];

  /// Whether any recurrence field differs from the initial snapshot.
  bool get hasChanges =>
      frequency.value != _initialFrequency ||
      !listEquals(weekdays.value, _initialWeekdays) ||
      mode.value != _initialMode ||
      minuteOfDay.value != _initialMinuteOfDay;

  /// Copies a picker [selection] into the notifiers.
  void apply(RecurrenceSelection selection) {
    frequency.value = selection.frequency;
    weekdays.value = List<int>.from(selection.weekdays);
    mode.value = selection.mode;
    minuteOfDay.value = selection.minuteOfDay;
  }

  /// Releases notifiers.
  void dispose() {
    frequency.dispose();
    weekdays.dispose();
    mode.dispose();
    minuteOfDay.dispose();
  }
}
