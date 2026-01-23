import 'package:flutter/material.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';

/// Shared post card widget used across profile feeds and search results.
///
/// This widget displays a feed item with author info, post text, and action counts.
/// It can be used in profile tabs (Posts/Replies/Media) and search results.
class FeedPostCard extends StatelessWidget {
  const FeedPostCard({required this.post, this.onTap, this.onAvatarTap, super.key});

  final Post post;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 8),
              _buildBody(theme),
              const SizedBox(height: 8),
              _buildActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        InkWell(
          onTap: onAvatarTap,
          child: Avatar(imageUrl: post.author.avatar, radius: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.author.displayName ?? post.author.handle,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (post.indexedAt != null)
                    Text(
                      '• ${DateFormatter.formatRelative(post.indexedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              Text(
                '@${post.author.handle}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Text(
      post.text,
      style: theme.textTheme.bodyMedium,
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        _ActionItem(icon: Icons.chat_bubble_outline, count: post.replyCount),
        const SizedBox(width: 24),
        _ActionItem(icon: Icons.repeat, count: post.repostCount),
        const SizedBox(width: 24),
        _ActionItem(icon: Icons.favorite_outline, count: post.likeCount),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({required this.icon, required this.count});

  final IconData icon;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withAlpha(153)),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(
            _formatCount(count),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ],
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}
