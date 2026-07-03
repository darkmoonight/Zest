import 'package:intl/date_symbol_data_local.dart';

/// Loads intl date symbols for background isolates without MaterialApp.
class LocaleFormatHelper {
  /// Private constructor; use static methods only.
  LocaleFormatHelper._();

  /// Loads intl date symbols for [languageCode].
  static Future<void> ensureDateFormatting(String languageCode) async {
    await initializeDateFormatting(languageCode);
  }
}
