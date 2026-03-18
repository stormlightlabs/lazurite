import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:share_plus/share_plus.dart';

class PostActionBar extends StatelessWidget {
  const PostActionBar({
    super.key,
    required this.replyCount,
    required this.repostCount,
    required this.likeCount,
    required this.saveCount,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
    required this.postUri,
    this.postCid,
    this.onReply,
    this.onRepost,
    this.onQuote,
    this.onLike,
    this.onShare,
    this.onSave,
    this.onLongPressSave,
    this.onMore,
    this.isLoadingLike = false,
    this.isLoadingRepost = false,
  });

  final int replyCount;
  final int repostCount;
  final int likeCount;
  final int saveCount;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;
  final String postUri;
  final String? postCid;
  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onQuote;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onLongPressSave;
  final VoidCallback? onMore;
  final bool isLoadingLike;
  final bool isLoadingRepost;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          count: replyCount,
          onTap: onReply,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        _ActionButton(
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          count: repostCount,
          isActive: isReposted,
          isLoading: isLoadingRepost,
          onTap: onRepost,
          activeColor: Colors.green,
          onLongPress: onRepost != null ? () => _showRepostOptions(context) : null,
        ),
        _ActionButton(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          count: likeCount,
          isActive: isLiked,
          isLoading: isLoadingLike,
          onTap: onLike,
          activeColor: Colors.pink,
        ),
        _ActionButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
          activeIcon: Icons.bookmark,
          count: saveCount,
          isActive: isSaved,
          onTap: onSave != null ? () => _showSaveOptions(context) : null,
          onLongPress: onLongPressSave,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          activeColor: Colors.amber,
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: 0,
          onTap: onShare ?? () => _defaultShare(context),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        if (onMore != null)
          _ActionButton(
            icon: Icons.more_vert,
            activeIcon: Icons.more_vert,
            count: 0,
            onTap: onMore,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }

  void _showRepostOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(isReposted ? Icons.repeat : Icons.repeat, color: isReposted ? Colors.green : null),
              title: Text(isReposted ? 'Unrepost' : 'Repost'),
              subtitle: Text(isReposted ? 'Remove this repost' : 'Share this post'),
              onTap: () {
                Navigator.pop(context);
                onRepost?.call();
              },
            ),
            if (!isReposted)
              ListTile(
                leading: const Icon(Icons.format_quote),
                title: const Text('Quote Post'),
                subtitle: const Text('Quote this post with your own text'),
                onTap: () {
                  Navigator.pop(context);
                  onQuote?.call();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSaveOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isSaved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                color: Colors.amber,
              ),
              title: Text(isSaved ? 'Remove local save' : 'Save locally'),
              onTap: () {
                Navigator.pop(context);
                onSave?.call();
              },
            ),
            ListTile(
              enabled: false,
              leading: Icon(
                Icons.cloud_outlined,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              title: const Text('Save to Bluesky'),
              subtitle: const Text('Coming soon'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _defaultShare(BuildContext context) async {
    final url = _convertAtUriToBskyUrl(postUri);
    await Share.share(url);
  }

  String _convertAtUriToBskyUrl(String atUri) {
    try {
      final uri = Uri.parse(atUri);
      final parts = uri.pathSegments;
      if (parts.length >= 2) {
        final did = uri.host;
        final rkey = parts.last;
        return 'https://bsky.app/profile/$did/post/$rkey';
      }
    } catch (_) {
      log.d('failed to convert atUri to bskyUrl');
    }
    return atUri;
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    this.isActive = false,
    this.isLoading = false,
    this.onTap,
    this.onLongPress,
    this.color,
    this.activeColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final int count;
  final bool isActive;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final iconColor = isActive ? (activeColor ?? defaultColor) : defaultColor;

    Widget button = InkWell(
      onTap: isLoading ? null : onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
            else
              Icon(isActive ? activeIcon : icon, size: 18, color: iconColor),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(_formatCount(count), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor)),
            ],
          ],
        ),
      ),
    );

    if (onTap != null && !isLoading) {
      button = GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedScale(scale: isActive ? 1.0 : 1.0, duration: const Duration(milliseconds: 100), child: button),
      );
    }

    return button;
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }
}
