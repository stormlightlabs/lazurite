import 'package:flutter/material.dart';

/// A placeholder card displayed when a post is from a blocked account.
///
/// Privacy-preserving - does not reveal any author information.
class BlockedPostCard extends StatelessWidget {
  const BlockedPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Blocked post',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: colorScheme.outlineVariant, shape: BoxShape.circle),
              child: Icon(Icons.block, color: colorScheme.onSurfaceVariant, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This post is from an account you\'ve blocked',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
