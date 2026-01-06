import 'package:flutter/material.dart';

import '../../infrastructure/thread_repository.dart';

/// Displays reply restriction information when a threadgate is present.
class ThreadgateIndicator extends StatelessWidget {
  const ThreadgateIndicator({required this.threadgate, super.key});

  final Threadgate threadgate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: 'Reply restriction: ${threadgate.restrictionDescription}',
      child: Tooltip(
        message: threadgate.restrictionDescription,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline, size: 14, color: colorScheme.onSecondaryContainer),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  threadgate.restrictionDescription,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
