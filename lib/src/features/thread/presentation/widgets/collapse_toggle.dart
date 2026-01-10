import 'package:flutter/material.dart';

/// A collapsible toggle button with triangle icon and reply count badge.
///
/// Displays a triangle icon that rotates 90 degrees when collapsed (pointing right)
/// vs expanded (pointing down). Shows a reply count badge when provided.
class CollapseToggle extends StatelessWidget {
  const CollapseToggle({
    required this.isCollapsed,
    required this.onTap,
    this.replyCount = 0,
    this.showCount = false,
    super.key,
  });

  /// Whether the associated thread is currently collapsed
  final bool isCollapsed;

  /// Callback when toggle is tapped
  final VoidCallback onTap;

  /// Number of replies (for badge display)
  final int replyCount;

  /// Whether to show the reply count badge
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              turns: isCollapsed ? -0.25 : 0, // -90° when collapsed, 0° when expanded
              duration: const Duration(milliseconds: 200),
              child: Icon(Icons.play_arrow, size: 16, color: colorScheme.onSurfaceVariant),
            ),
            if (showCount && replyCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  replyCount.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
