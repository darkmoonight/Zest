import 'package:flutter/material.dart';

class MyDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  MyDelegate({required this.child, this.height = 48.0});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => Container(child: child);

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant MyDelegate oldDelegate) =>
      child != oldDelegate.child || height != oldDelegate.height;
}
