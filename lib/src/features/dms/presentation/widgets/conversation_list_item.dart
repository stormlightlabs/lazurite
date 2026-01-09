import 'package:flutter/material.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/avatar.dart';

class ConversationListItem extends StatelessWidget {
  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
    this.onLongPress,
  });

  final DmConversation conversation;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  String _buildSemanticLabel() {
    final otherParty = conversation.otherParty;
    final name = otherParty.displayName ?? otherParty.handle;
    final message = conversation.lastMessageText ?? 'No messages';
    final unread = conversation.hasUnread ? '${conversation.unreadCount} unread' : '';
    final request = !conversation.isAccepted ? 'Message request' : '';
    return '$name. $message. $unread $request'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final otherParty = conversation.otherParty;
    final lastMessageAt = conversation.lastMessageAt;

    return Semantics(
      label: _buildSemanticLabel(),
      button: true,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Avatar(imageUrl: otherParty.avatar, radius: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            otherParty.displayName ?? otherParty.handle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (lastMessageAt != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.formatRelative(lastMessageAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessageText ?? 'No messages',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: conversation.hasUnread
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: conversation.hasUnread
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (!conversation.isAccepted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Request',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
