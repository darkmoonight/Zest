import 'package:zest/i18n/tr.dart';

/// Stable CalDAV error codes persisted in [Settings.caldavLastError].
///
/// Raw exception strings must never be stored or shown — they can include
/// URLs, hostnames, or auth-related details.
abstract final class CalDavErrorCodes {
  /// Authentication failed (401 / credentials).
  static const auth = 'caldavErrorAuth';

  /// Network / TLS / unreachable host.
  static const network = 'caldavErrorNetwork';

  /// Calendar or resource missing.
  static const notFound = 'caldavErrorNotFound';

  /// Prefix for conflict messages: `caldavErrorConflict:<count>`.
  static const conflictPrefix = 'caldavErrorConflict:';

  /// Fallback when the cause is unknown.
  static const generic = 'caldavErrorGeneric';
}

/// Maps exceptions to [CalDavErrorCodes] and formats them for the UI.
abstract final class CalDavError {
  /// Returns a stable code for [error] (never the raw exception text).
  static String codeFor(Object error) {
    final msg = error.toString().toLowerCase();
    if (_matches(msg, const [
      '401',
      'unauthorized',
      'authentication',
      'not authorised',
      'not authorized',
      'forbidden',
      '403',
      'invalid credentials',
    ])) {
      return CalDavErrorCodes.auth;
    }
    if (_matches(msg, const [
      '404',
      'not found',
      'no longer available',
      'missing calendar',
    ])) {
      return CalDavErrorCodes.notFound;
    }
    if (_matches(msg, const [
      'socket',
      'connection',
      'network',
      'timed out',
      'timeout',
      'handshake',
      'certificate',
      'ssl',
      'tls',
      'failed host lookup',
      'connection refused',
      'cleartext',
    ])) {
      return CalDavErrorCodes.network;
    }
    return CalDavErrorCodes.generic;
  }

  /// Code stored when the server wins [count] conflicts.
  static String conflictCode(int count) =>
      '${CalDavErrorCodes.conflictPrefix}$count';

  /// User-facing text for a stored [caldavLastError] or sync result error.
  static String displayMessage(String? stored) {
    if (stored == null || stored.isEmpty) return '';
    if (stored.startsWith(CalDavErrorCodes.conflictPrefix)) {
      final count = stored.substring(CalDavErrorCodes.conflictPrefix.length);
      return 'caldavConflictServerWins'.trFormat({'count': count});
    }
    if (_isKnownCode(stored)) {
      return 'caldavSyncFailed'.trFormat({'error': stored.tr});
    }
    // Legacy raw exception text from older builds.
    return 'caldavSyncFailed'.trFormat({'error': CalDavErrorCodes.generic.tr});
  }

  /// Connection-failure snackbar text (no raw [error] leak).
  static String connectionFailedMessage(Object error) {
    final code = codeFor(error);
    return 'caldavConnectionFailed'.trFormat({'error': code.tr});
  }

  static bool _isKnownCode(String value) =>
      value == CalDavErrorCodes.auth ||
      value == CalDavErrorCodes.network ||
      value == CalDavErrorCodes.notFound ||
      value == CalDavErrorCodes.generic;

  static bool _matches(String msg, List<String> needles) {
    for (final needle in needles) {
      if (msg.contains(needle)) return true;
    }
    return false;
  }
}
