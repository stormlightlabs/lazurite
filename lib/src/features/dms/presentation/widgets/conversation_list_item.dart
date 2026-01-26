import 'package:flutter/material.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';

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

  Widget _buildOtherPartyName(TextTheme textTheme) {
    final otherParty = conversation.otherParty;
    return Text(
      otherParty.displayName ?? otherParty.handle,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: conversation.hasUnread ? FontWeight.bold : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLastMessage(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      conversation.lastMessageText ?? 'No messages',
      style: textTheme.bodyMedium?.copyWith(
        color: conversation.hasUnread ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
        fontWeight: conversation.hasUnread ? FontWeight.w500 : FontWeight.normal,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<Widget> _buildLastMessageTime(
    TextTheme textTheme,
    ColorScheme colorScheme,
    DateTime lastMessageAt,
  ) {
    return [
      const SizedBox(width: 8),
      Text(
        DateFormatter.formatRelative(lastMessageAt),
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: conversation.hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
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
                        Expanded(child: _buildOtherPartyName(textTheme)),
                        if (lastMessageAt != null)
                          ..._buildLastMessageTime(textTheme, colorScheme, lastMessageAt),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: _buildLastMessage(textTheme, colorScheme)),
                        if (conversation.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
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
                              color: colorScheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Request',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onTertiaryContainer,
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
