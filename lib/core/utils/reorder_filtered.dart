/// Splices [filtered] order into matching slots of [all], then assigns indexes.
///
/// Used by category and item list reordering so filtered views keep relative
/// positions of non-filtered rows.
void reorderFilteredInPlace<T>({
  required List<T> all,
  required List<T> filtered,
  required int Function(T item) idOf,
  required void Function(T item, int index) assignIndex,
}) {
  if (filtered.isEmpty) return;

  final filteredIds = filtered.map(idOf).toSet();
  var position = 0;

  for (var i = 0; i < all.length && position < filtered.length; i++) {
    if (filteredIds.contains(idOf(all[i]))) {
      all[i] = filtered[position++];
    }
  }

  for (var i = 0; i < all.length; i++) {
    assignIndex(all[i], i);
  }
}
