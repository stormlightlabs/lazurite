import 'package:flutter/material.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';

/// Shared post card widget used across profile feeds and search results.
///
/// This widget displays a feed item with author info, post text, and action counts.
/// It can be used in profile tabs (Posts/Replies/Media) and search results.
class FeedPostCard extends StatelessWidget {
  const FeedPostCard({
    required this.uri,
    required this.authorDid,
    required this.authorHandle,
    required this.text,
    this.authorDisplayName,
    this.authorAvatar,
    this.indexedAt,
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
    this.onTap,
    this.onAvatarTap,
    this.showDivider = true,
    super.key,
  });

  final String uri;
  final String authorDid;
  final String authorHandle;
  final String? authorDisplayName;
  final String? authorAvatar;
  final String text;
  final DateTime? indexedAt;
  final int replyCount;
  final int repostCount;
  final int likeCount;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
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
        if (showDivider) const Divider(height: 1),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        InkWell(
          onTap: onAvatarTap,
          child: Avatar(imageUrl: authorAvatar, radius: 20),
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
                      authorDisplayName ?? authorHandle,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (indexedAt != null)
                    Text(
                      '• ${DateFormatter.formatRelative(indexedAt!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              Text(
                '@$authorHandle',
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
      text,
      style: theme.textTheme.bodyMedium,
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        _ActionItem(icon: Icons.chat_bubble_outline, count: replyCount),
        const SizedBox(width: 24),
        _ActionItem(icon: Icons.repeat, count: repostCount),
        const SizedBox(width: 24),
        _ActionItem(icon: Icons.favorite_outline, count: likeCount),
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
