import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Formats a post timestamp as a short, uppercase string.
String formatPostTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);

  if (difference.inMinutes < 1) return 'NOW';
  if (difference.inHours < 1) return '${difference.inMinutes}M';
  if (difference.inDays < 1) return '${difference.inHours}H';
  if (difference.inDays < 7) return '${difference.inDays}D';
  return DateFormat('MMM d').format(time).toUpperCase();
}

/// Shared footer for post cards. Renders a top-bordered row with
/// action icons (reply, repost, like, save) on the left and a timestamp on the right.
class PostCardFooter extends StatelessWidget {
  const PostCardFooter({
    super.key,
    required this.timestamp,
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
    this.saveCount = 0,
    this.isLiked = false,
    this.isReposted = false,
    this.isSaved = false,
    this.saveType,
    this.isLoadingLike = false,
    this.isLoadingRepost = false,
    this.onReply,
    this.onRepost,
    this.onLike,
    this.onSave,
    this.onLongPressSave,
    this.onCloudSave,
    this.onCloudUnsave,
  });

  final String timestamp;
  final int replyCount;
  final int repostCount;
  final int likeCount;
  final int saveCount;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;
  final String? saveType;
  final bool isLoadingLike;
  final bool isLoadingRepost;
  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onLongPressSave;
  final VoidCallback? onCloudSave;
  final VoidCallback? onCloudUnsave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final saveActiveColor = (saveType == 'cloud' || saveType == 'both') ? colorScheme.primary : Colors.amber;
    const horizontalPadding = 12.0;
    const actionSpacing = 8.0;
    const iconSize = 18.0;
    const actionPadding = 4.0;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
      child: Row(
        children: [
          _FooterAction(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            isActive: false,
            isLoading: false,
            onTap: onReply,
            color: colorScheme.onSurfaceVariant,
            iconSize: iconSize,
            padding: actionPadding,
          ),
          const SizedBox(width: actionSpacing),
          _FooterAction(
            icon: Icons.repeat,
            activeIcon: Icons.repeat,
            isActive: isReposted,
            isLoading: isLoadingRepost,
            onTap: onRepost,
            color: colorScheme.onSurfaceVariant,
            activeColor: Colors.green,
            iconSize: iconSize,
            padding: actionPadding,
          ),
          const SizedBox(width: actionSpacing),
          _FooterAction(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            isActive: isLiked,
            isLoading: isLoadingLike,
            onTap: onLike,
            color: colorScheme.onSurfaceVariant,
            activeColor: Colors.pink,
            iconSize: iconSize,
            padding: actionPadding,
          ),
          const SizedBox(width: actionSpacing),
          _FooterAction(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
            activeIcon: Icons.bookmark,
            isActive: isSaved,
            isLoading: false,
            onTap: onSave != null ? () => _showSaveOptions(context) : null,
            onLongPress: onLongPressSave,
            color: colorScheme.onSurfaceVariant,
            activeColor: saveActiveColor,
            iconSize: iconSize,
            padding: actionPadding,
          ),
          const SizedBox(width: actionSpacing),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                timestamp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10, letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSaveOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    final isLocalSaved = isSaved && (saveType == 'local' || saveType == 'both');
    final isCloudSaved = saveType == 'cloud' || saveType == 'both';

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isLocalSaved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
                color: Colors.amber,
              ),
              title: Text(isLocalSaved ? 'Remove local save' : 'Save locally'),
              onTap: () {
                Navigator.pop(context);
                onSave?.call();
              },
            ),
            ListTile(
              leading: Icon(
                isCloudSaved ? Icons.cloud_off_outlined : Icons.cloud_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(isCloudSaved ? 'Remove from Bluesky' : 'Save to Bluesky'),
              onTap: () {
                Navigator.pop(context);
                if (isCloudSaved) {
                  onCloudUnsave?.call();
                } else {
                  onCloudSave?.call();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.isLoading,
    required this.iconSize,
    required this.padding,
    this.onTap,
    this.onLongPress,
    this.color,
    this.activeColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final bool isLoading;
  final double iconSize;
  final double padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final iconColor = isActive ? (activeColor ?? defaultColor) : defaultColor;

    return InkWell(
      onTap: isLoading ? null : onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: isLoading
            ? SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(strokeWidth: 2, color: iconColor),
              )
            : Icon(isActive ? activeIcon : icon, size: iconSize, color: iconColor),
      ),
    );
  }
}
