import 'package:zest/core/caldav/caldav_client.dart';
import 'package:zest/core/caldav/caldav_remote.dart';
import 'package:zest/data/models/db.dart';

/// CalDAV sign-in fields used by settings and discovery.
class CalDavAccount {
  /// Creates account credentials.
  const CalDavAccount({
    required this.url,
    required this.username,
    required this.password,
    this.allowInsecure = false,
  });

  /// Server base URL.
  final String url;

  /// Account username.
  final String username;

  /// Account password (secure storage or form input).
  final String password;

  /// Whether plain HTTP is allowed.
  final bool allowInsecure;

  /// Whether all fields required for a connection attempt are non-empty.
  bool get isComplete =>
      url.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.isNotEmpty;

  /// Opens a CalDAV session with trimmed URL and username.
  Future<CalDavRemote> connect() {
    return connectCalDavRemote(
      url: url.trim(),
      username: username.trim(),
      password: password,
      allowInsecure: allowInsecure,
    );
  }
}

/// CalDAV-related [Settings] fields shared by sync and the settings UI.
extension CalDavSettings on Settings {
  /// Whether URL and username are set (password is checked separately).
  bool get hasCalDavAccount =>
      (caldavUrl?.trim().isNotEmpty ?? false) &&
      (caldavUsername?.trim().isNotEmpty ?? false);

  /// Whether sync can run: account fields and a calendar href are set.
  bool get hasCalDavSyncTarget =>
      hasCalDavAccount && (caldavCalendarHref?.trim().isNotEmpty ?? false);

  /// Sets the selected calendar and clears the cached collection tag.
  void setCalDavCalendar(CalDavCalendarInfo? calendar) {
    caldavCalendarHref = calendar?.href;
    caldavCalendarName = calendar?.displayName;
    caldavCtag = null;
  }
}

/// Connects with [account], lists VTODO calendars, and closes the session.
Future<List<CalDavCalendarInfo>> discoverCalDavTodoCalendars(
  CalDavAccount account,
) async {
  final remote = await account.connect();
  try {
    return await remote.listTodoCalendars();
  } finally {
    remote.close();
  }
}

/// Returns the calendar matching [href], or the first entry when unknown.
CalDavCalendarInfo selectCalDavCalendar(
  List<CalDavCalendarInfo> calendars,
  String? href,
) {
  for (final calendar in calendars) {
    if (calendar.href == href) return calendar;
  }
  return calendars.first;
}
