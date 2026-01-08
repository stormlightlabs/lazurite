import 'package:flutter/material.dart';
import 'package:lazurite/src/core/constants/layout_constants.dart';

/// A common wrapper for pull-to-refresh functionality.
///
/// Wraps a scrollable child with a [RefreshIndicator] and handles the refresh callback.
class PullToRefreshWrapper extends StatelessWidget {
  const PullToRefreshWrapper({
    required this.onRefresh,
    required this.child,
    this.color,
    super.key,
  });

  /// Callback triggered when the user pulls to refresh.
  final Future<void> Function() onRefresh;

  /// The scrollable child widget.
  final Widget child;

  /// Optional color for the refresh indicator.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? Theme.of(context).colorScheme.primary,
      edgeOffset: kRefreshIndicatorEdgeOffset,
      displacement: kRefreshIndicatorDisplacement,
      child: child,
    );
  }
}
