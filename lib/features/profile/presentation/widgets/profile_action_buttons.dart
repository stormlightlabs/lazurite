import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/shared/presentation/helpers/haptic_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';

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
    this.isOffline = false,
    this.onFollow,
    this.onUnfollow,
    this.onMute,
    this.onUnmute,
    this.onBlock,
    this.onUnblock,
    this.onMore,
    this.onAddToList,
  });

  final bool isFollowing;
  final bool isMuted;
  final bool isBlocked;
  final bool isBlockedBy;
  final bool isLoadingFollow;
  final bool isLoadingMute;
  final bool isLoadingBlock;
  final bool isOffline;
  final VoidCallback? onFollow;
  final VoidCallback? onUnfollow;
  final VoidCallback? onMute;
  final VoidCallback? onUnmute;
  final VoidCallback? onBlock;
  final VoidCallback? onUnblock;
  final VoidCallback? onMore;
  final VoidCallback? onAddToList;

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
    final l10n = context.l10n;
    if (isBlocked) {
      return _ActionButton(
        label: l10n.buttonUnblock,
        onPressed: isOffline || onUnblock == null ? null : () => _confirmUnblock(context),
        isLoading: isLoadingBlock,
        foregroundColor: context.colorScheme.onError,
        backgroundColor: context.colorScheme.error,
        tooltip: isOffline ? l10n.formatOfflineReconnectAction(l10n.buttonUnblock.toLowerCase()) : null,
      );
    }

    if (isFollowing) {
      return _ActionButton(
        label: l10n.buttonFollowing,
        onPressed: isOffline || onUnfollow == null ? null : () => _confirmUnfollow(context),
        isLoading: isLoadingFollow,
        isSecondary: true,
        tooltip: isOffline ? l10n.formatOfflineReconnectAction('change your follow state') : null,
      );
    }

    return _ActionButton(
      label: l10n.buttonFollow,
      onPressed: isOffline ? null : onFollow,
      isLoading: isLoadingFollow,
      tooltip: isOffline ? l10n.formatOfflineReconnectAction('follow this account') : null,
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    final l10n = context.l10n;
    final List<PopupMenuEntry<void>> menuItems = [];

    if (!isBlocked) {
      if (isMuted) {
        menuItems.add(
          PopupMenuItem(
            child: Row(
              children: [const Icon(Icons.volume_up_outlined), const SizedBox(width: 8), Text(l10n.buttonUnmute)],
            ),
            onTap: () => _confirmUnmute(context),
          ),
        );
      } else {
        menuItems.add(
          PopupMenuItem(
            child: Row(
              children: [const Icon(Icons.volume_off_outlined), const SizedBox(width: 8), Text(l10n.buttonMute)],
            ),
            onTap: () => _confirmMute(context),
          ),
        );
      }

      menuItems.add(
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.block_outlined, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.buttonBlock, style: const TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () => _confirmBlock(context),
        ),
      );
    }

    if (onAddToList != null) {
      menuItems.add(
        PopupMenuItem(
          onTap: onAddToList,
          child: Row(
            children: [const Icon(Icons.playlist_add_outlined), const SizedBox(width: 8), Text(l10n.labelAddToList)],
          ),
        ),
      );
    }

    menuItems.addAll([
      const PopupMenuDivider(),
      PopupMenuItem(
        onTap: onMore,
        child: Row(
          children: [
            const Icon(Icons.report_outlined, color: Colors.orange),
            const SizedBox(width: 8),
            Text(l10n.labelReport, style: const TextStyle(color: Colors.orange)),
          ],
        ),
      ),
    ]);

    Widget button = PopupMenuButton<void>(
      enabled: !isOffline,
      icon: const Icon(Icons.more_vert),
      itemBuilder: (_) => menuItems,
    );
    if (isOffline) {
      button = Tooltip(message: l10n.formatOfflineReconnectAction('manage this profile'), child: button);
    }
    return button;
  }

  Future<void> _confirmUnfollow(BuildContext context) async {
    HapticHelper.mediumImpact();
    await showConfirmationDialog(
      context: context,
      title: Text(context.l10n.dialogUnfollowAccountTitle),
      content: Text(context.l10n.dialogUnfollowAccountContent),
      confirmLabel: context.l10n.buttonUnfollow,
      onConfirmed: onUnfollow,
    );
  }

  Future<void> _confirmMute(BuildContext context) async {
    HapticHelper.mediumImpact();
    await showConfirmationDialog(
      context: context,
      title: Text(context.l10n.dialogMuteAccountTitle),
      content: Text(context.l10n.dialogMuteAccountContent),
      confirmLabel: context.l10n.buttonMute,
      onConfirmed: onMute,
    );
  }

  Future<void> _confirmUnmute(BuildContext context) async {
    HapticHelper.mediumImpact();
    await showConfirmationDialog(
      context: context,
      title: Text(context.l10n.dialogUnmuteAccountTitle),
      content: Text(context.l10n.dialogUnmuteAccountContent),
      confirmLabel: context.l10n.buttonUnmute,
      onConfirmed: onUnmute,
    );
  }

  Future<void> _confirmBlock(BuildContext context) async {
    HapticHelper.heavyImpact();
    await showConfirmationDialog(
      context: context,
      title: Row(
        children: [
          Icon(Icons.block, color: context.colorScheme.error),
          const SizedBox(width: 8),
          Text(context.l10n.dialogBlockAccountTitle),
        ],
      ),
      content: Text(context.l10n.dialogBlockAccountContent),
      confirmLabel: context.l10n.buttonBlock,
      confirmDestructive: true,
      onConfirmed: onBlock,
    );
  }

  Future<void> _confirmUnblock(BuildContext context) async {
    HapticHelper.mediumImpact();
    await showConfirmationDialog(
      context: context,
      title: Text(context.l10n.dialogUnblockAccountTitle),
      content: Text(context.l10n.dialogUnblockAccountContent),
      confirmLabel: context.l10n.buttonUnblock,
      onConfirmed: onUnblock,
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
    this.tooltip,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isSecondary) {
      final button = OutlinedButton(onPressed: isLoading ? null : onPressed, child: _buildChild(theme));
      return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
    }

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(foregroundColor: foregroundColor, backgroundColor: backgroundColor),
      child: _buildChild(theme),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
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
