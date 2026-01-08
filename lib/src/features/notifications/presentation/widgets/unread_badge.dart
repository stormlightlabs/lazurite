import 'package:flutter/material.dart';

/// Badge widget for displaying unread notification count.
///
/// Displays a numeric badge on the notifications tab icon. The badge
/// automatically hides when count is zero and formats large counts as "99+".
///
/// Features:
/// - Shows count for values > 0
/// - Formats counts > 99 as "99+"
/// - Hides badge when count is 0
/// - Semantic label for screen readers
/// - Adapts to Material Design theme
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({required this.count, required this.child, super.key});

  /// The unread notification count to display.
  ///
  /// When 0, the badge is hidden. When > 99, displays as "99+".
  final int count;

  /// The child widget to display the badge on (typically an Icon).
  final Widget child;

  /// Maximum count to display before showing "99+".
  static const int _maxDisplayCount = 99;

  @override
  Widget build(BuildContext context) {
    final isVisible = count > 0;
    final displayText = count > _maxDisplayCount ? '99+' : '$count';

    return Badge(
      label: Text(displayText),
      isLabelVisible: isVisible,
      child: Semantics(
        label: isVisible ? '$count unread notifications' : null,
        excludeSemantics: !isVisible,
        child: child,
      ),
    );
  }
}
