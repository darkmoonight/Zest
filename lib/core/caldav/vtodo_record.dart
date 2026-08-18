/// Portable VTODO fields used by the mapper and CalDAV remote.
class VtodoRecord {
  /// Creates a VTODO snapshot.
  const VtodoRecord({
    required this.uid,
    this.href,
    this.etag,
    required this.summary,
    this.description = '',
    this.due,
    this.completed,
    this.priority = 0,
    this.status = 'NEEDS-ACTION',
    this.categories = const [],
    this.rawIcalendar,
  });

  /// iCalendar UID.
  final String uid;

  /// CalDAV resource href.
  final String? href;

  /// Entity tag for optimistic locking.
  final String? etag;

  /// Task title.
  final String summary;

  /// Task notes.
  final String description;

  /// Due date and time.
  final DateTime? due;

  /// Completion timestamp.
  final DateTime? completed;

  /// Priority on the RFC 5545 scale (0 = undefined).
  final int priority;

  /// VTODO status string.
  final String status;

  /// Category labels from CATEGORIES.
  final List<String> categories;

  /// Raw ICS for fields not exposed by the protocol model.
  final String? rawIcalendar;

  /// Returns a copy with selected fields replaced.
  VtodoRecord copyWith({
    String? uid,
    String? href,
    String? etag,
    String? summary,
    String? description,
    DateTime? due,
    DateTime? completed,
    int? priority,
    String? status,
    List<String>? categories,
    String? rawIcalendar,
  }) {
    return VtodoRecord(
      uid: uid ?? this.uid,
      href: href ?? this.href,
      etag: etag ?? this.etag,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      due: due ?? this.due,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      rawIcalendar: rawIcalendar ?? this.rawIcalendar,
    );
  }
}
