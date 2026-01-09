import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/avatar.dart';
import '../../../../infrastructure/db/app_database.dart';
import '../../domain/dm_message.dart';
import 'delivery_status_indicator.dart';

/// Displays a single message in a conversation.
///
/// Handles:
/// - Alignment (right for sent, left for received)
/// - Avatar display (only for received messages)
/// - Timestamp and delivery status
/// - Visual grouping for consecutive messages from same sender
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isFromMe,
    this.senderProfile,
    this.showAvatar = true,
    this.onRetry,
  });

  /// The message to display.
  final AppDmMessage message;

  /// Whether this message was sent by the current user.
  final bool isFromMe;

  /// Profile of the sender (for received messages).
  final Profile? senderProfile;

  /// Whether to show the sender's avatar.
  /// Set to false for consecutive messages from the same sender.
  final bool showAvatar;

  /// Callback for retrying a failed message.
  final VoidCallback? onRetry;

  String _buildSemanticLabel() {
    final sender = isFromMe ? 'You' : (senderProfile?.displayName ?? 'Unknown');
    final time = DateFormatter.formatRelative(message.sentAt);
    final statusLabel = switch (message.status) {
      MessageStatus.pending => 'pending',
      MessageStatus.sending => 'sending',
      MessageStatus.sent => 'sent',
      MessageStatus.read => 'read',
      MessageStatus.failed => 'failed to send',
      MessageStatus.deleted => 'deleted',
    };
    return '$sender said: ${message.content}. $time. Status: $statusLabel';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = isFromMe
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isFromMe
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Semantics(
      label: _buildSemanticLabel(),
      child: Padding(
        padding: EdgeInsets.only(
          left: isFromMe ? 48 : 8,
          right: isFromMe ? 8 : 48,
          top: 4,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isFromMe && showAvatar) ...[
              Avatar(imageUrl: senderProfile?.avatar, radius: 16),
              const SizedBox(width: 8),
            ] else if (!isFromMe) ...[
              const SizedBox(width: 40), // Space for hidden avatar
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isFromMe ? 16 : 4),
                    bottomRight: Radius.circular(isFromMe ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isFromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormatter.formatRelative(message.sentAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: textColor.withAlpha(153),
                          ),
                        ),
                        if (isFromMe) ...[
                          const SizedBox(width: 4),
                          DeliveryStatusIndicator(
                            status: message.status,
                            onRetry: message.isFailed ? onRetry : null,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
