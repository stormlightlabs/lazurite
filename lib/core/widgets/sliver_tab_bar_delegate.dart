import 'dart:ui';
import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:flutter/material.dart';

/// A [SliverPersistentHeaderDelegate] that pins a [TabBar] with a frosted-glass
/// background. Extracted so it can be shared across multiple screens.
class SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colorScheme = context.colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: ColoredBox(color: colorScheme.surface.withValues(alpha: 0.85), child: tabBar),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverTabBarDelegate oldDelegate) => oldDelegate.tabBar != tabBar;
}
