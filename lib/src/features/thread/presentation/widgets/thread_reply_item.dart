import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/widgets/feed_post_card.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
import 'package:lazurite/src/features/thread/domain/thread_layout_calculator.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/blocked_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/collapse_toggle.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/deep_thread_indicator.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/not_found_post_card.dart';
import 'package:lazurite/src/features/thread/presentation/widgets/thread_curved_connector.dart';

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
    this.isLastSibling = false,
    this.hasMoreSiblings = false,
    super.key,
  });

  /// The thread post to render
  final ThreadViewPost post;

  /// Current nesting depth (0-based)
  final int depth;

  /// Whether this post's replies are collapsed
  final bool isCollapsed;

  /// Callback when collapse toggle is tapped
  final VoidCallback onToggleCollapse;

  /// Whether this is the last sibling in its parent's reply list
  final bool isLastSibling;

  /// Whether there are more siblings after this one
  final bool hasMoreSiblings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indent = ThreadLayoutCalculator.calculateIndent(depth);
    final shouldFlatten = ThreadLayoutCalculator.shouldFlattenDepth(depth);
    final hasReplies = post.replies.isNotEmpty;
    final connectorStyle = _determineConnectorStyle(hasReplies, isLastSibling);

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

        Stack(
          children: [
            if (depth > 0)
              Positioned(
                left: ThreadLayoutCalculator.calculateConnectorLeft(depth - 1),
                top: 0,
                bottom: hasMoreSiblings ? 0 : null,
                height: hasMoreSiblings ? null : 60,
                child: ThreadCurvedConnector(style: connectorStyle, depth: depth),
              ),

            Padding(
              padding: EdgeInsets.only(left: indent),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasReplies)
                    CollapseToggle(
                      isCollapsed: isCollapsed,
                      onTap: onToggleCollapse,
                      replyCount: ThreadLayoutCalculator.countAllReplies(post),
                      showCount: isCollapsed,
                    )
                  else
                    const SizedBox(width: 24),
                  Expanded(child: _buildPostCard()),
                ],
              ),
            ),
          ],
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

    return FeedPostCard(item: post.post.toFeedPost());
  }

  ConnectorStyle _determineConnectorStyle(bool hasReplies, bool isLast) {
    if (hasReplies && !isCollapsed) {
      return ConnectorStyle.parentToChild;
    }
    if (isLast) {
      return ConnectorStyle.terminal;
    }
    return ConnectorStyle.continuation;
  }
}
