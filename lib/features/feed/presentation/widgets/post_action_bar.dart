import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/animation_tokens.dart';
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
          animateOnTap: true,
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
          animateOnTap: true,
          onTap: isOffline ? null : onLike,
          activeColor: Colors.pink,
          tooltip: isOffline ? offlineActionMessage('like this post') : null,
        ),
        _ActionButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_outline,
          activeIcon: Icons.bookmark,
          count: saveCount,
          isActive: isSaved,
          animateOnTap: true,
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
    this.animateOnTap = false,
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
  final bool animateOnTap;

  @override
  Widget build(BuildContext context) {
    return _ActionButtonBody(
      icon: icon,
      activeIcon: activeIcon,
      count: count,
      isActive: isActive,
      isLoading: isLoading,
      onTap: onTap,
      onLongPress: onLongPress,
      color: color,
      activeColor: activeColor,
      tooltip: tooltip,
      animateOnTap: animateOnTap,
    );
  }
}

class _ActionButtonBody extends StatefulWidget {
  const _ActionButtonBody({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.isActive,
    required this.isLoading,
    required this.onTap,
    required this.onLongPress,
    required this.color,
    required this.activeColor,
    required this.tooltip,
    required this.animateOnTap,
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
  final bool animateOnTap;

  @override
  State<_ActionButtonBody> createState() => _ActionButtonBodyState();
}

class _ActionButtonBodyState extends State<_ActionButtonBody> {
  int _tapSequence = 0;

  @override
  Widget build(BuildContext context) {
    final defaultColor = widget.color ?? context.colorScheme.onSurfaceVariant;
    final iconColor = widget.isActive ? (widget.activeColor ?? defaultColor) : defaultColor;
    final iconWidget = widget.isLoading
        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
        : AnimatedSwitcher(
            duration: Anim.fast,
            switchInCurve: Anim.enter,
            switchOutCurve: Anim.exit,
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: Icon(
              widget.isActive ? widget.activeIcon : widget.icon,
              key: ValueKey('${widget.isActive}-${widget.isLoading}'),
              size: 18,
              color: iconColor,
            ),
          );

    Widget button = InkWell(
      onTap: widget.isLoading ? null : _handleTap,
      onLongPress: widget.onLongPress,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            if (widget.count > 0) ...[
              const SizedBox(width: 4),
              Text(formatCount(widget.count), style: context.textTheme.bodySmall?.copyWith(color: iconColor)),
            ],
          ],
        ),
      ),
    );

    if (widget.animateOnTap && _tapSequence > 0) {
      button = button.animate(
        key: ValueKey('action-${widget.icon.codePoint}-$_tapSequence'),
        effects: const [
          ScaleEffect(begin: Offset(1, 1), end: Offset(1.3, 1.3), duration: Anim.actionBounceIn, curve: Anim.enter),
          ScaleEffect(begin: Offset(1.3, 1.3), end: Offset(1, 1), duration: Anim.actionBounceOut, curve: Anim.emphasis),
        ],
      );
    }

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }

  void _handleTap() {
    if (widget.onTap == null) {
      return;
    }

    if (widget.animateOnTap) {
      setState(() => _tapSequence++);
    }
    widget.onTap!.call();
  }
}
