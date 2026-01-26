import 'package:flutter/material.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/core/utils/date_formatter.dart';
import 'package:lazurite/src/core/widgets/avatar.dart';
import 'package:lazurite/src/features/dms/domain/dm_conversation.dart';

/// A card widget for displaying a message request.
///
/// Shows the sender's profile, message preview, and accept/decline
/// buttons for unaccepted conversation requests.
class MessageRequestCard extends StatelessWidget {
  const MessageRequestCard({
    super.key,
    required this.conversation,
    required this.onAccept,
    required this.onDecline,
    this.onTap,
  });

  /// The conversation request to display.
  final DmConversation conversation;

  /// Called when the user accepts the request.
  final VoidCallback onAccept;

  /// Called when the user declines the request (client-side hide).
  final VoidCallback onDecline;

  /// Called when the user taps the card to view the conversation.
  final VoidCallback? onTap;

  String _buildSemanticLabel() {
    final otherParty = conversation.otherParty;
    final name = otherParty.displayName ?? otherParty.handle;
    final message = conversation.lastMessageText ?? 'No message preview';
    return 'Message request from $name. $message. Double tap to view, or use buttons to accept or decline.';
  }

  Widget _otherPartyInfo(Author other, TextTheme textTheme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          other.displayName ?? other.handle,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '@${other.handle}',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildLastMessageText(String? text, TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(Icons.chat_bubble_outline, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text!,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLastMessageTime(
    DateTime? time,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) => time == null
      ? []
      : [
          const SizedBox(width: 8),
          Text(
            DateFormatter.formatRelative(time),
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ];

  Widget _buildButtons(TextTheme textTheme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onDecline,
            style: OutlinedButton.styleFrom(foregroundColor: colorScheme.onSurfaceVariant),
            child: const Text('Decline'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(onPressed: onAccept, child: const Text('Accept')),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final otherParty = conversation.otherParty;
    final lastMessageAt = conversation.lastMessageAt;
    final lastMessageText = conversation.lastMessageText;

    return Semantics(
      label: _buildSemanticLabel(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(imageUrl: otherParty.avatar, radius: 24),
                    const SizedBox(width: 12),
                    Expanded(child: _otherPartyInfo(otherParty, textTheme, colorScheme)),
                    ..._buildLastMessageTime(lastMessageAt, textTheme, colorScheme),
                  ],
                ),
                const SizedBox(height: 12),
                if (conversation.lastMessageText != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildLastMessageText(lastMessageText, textTheme, colorScheme),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildButtons(textTheme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
