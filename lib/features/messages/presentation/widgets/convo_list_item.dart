import 'package:bluesky_poptart/chat/bsky/convo/defs.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/shared/presentation/widgets/actor_name_widget.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';

class ConvoListItem extends StatelessWidget {
  const ConvoListItem({
    super.key,
    required this.convo,
    required this.currentUserDid,
    required this.onTap,
    required this.onMuteTap,
  });

  final ConvoView convo;
  final String currentUserDid;
  final VoidCallback onTap;
  final VoidCallback onMuteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final other = convo.members.where((m) => m.did != currentUserDid).firstOrNull;
    final displayName = other?.displayName;
    final handle = other?.handle ?? context.l10n.commonUnknown;
    final fallbackName = displayName ?? handle;
    final lastMessageText = _lastMessageText(context);

    return ListTile(
      onTap: onTap,
      leading: _buildAvatar(other?.avatar, fallbackName),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ActorNameWidget(
              displayName: displayName,
              handle: handle,
              displayNameStyle: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: convo.unreadCount > 0 ? FontWeight.w700 : FontWeight.normal,
              ),
              handleStyle: theme.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
              uppercaseHandle: false,
            ),
          ),
          if (convo.muted)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(Icons.volume_off, size: 14, color: theme.colorScheme.onSurfaceVariant),
            ),
          if (convo.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Badge(
                label: Text(
                  convo.unreadCount > 99 ? '99+' : convo.unreadCount.toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
        ],
      ),
      subtitle: lastMessageText != null
          ? Text(
              lastMessageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          : null,
      trailing: PopupMenuButton<_ConvoAction>(
        onSelected: (action) {
          if (action == _ConvoAction.mute || action == _ConvoAction.unmute) {
            onMuteTap();
          }
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: convo.muted ? _ConvoAction.unmute : _ConvoAction.mute,
            child: Text(convo.muted ? context.l10n.buttonUnmute : context.l10n.buttonMute),
          ),
        ],
        child: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, String fallbackText) {
    return ProfileAvatar(
      size: 48,
      imageUrl: avatarUrl,
      fallbackText: fallbackText,
      fallbackBuilder: (_) => const Icon(Icons.person),
    );
  }

  String? _lastMessageText(BuildContext context) {
    final lastMessage = convo.lastMessage;
    if (lastMessage == null) return null;

    return lastMessage.when(
      messageView: (data) => data.text.isNotEmpty ? data.text : null,
      deletedMessageView: (_) => context.l10n.messageDeleted,
      unknown: (_) => null,
    );
  }
}

enum _ConvoAction { mute, unmute }
