import 'package:flutter/material.dart';

/// Indicator shown when thread depth exceeds maximum nesting level.
///
/// Displays parent context (e.g., "Replying to @username") to maintain
/// conversation context when nesting is flattened.
class DeepThreadIndicator extends StatelessWidget {
  const DeepThreadIndicator({required this.parentHandle, super.key});

  /// Handle of the parent post author
  final String parentHandle;

  @override
  Widget build(BuildContext context) {
    if (parentHandle.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8, right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.subdirectory_arrow_right, size: 14, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            'Replying to @$parentHandle',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
