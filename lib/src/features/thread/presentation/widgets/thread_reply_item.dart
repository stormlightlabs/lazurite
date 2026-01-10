import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/widgets/feed_post_card.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
import 'package:lazurite/src/features/thread/domain/thread_layout_calculator.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/post/post_header.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/blocked_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/collapse_toggle.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/deep_thread_indicator.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/not_found_post_card.dart';

/// A recursive reply item widget that renders nested thread replies.
///
/// Handles indentation based on depth, collapse/expand state, and renders
/// child replies recursively.
class ThreadReplyItem extends ConsumerWidget {
  const ThreadReplyItem({
    required this.post,
    required this.depth,
    required this.isCollapsed,
    required this.onToggleCollapse,
    super.key,
  });

  /// The thread post to render
  final ThreadViewPost post;

  /// Current nesting depth (1-based for replies)
  final int depth;

  /// Whether this post's replies are collapsed
  final bool isCollapsed;

  /// Callback when collapse toggle is tapped
  final VoidCallback onToggleCollapse;

  static const _collapseAnimationDuration = Duration(milliseconds: 250);
  static const _collapsedMaxChars = 140;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indent = ThreadLayoutCalculator.calculateIndent(depth);
    final shouldFlatten = ThreadLayoutCalculator.shouldFlattenDepth(depth);
    final hasReplies = post.replies.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (shouldFlatten && depth > 0)
          Padding(
            padding: EdgeInsets.only(left: indent),
            child: DeepThreadIndicator(
              parentHandle: post.parent != null ? post.parent!.post.author.handle : '',
            ),
          ),

        Padding(
          padding: EdgeInsets.only(left: indent),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasReplies)
                CollapseToggle(isCollapsed: isCollapsed, onTap: onToggleCollapse)
              else
                const SizedBox(width: 32),
              Expanded(
                child: AnimatedSwitcher(
                  duration: _collapseAnimationDuration,
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: -1,
                        child: child,
                      ),
                    );
                  },
                  child: isCollapsed
                      ? _CollapsedPostSummary(
                          key: const ValueKey('collapsed_summary'),
                          post: post,
                          maxCharacters: _collapsedMaxChars,
                        )
                      : KeyedSubtree(
                          key: const ValueKey('expanded_post'),
                          child: _buildPostCard(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard() {
    if (post.isBlocked) {
      return const BlockedPostCard();
    }

    if (post.isNotFound) {
      return const NotFoundPostCard();
    }

    return FeedPostCard(
      item: post.post.toFeedPost(),
      margin: const EdgeInsets.symmetric(vertical: 8),
    );
  }
}

class _CollapsedPostSummary extends StatelessWidget {
  const _CollapsedPostSummary({required this.post, required this.maxCharacters, super.key});

  final ThreadViewPost post;
  final int maxCharacters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final extractedText = _extractText();
    final previewText = extractedText.isEmpty ? 'No preview available' : extractedText;
    final repliesLabel = post.replies.isEmpty ? null : _formatReplies(post.replies.length);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostHeader(author: post.post.toProfileModel(), indexedAt: post.post.indexedAt),
          const SizedBox(height: 8),
          Text(
            previewText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
          if (repliesLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              repliesLabel,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _extractText() {
    final raw = post.post.record['text'];
    if (raw is! String) return '';
    final trimmed = raw.trim();
    if (trimmed.length <= maxCharacters) return trimmed;
    return '${trimmed.substring(0, maxCharacters)}…';
  }

  String _formatReplies(int count) {
    final noun = count == 1 ? 'reply hidden' : 'replies hidden';
    return '$count $noun';
  }
}
