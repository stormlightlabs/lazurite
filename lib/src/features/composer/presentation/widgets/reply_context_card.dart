import 'package:flutter/material.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';

/// Displays the parent post context when replying to a post.
///
/// Shows a compact card with the parent post author and truncated text,
/// with a vertical thread indicator line connecting to the composer below.
class ReplyContextCard extends StatelessWidget {
  const ReplyContextCard({required this.author, required this.text, super.key});

  /// The author of the parent post being replied to.
  final Author author;

  /// The text content of the parent post.
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Avatar(imageUrl: author.avatar, radius: 16),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        if (author.displayName != null && author.displayName!.isNotEmpty)
                          TextSpan(
                            text: author.displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        TextSpan(
                          text: author.displayName != null && author.displayName!.isNotEmpty
                              ? ' @${author.handle}'
                              : '@${author.handle}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
