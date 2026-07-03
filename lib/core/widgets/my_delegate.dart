import 'package:flutter/material.dart';

/// Sliver persistent header delegate with a fixed height and custom child.
class MyDelegate extends SliverPersistentHeaderDelegate {
  /// The widget displayed inside the header.
  final Widget child;

  /// The fixed height of the header.
  final double height;

  /// Creates a sliver header delegate with the given [child] and [height].
  MyDelegate({required this.child, this.height = 48.0});

  @override
  /// Builds the header container with scaffold background color.
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  /// Maximum extent equals [height].
  double get maxExtent => height;

  @override
  /// Minimum extent equals [height].
  double get minExtent => height;

  @override
  /// Rebuilds when [child] or [height] changes.
  bool shouldRebuild(covariant MyDelegate oldDelegate) =>
      child != oldDelegate.child || height != oldDelegate.height;
}
