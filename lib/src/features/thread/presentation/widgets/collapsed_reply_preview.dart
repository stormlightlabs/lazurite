import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';

/// Shows a preview of collapsed replies.
///
/// Displays the first reply's text (truncated) and total reply count,
/// similar to Reddit's collapsed thread preview.
class CollapsedReplyPreview extends StatelessWidget {
  const CollapsedReplyPreview({
    required this.firstReply,
    required this.totalCount,
    required this.onExpand,
    required this.indent,
    super.key,
  });

  /// First reply to show preview from
  final ThreadViewPost firstReply;

  /// Total number of all nested replies
  final int totalCount;

  /// Callback when preview is tapped to expand
  final VoidCallback onExpand;

  /// Left indent for alignment with parent
  final double indent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final previewText = _extractPreviewText(firstReply, maxLength: 100);
    final authorHandle = firstReply.post.author.handle;

    return InkWell(
      onTap: onExpand,
      child: Container(
        margin: EdgeInsets.only(left: indent + 24, right: 8, top: 4, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.unfold_more, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '@$authorHandle: $previewText',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text(
              _formatReplyCount(totalCount),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractPreviewText(ThreadViewPost post, {int maxLength = 100}) {
    if (post.isBlocked) return 'Blocked post';
    if (post.isNotFound) return 'Post not found';

    try {
      final record = jsonDecode(post.post.record['text'] as String? ?? '{}');
      if (record is String) {
        final text = record.trim();
        if (text.length <= maxLength) return text;
        return '${text.substring(0, maxLength)}...';
      }
    } catch (_) {
      /* Failed to parse, try direct text access */
    }

    final text = (post.post.record['text'] as String? ?? '').trim();
    if (text.isEmpty) return 'No preview available';

    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  String _formatReplyCount(int count) {
    if (count == 1) return '1 reply hidden';
    return '$count replies hidden';
  }
}
