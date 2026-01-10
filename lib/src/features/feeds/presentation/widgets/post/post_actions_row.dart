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
    this.onReply,
    this.onRepost,
    this.onLike,
    this.onBookmark,
    this.onMore,
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

  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onLike;
  final VoidCallback? onBookmark;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final isLiked = viewerLikeUri != null;
    final isReposted = viewerRepostUri != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final showCounts = constraints.maxWidth > 240;
        final itemPadding = constraints.maxWidth > 200
            ? 8.0
            : constraints.maxWidth > 160
            ? 4.0
            : 2.0;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionItem(
              icon: Icons.chat_bubble_outline,
              count: showCounts ? replyCount : 0,
              onTap: onReply,
              tooltip: 'Reply',
              padding: itemPadding,
            ),
            _ActionItem(
              icon: Icons.repeat,
              count: showCounts ? repostCount : 0,
              isActive: isReposted,
              activeColor: Colors.green,
              onTap: onRepost,
              tooltip: isReposted ? 'Unrepost' : 'Repost',
              padding: itemPadding,
            ),
            _ActionItem(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              count: showCounts ? likeCount : 0,
              isActive: isLiked,
              activeColor: Colors.red,
              onTap: onLike,
              tooltip: isLiked ? 'Unlike' : 'Like',
              padding: itemPadding,
            ),
            _ActionItem(
              icon: viewerBookmarked ? Icons.bookmark : Icons.bookmark_border,
              count: 0,
              isActive: viewerBookmarked,
              activeColor: Colors.amber,
              onTap: onBookmark,
              tooltip: viewerBookmarked ? 'Remove Bookmark' : 'Bookmark',
              padding: itemPadding,
            ),
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'More',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        );
      },
    );
  }
}

class _ActionItem extends StatefulWidget {
  const _ActionItem({
    required this.icon,
    this.count = 0,
    this.isActive = false,
    this.activeColor,
    this.onTap,
    this.tooltip,
    this.padding = 8.0,
  });

  final IconData icon;
  final int count;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback? onTap;
  final String? tooltip;
  final double padding;

  @override
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;

    _controller.forward().then((_) => _controller.reverse());
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? widget.activeColor ?? AppColors.textSecondary
        : AppColors.textSecondary;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.padding, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Icon(widget.icon, size: 18, color: color),
              ),
              if (widget.count > 0) ...[
                const SizedBox(width: 4),
                ConstraintsTransformBox(
                  constraintsTransform: ConstraintsTransformBox.unconstrained,
                  child: Text(
                    _formatCount(widget.count),
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: widget.isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}
