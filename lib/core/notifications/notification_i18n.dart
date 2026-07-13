import 'package:zest/i18n/tr.dart';

/// Localized label for the snooze notification action button.
String snoozeActionLabel(int minutes) =>
    'snoozeActionLabel'.trFormat({'minutes': minutes});
