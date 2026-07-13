import 'package:flutter_test/flutter_test.dart';
import 'package:zest/core/notifications/notification_i18n.dart';
import 'package:zest/i18n/strings.g.dart';

void main() {
  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.enUs);
  });

  test('snoozeActionLabel substitutes minutes', () {
    expect(snoozeActionLabel(15), 'Snooze 15 min');
    expect(snoozeActionLabel(45), 'Snooze 45 min');
  });
}
