import 'package:bluesky/chat_bsky_convo_defs.dart';
import 'package:flutter/material.dart';

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
    final displayName = other?.displayName ?? other?.handle ?? 'Unknown';
    final lastMessageText = _lastMessageText();

    return ListTile(
      onTap: onTap,
      leading: _buildAvatar(context, other?.avatar),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: convo.unreadCount > 0 ? FontWeight.w700 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
            child: Text(convo.muted ? 'Unmute' : 'Mute'),
          ),
        ],
        child: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? avatarUrl) {
    final theme = Theme.of(context);
    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
      child: avatarUrl == null ? const Icon(Icons.person) : null,
    );
  }

  String? _lastMessageText() {
    final lastMessage = convo.lastMessage;
    if (lastMessage == null) return null;

    return lastMessage.when(
      messageView: (data) => data.text.isNotEmpty ? data.text : null,
      deletedMessageView: (_) => 'Message deleted',
      unknown: (_) => null,
    );
  }
}

enum _ConvoAction { mute, unmute }
