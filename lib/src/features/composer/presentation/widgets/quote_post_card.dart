import 'package:flutter/material.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';

/// Displays a quoted post preview in the composer.
///
/// Shows the quoted post author, text, and media indicator in a bordered card.
/// Mirrors the styling from feed quoted post embeds.
class QuotePostCard extends StatelessWidget {
  const QuotePostCard({required this.author, required this.text, this.imageCount = 0, super.key});

  /// The author of the quoted post.
  final Author author;

  /// The text content of the quoted post.
  final String text;

  /// Number of images attached to the quoted post.
  final int imageCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Avatar(imageUrl: author.avatar, radius: 12),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
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
              ),
            ],
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodyMedium,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (imageCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.image, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '$imageCount image${imageCount > 1 ? 's' : ''}',
                  style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
