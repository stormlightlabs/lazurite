import 'package:flutter/material.dart';
import 'package:lazurite/src/features/composer/domain/link_metadata.dart';

/// Displays a preview card for a link with metadata.
///
/// Shows title, description, image, and site name extracted from URL metadata.
class LinkCardPreview extends StatelessWidget {
  const LinkCardPreview({required this.metadata, this.onRemove, super.key});

  /// Metadata to display.
  final LinkMetadata metadata;

  /// Callback fired when user taps remove button.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (metadata.imageUrl != null)
              SizedBox(
                width: 120,
                child: Image.network(
                  metadata.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                    );
                  },
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (metadata.siteName != null)
                      Text(
                        metadata.siteName!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (metadata.title != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        metadata.title!,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (metadata.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        metadata.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onRemove,
                tooltip: 'Remove link preview',
              ),
          ],
        ),
      ),
    );
  }
}
