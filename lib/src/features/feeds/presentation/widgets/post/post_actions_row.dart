import 'package:flutter/material.dart';
import 'package:lazurite/src/app/theme.dart';

class PostActionsRow extends StatelessWidget {
  const PostActionsRow({
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
    this.viewerLikeUri,
    this.viewerRepostUri,
    this.viewerBookmarked = false,
    super.key,
  });

  final int replyCount;
  final int repostCount;
  final int likeCount;

  /// URI if viewer has liked this post (non-null = liked).
  final String? viewerLikeUri;

  /// URI if viewer has reposted this post (non-null = reposted).
  final String? viewerRepostUri;

  /// Whether viewer has bookmarked this post.
  final bool viewerBookmarked;

  @override
  Widget build(BuildContext context) {
    final isLiked = viewerLikeUri != null;
    final isReposted = viewerRepostUri != null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionItem(icon: Icons.chat_bubble_outline, count: replyCount),
        _ActionItem(
          icon: Icons.repeat,
          count: repostCount,
          isActive: isReposted,
          activeColor: Colors.green,
        ),
        _ActionItem(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          count: likeCount,
          isActive: isLiked,
          activeColor: Colors.red,
        ),
        _ActionItem(
          icon: viewerBookmarked ? Icons.bookmark : Icons.bookmark_border,
          count: 0,
          isActive: viewerBookmarked,
          activeColor: Colors.amber,
        ),
        const Icon(Icons.more_horiz, size: 18, color: AppColors.textSecondary),
      ],
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.count,
    this.isActive = false,
    this.activeColor,
  });

  final IconData icon;
  final int count;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor ?? AppColors.textSecondary : AppColors.textSecondary;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Text(_formatCount(count), style: TextStyle(color: color, fontSize: 13)),
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
