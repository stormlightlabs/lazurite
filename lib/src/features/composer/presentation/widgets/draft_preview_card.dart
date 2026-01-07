import 'package:flutter/material.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';
import 'package:lazurite/src/features/composer/presentation/widgets/draft_status_chip.dart';

class DraftPreviewCard extends StatelessWidget {
  const DraftPreviewCard({required this.draft, required this.onTap, this.onRetry, super.key});

  final Draft draft;
  final VoidCallback onTap;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final mediaCount = draft.media.length;
    final hasReply = draft.replyParentUri != null;
    final hasQuote = draft.quoteUri != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (draft.text.isNotEmpty)
                          Text(
                            draft.text,
                            style: textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        else
                          Text(
                            'Untitled Draft',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            DraftStatusChip(status: draft.status),
                            const Spacer(),
                            Text(
                              DateFormatter.formatRelative(draft.updatedAt),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (mediaCount > 0) ...[
                    const SizedBox(width: 12),
                    _MediaBadge(count: mediaCount),
                  ],
                ],
              ),
              if (hasReply || hasQuote || draft.errorMessage != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (hasReply)
                      _IconBadge(icon: Icons.reply, label: 'Reply', color: colorScheme.primary),
                    if (hasQuote) ...[
                      if (hasReply) const SizedBox(width: 8),
                      _IconBadge(
                        icon: Icons.format_quote,
                        label: 'Quote',
                        color: colorScheme.secondary,
                      ),
                    ],
                    if (draft.errorMessage != null) ...[
                      if (hasReply || hasQuote) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          draft.errorMessage!,
                          style: textTheme.labelSmall?.copyWith(color: colorScheme.error),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (draft.status == DraftStatus.failed && onRetry != null) ...[
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 32),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaBadge extends StatelessWidget {
  const _MediaBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.image, color: colorScheme.onSurfaceVariant),
          if (count > 1)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
      ],
    );
  }
}
