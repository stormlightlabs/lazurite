import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileActionButtons extends StatelessWidget {
  const ProfileActionButtons({
    super.key,
    required this.isFollowing,
    required this.isMuted,
    required this.isBlocked,
    required this.isBlockedBy,
    required this.isLoadingFollow,
    required this.isLoadingMute,
    required this.isLoadingBlock,
    this.onFollow,
    this.onUnfollow,
    this.onMute,
    this.onUnmute,
    this.onBlock,
    this.onUnblock,
    this.onMore,
  });

  final bool isFollowing;
  final bool isMuted;
  final bool isBlocked;
  final bool isBlockedBy;
  final bool isLoadingFollow;
  final bool isLoadingMute;
  final bool isLoadingBlock;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onMute;
  final VoidCallback? onUnmute;
  final VoidCallback? onBlock;
  final VoidCallback? onUnblock;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    if (isBlockedBy) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [_buildFollowButton(context), const SizedBox(width: 8), _buildMoreButton(context)],
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    if (isBlocked) {
      return _ActionButton(
        label: 'Unblock',
        onPressed: onUnblock != null ? () => _confirmUnblock(context) : null,
        isLoading: isLoadingBlock,
        foregroundColor: Theme.of(context).colorScheme.onError,
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    }

    if (isFollowing) {
      return _ActionButton(
        label: 'Following',
        onPressed: onUnfollow != null ? () => _confirmUnfollow(context) : null,
        isLoading: isLoadingFollow,
        isSecondary: true,
      );
    }

    return _ActionButton(label: 'Follow', onPressed: onFollow, isLoading: isLoadingFollow);
  }

  Widget _buildMoreButton(BuildContext context) {
    final List<PopupMenuEntry<void>> menuItems = [];

    if (!isBlocked) {
      if (isMuted) {
        menuItems.add(
          PopupMenuItem(
            child: const Row(children: [Icon(Icons.volume_up_outlined), SizedBox(width: 8), Text('Unmute')]),
            onTap: () => _confirmUnmute(context),
          ),
        );
      } else {
        menuItems.add(
          PopupMenuItem(
            child: const Row(children: [Icon(Icons.volume_off_outlined), SizedBox(width: 8), Text('Mute')]),
            onTap: () => _confirmMute(context),
          ),
        );
      }

      menuItems.add(
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.block_outlined, color: Colors.red),
              SizedBox(width: 8),
              Text('Block', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => _confirmBlock(context),
        ),
      );
    }

    menuItems.addAll([
      const PopupMenuDivider(),
      PopupMenuItem(
        onTap: onMore,
        child: const Row(
          children: [
            Icon(Icons.report_outlined, color: Colors.orange),
            SizedBox(width: 8),
            Text('Report', style: TextStyle(color: Colors.orange)),
          ],
        ),
      ),
    ]);

    return PopupMenuButton<void>(icon: const Icon(Icons.more_vert), itemBuilder: (_) => menuItems);
  }

  void _confirmUnfollow(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unfollow?'),
        content: const Text('You will no longer see their posts in your feed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onUnfollow?.call();
            },
            child: const Text('Unfollow'),
          ),
        ],
      ),
    );
  }

  void _confirmMute(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute Account?'),
        content: const Text('You will no longer see their posts or receive notifications from them.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onMute?.call();
            },
            child: const Text('Mute'),
          ),
        ],
      ),
    );
  }

  void _confirmUnmute(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unmute Account?'),
        content: const Text('You will see their posts and receive notifications again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onUnmute?.call();
            },
            child: const Text('Unmute'),
          ),
        ],
      ),
    );
  }

  void _confirmBlock(BuildContext context) {
    HapticFeedback.heavyImpact();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.block, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Block Account?'),
          ],
        ),
        content: const Text(
          'They will not be able to see your posts or interact with you. They will not be notified that you blocked them.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onBlock?.call();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _confirmUnblock(BuildContext context) {
    HapticFeedback.mediumImpact();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock Account?'),
        content: const Text('They will be able to see your posts and interact with you again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onUnblock?.call();
            },
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.foregroundColor,
    this.backgroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSecondary) {
      return OutlinedButton(onPressed: isLoading ? null : onPressed, child: _buildChild(theme));
    }

    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(foregroundColor: foregroundColor, backgroundColor: backgroundColor),
      child: _buildChild(theme),
    );
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isSecondary ? theme.colorScheme.primary : (foregroundColor ?? theme.colorScheme.onPrimary),
        ),
      );
    }
    return Text(label);
  }
}
