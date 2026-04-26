import 'package:flutter/material.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/shared/presentation/helpers/haptic_helper.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

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
    this.saveType,
    required this.postUri,
    this.postCid,
    this.onReply,
    this.onRepost,
    this.onQuote,
    this.onLike,
    this.onShare,
    this.onSave,
    this.onLongPressSave,
    this.onCloudSave,
    this.onCloudUnsave,
    this.onMore,
    this.isLoadingLike = false,
    this.isLoadingRepost = false,
    this.isOffline = false,
  });

  final int replyCount;
  final int repostCount;
  final int likeCount;
  final int saveCount;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;
  final String? saveType;
  final String postUri;
  final String? postCid;
  final VoidCallback? onReply;
  final VoidCallback? onRepost;
  final VoidCallback? onQuote;
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onLongPressSave;
  final VoidCallback? onCloudSave;
  final VoidCallback? onCloudUnsave;
  final VoidCallback? onMore;
  final bool isLoadingLike;
  final bool isLoadingRepost;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionButton(
          icon: Icons.chat_bubble_outline,
          activeIcon: Icons.chat_bubble,
          count: replyCount,
          onTap: isOffline ? null : onReply,
          tooltip: isOffline ? offlineActionMessage('reply to this post') : null,
          color: context.colorScheme.onSurfaceVariant,
        ),
        _ActionButton(
          icon: Icons.repeat,
          activeIcon: Icons.repeat,
          count: repostCount,
          isActive: isReposted,
          isLoading: isLoadingRepost,
          onTap: isOffline ? null : onRepost,
          activeColor: Colors.green,
          onLongPress: !isOffline && onRepost != null ? () => _showRepostOptions(context) : null,
          tooltip: isOffline ? offlineActionMessage('repost this post') : null,
        ),
        _ActionButton(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          count: likeCount,
          isActive: isLiked,
          isLoading: isLoadingLike,
          onTap: isOffline ? null : onLike,
          activeColor: Colors.pink,
          tooltip: isOffline ? offlineActionMessage('like this post') : null,
        ),
        _ActionButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
          activeIcon: Icons.bookmark,
          count: saveCount,
          isActive: isSaved,
          onTap: onSave != null ? () => _showSaveOptions(context) : null,
          onLongPress: onLongPressSave,
          color: context.colorScheme.onSurfaceVariant,
          activeColor: (saveType == 'cloud' || saveType == 'both') ? context.colorScheme.primary : Colors.amber,
        ),
        _ActionButton(
          icon: Icons.share_outlined,
          activeIcon: Icons.share,
          count: 0,
          onTap: onShare ?? () => _defaultShare(context),
          color: context.colorScheme.onSurfaceVariant,
        ),
        if (onMore != null)
          _ActionButton(
            icon: Icons.more_vert,
            activeIcon: Icons.more_vert,
            count: 0,
            onTap: onMore,
            color: context.colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }

  void _showRepostOptions(BuildContext context) {
    HapticHelper.mediumImpact();
    showOptionsSheet<void>(
      context: context,
      items: [
        OptionsSheetItem(
          leading: Icon(Icons.repeat, color: isReposted ? Colors.green : null),
          title: isReposted ? 'Unrepost' : 'Repost',
          subtitle: isReposted ? 'Remove this repost' : 'Share this post',
          onTap: onRepost,
        ),
        if (!isReposted)
          OptionsSheetItem(
            leading: const Icon(Icons.format_quote),
            title: 'Quote Post',
            subtitle: 'Quote this post with your own text',
            onTap: onQuote,
          ),
      ],
    );
  }

  void _showSaveOptions(BuildContext context) {
    HapticHelper.mediumImpact();
    final isLocalSaved = isSaved && (saveType == 'local' || saveType == 'both');
    final isCloudSaved = saveType == 'cloud' || saveType == 'both';
    showOptionsSheet<void>(
      context: context,
      items: [
        OptionsSheetItem(
          leading: Icon(
            isLocalSaved ? Icons.bookmark_remove_outlined : Icons.bookmark_add_outlined,
            color: Colors.amber,
          ),
          title: isLocalSaved ? 'Remove local save' : 'Save locally',
          onTap: onSave,
        ),
        OptionsSheetItem(
          leading: Icon(
            isCloudSaved ? Icons.cloud_off_outlined : Icons.cloud_outlined,
            color: context.colorScheme.primary,
          ),
          title: isCloudSaved ? 'Remove from Bluesky' : 'Save to Bluesky',
          onTap: isCloudSaved ? onCloudUnsave : onCloudSave,
        ),
      ],
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
    this.tooltip,
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
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? context.colorScheme.onSurfaceVariant;
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
              Text(formatCount(count), style: context.textTheme.bodySmall?.copyWith(color: iconColor)),
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

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
