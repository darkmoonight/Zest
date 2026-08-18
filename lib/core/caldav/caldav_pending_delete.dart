import 'dart:convert';

/// A VTODO that was deleted locally and still needs a remote DELETE.
class CalDavPendingDelete {
  /// Creates a pending remote delete.
  const CalDavPendingDelete({required this.uid, required this.href, this.etag});

  /// iCalendar UID.
  final String uid;

  /// CalDAV resource href.
  final String href;

  /// ETag at delete time, if known.
  final String? etag;

  /// Decodes [Settings.caldavPendingDeletes] JSON.
  static List<CalDavPendingDelete> decode(String json) {
    try {
      final parsed = jsonDecode(json);
      if (parsed is! List) return const [];
      return [
        for (final item in parsed)
          if (item is Map)
            CalDavPendingDelete(
              uid: '${item['uid'] ?? ''}',
              href: '${item['href'] ?? ''}',
              etag: item['etag'] == null ? null : '${item['etag']}',
            ),
      ].where((item) => item.uid.isNotEmpty && item.href.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Encodes [items] for [Settings.caldavPendingDeletes].
  static String encode(List<CalDavPendingDelete> items) {
    return jsonEncode([
      for (final item in items)
        {
          'uid': item.uid,
          'href': item.href,
          if (item.etag != null) 'etag': item.etag,
        },
    ]);
  }
}
