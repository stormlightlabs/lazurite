import 'package:flutter/material.dart';

/// An inline error banner for network failures.
///
/// Displays a compact error message with optional retry button.
class NetworkErrorBanner extends StatelessWidget {
  /// Creates a network error banner.
  const NetworkErrorBanner({required this.message, this.onRetry, super.key});

  /// The error message to display.
  final String message;

  /// Callback for the retry action. If null, no retry button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 20, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: Text('Retry', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
          ],
        ),
      ),
    );
  }
}
