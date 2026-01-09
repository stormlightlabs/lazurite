import 'package:flutter/material.dart';

import '../../domain/dm_message.dart';

/// Displays the delivery status of a message.
///
/// Shows different icons based on the message status:
/// - pending: clock icon
/// - sending: spinner
/// - sent: single checkmark
/// - read: double checkmark
/// - failed: error icon with optional retry callback
class DeliveryStatusIndicator extends StatelessWidget {
  const DeliveryStatusIndicator({super.key, required this.status, this.onRetry, this.size = 16.0});

  final MessageStatus status;
  final VoidCallback? onRetry;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final statusWidget = switch (status) {
      MessageStatus.pending => Icon(
        Icons.access_time,
        key: const ValueKey('pending'),
        size: size,
        color: theme.colorScheme.onSurfaceVariant,
        semanticLabel: 'Pending',
      ),
      MessageStatus.sending => SizedBox(
        key: const ValueKey('sending'),
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      MessageStatus.sent => Icon(
        Icons.check,
        key: const ValueKey('sent'),
        size: size,
        color: theme.colorScheme.onSurfaceVariant,
        semanticLabel: 'Sent',
      ),
      MessageStatus.read => Icon(
        Icons.done_all,
        key: const ValueKey('read'),
        size: size,
        color: theme.colorScheme.primary,
        semanticLabel: 'Read',
      ),
      MessageStatus.failed => GestureDetector(
        key: const ValueKey('failed'),
        onTap: onRetry,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: size,
              color: theme.colorScheme.error,
              semanticLabel: 'Failed to send',
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 4),
              Text(
                'Retry',
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      MessageStatus.deleted => Icon(
        Icons.block,
        key: const ValueKey('deleted'),
        size: size,
        color: theme.colorScheme.onSurfaceVariant,
        semanticLabel: 'Deleted',
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: animation, child: child),
      ),
      child: statusWidget,
    );
  }
}
