import 'package:flutter/material.dart';
import 'package:lazurite/features/connectivity/connectivity_helpers.dart';
import 'package:lazurite/shared/presentation/helpers/haptic_helper.dart';
import 'package:lazurite/shared/presentation/widgets/options_sheet.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

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
    this.onQuote,
    this.onLike,
    this.onSave,
    this.onLongPressSave,
    this.onCloudSave,
    this.onCloudUnsave,
    this.onMore,
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
  final VoidCallback? onQuote;
  final VoidCallback? onLike;
  final VoidCallback? onSave;
  final VoidCallback? onLongPressSave;
  final VoidCallback? onCloudSave;
  final VoidCallback? onCloudUnsave;
  final VoidCallback? onMore;
  final bool showCounts;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final saveActiveColor = (saveType == 'cloud' || saveType == 'both') ? colorScheme.primary : Colors.amber;
    const horizontalPadding = 8.0;
    const topPadding = 6.0;
    const bottomPadding = 4.0;
    const iconSize = 20.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactLayout = constraints.maxWidth < 240;
        final actionSpacing = compactLayout ? 4.0 : 8.0;
        final actionHorizontalPadding = compactLayout ? 6.0 : 8.0;
        final actionVerticalPadding = compactLayout ? 6.0 : 8.0;
        final minimumTapTarget = compactLayout ? 40.0 : 44.0;
        final canShowCounts = showCounts && constraints.maxWidth >= 240;
        final actions = <Widget>[
          _FooterAction(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            isActive: false,
            isLoading: false,
            count: replyCount,
            onTap: isOffline ? null : onReply,
            color: colorScheme.onSurfaceVariant,
            iconSize: iconSize,
            horizontalPadding: actionHorizontalPadding,
            verticalPadding: actionVerticalPadding,
            minTapTarget: minimumTapTarget,
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
            onLongPress: !isOffline && onRepost != null ? () => _showRepostOptions(context) : null,
            color: colorScheme.onSurfaceVariant,
            activeColor: Colors.green,
            iconSize: iconSize,
            horizontalPadding: actionHorizontalPadding,
            verticalPadding: actionVerticalPadding,
            minTapTarget: minimumTapTarget,
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
            horizontalPadding: actionHorizontalPadding,
            verticalPadding: actionVerticalPadding,
            minTapTarget: minimumTapTarget,
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
            horizontalPadding: actionHorizontalPadding,
            verticalPadding: actionVerticalPadding,
            minTapTarget: minimumTapTarget,
            showCount: canShowCounts,
          ),
        ];
        final trailingMeta = _buildTrailingMeta(
          context: context,
          colorScheme: colorScheme,
          iconSize: iconSize,
          actionHorizontalPadding: actionHorizontalPadding,
          actionVerticalPadding: actionVerticalPadding,
          minimumTapTarget: minimumTapTarget,
        );

        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          padding: const EdgeInsets.fromLTRB(horizontalPadding, topPadding, horizontalPadding, bottomPadding),
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
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: trailingMeta),
                  ],
                )
              : Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[if (i > 0) SizedBox(width: actionSpacing), actions[i]],
                    SizedBox(width: actionSpacing),
                    Expanded(
                      child: Align(alignment: Alignment.centerRight, child: trailingMeta),
                    ),
                  ],
                ),
        );
      },
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

  Widget _buildTimestamp(BuildContext context, ColorScheme colorScheme) {
    return Text(
      timestamp,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: context.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontSize: 10,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTrailingMeta({
    required BuildContext context,
    required ColorScheme colorScheme,
    required double iconSize,
    required double actionHorizontalPadding,
    required double actionVerticalPadding,
    required double minimumTapTarget,
  }) {
    return Row(
      key: const ValueKey('post_footer_trailing_meta'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimestamp(context, colorScheme),
        if (onMore != null) ...[
          const SizedBox(width: 2),
          _FooterAction(
            icon: Icons.more_vert,
            activeIcon: Icons.more_vert,
            isActive: false,
            isLoading: false,
            count: 0,
            onTap: onMore,
            color: colorScheme.onSurfaceVariant,
            iconSize: iconSize,
            horizontalPadding: actionHorizontalPadding,
            verticalPadding: actionVerticalPadding,
            minTapTarget: minimumTapTarget,
            showCount: false,
          ),
        ],
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
}

class _FooterAction extends StatelessWidget {
  const _FooterAction({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.isLoading,
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.minTapTarget,
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
  final double horizontalPadding;
  final double verticalPadding;
  final double minTapTarget;
  final int count;
  final bool showCount;
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
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minTapTarget, minHeight: minTapTarget),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
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
                Text(formatCount(count), style: context.textTheme.bodySmall?.copyWith(color: iconColor)),
              ],
            ],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}
