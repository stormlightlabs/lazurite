import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

/// Formats a post timestamp as a short, uppercase string.
String formatPostTime(DateTime time) {
  return formatRelativeTime(time, nowLabel: 'NOW', uppercase: true);
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
    this.showCounts = false,
    this.isOffline = false,
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
  final bool showCounts;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final saveActiveColor = (saveType == 'cloud' || saveType == 'both') ? colorScheme.primary : Colors.amber;
    const horizontalPadding = 12.0;
    const iconSize = 18.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactLayout = constraints.maxWidth < 220;
        final actionSpacing = compactLayout ? 4.0 : 8.0;
        final actionPadding = compactLayout ? 2.0 : 4.0;
        final canShowCounts = showCounts && constraints.maxWidth >= 240;
        final actions = [
          _FooterAction(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            isActive: false,
            isLoading: false,
            count: replyCount,
            onTap: isOffline ? null : onReply,
            color: colorScheme.onSurfaceVariant,
            iconSize: iconSize,
            padding: actionPadding,
            showCount: canShowCounts,
            tooltip: isOffline ? offlineActionMessage('reply to this post') : null,
          ),
          _FooterAction(
            icon: Icons.repeat,
            activeIcon: Icons.repeat,
            isActive: isReposted,
            isLoading: isLoadingRepost,
            count: repostCount,
            onTap: isOffline ? null : onRepost,
            color: colorScheme.onSurfaceVariant,
            activeColor: Colors.green,
            iconSize: iconSize,
            padding: actionPadding,
            showCount: canShowCounts,
            tooltip: isOffline ? offlineActionMessage('repost this post') : null,
          ),
          _FooterAction(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            isActive: isLiked,
            isLoading: isLoadingLike,
            count: likeCount,
            onTap: isOffline ? null : onLike,
            color: colorScheme.onSurfaceVariant,
            activeColor: Colors.pink,
            iconSize: iconSize,
            padding: actionPadding,
            showCount: canShowCounts,
            tooltip: isOffline ? offlineActionMessage('like this post') : null,
          ),
          _FooterAction(
            icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
            activeIcon: Icons.bookmark,
            isActive: isSaved,
            isLoading: false,
            count: saveCount,
            onTap: onSave != null ? () => _showSaveOptions(context) : null,
            onLongPress: onLongPressSave,
            color: colorScheme.onSurfaceVariant,
            activeColor: saveActiveColor,
            iconSize: iconSize,
            padding: actionPadding,
            showCount: canShowCounts,
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
          child: compactLayout
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: actionSpacing,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: actions,
                    ),
                    const SizedBox(height: 6),
                    Align(alignment: Alignment.centerRight, child: _buildTimestamp(context, colorScheme)),
                  ],
                )
              : Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[if (i > 0) SizedBox(width: actionSpacing), actions[i]],
                    SizedBox(width: actionSpacing),
                    Expanded(
                      child: Align(alignment: Alignment.centerRight, child: _buildTimestamp(context, colorScheme)),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTimestamp(BuildContext context, ColorScheme colorScheme) {
    return Text(
      timestamp,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10, letterSpacing: 1.0),
    );
  }

  void _showSaveOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
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
            color: Theme.of(context).colorScheme.primary,
          ),
          title: isCloudSaved ? 'Remove from Bluesky' : 'Save to Bluesky',
          onTap: isCloudSaved ? onCloudUnsave : onCloudSave,
        ),
      ],
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
    required this.count,
    required this.showCount,
    this.onTap,
    this.onLongPress,
    this.color,
    this.activeColor,
    this.tooltip,
  });

  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final bool isLoading;
  final double iconSize;
  final double padding;
  final int count;
  final bool showCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? activeColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final defaultColor = color ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final iconColor = isActive ? (activeColor ?? defaultColor) : defaultColor;

    Widget button = InkWell(
      onTap: isLoading ? null : onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircularProgressIndicator(strokeWidth: 2, color: iconColor),
              )
            else
              Icon(isActive ? activeIcon : icon, size: iconSize, color: iconColor),
            if (showCount && count > 0) ...[
              const SizedBox(width: 4),
              Text(formatCount(count), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor)),
            ],
          ],
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
