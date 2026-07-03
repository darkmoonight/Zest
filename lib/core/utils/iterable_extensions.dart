/// Iterable helpers used across notifiers and services.
extension FirstWhereOrNull<E> on Iterable<E> {
  /// Returns the first element matching [test], or null if none match.
  E? firstWhereOrNull(bool Function(E) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
