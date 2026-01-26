import 'package:flutter/material.dart';

/// A full-screen error state widget.
///
/// Displays a centered error icon, title, optional message, and optional retry button.
/// Use for handling errors that prevent content from being displayed.
class ErrorView extends StatelessWidget {
  /// Creates an error view.
  const ErrorView({required this.title, this.message, this.onRetry, super.key});

  /// The main error title.
  final String title;

  /// Optional detailed error message.
  final String? message;

  /// Callback for the retry button. If null, no retry button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error.withAlpha(153)),
            const SizedBox(height: 16),
            Text(title, style: textTheme.headlineSmall, textAlign: TextAlign.center),
            ..._buildMessage(textTheme, colorScheme),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMessage(TextTheme textTheme, ColorScheme colorScheme) {
    if (message != null) {
      return [
        const SizedBox(height: 8),
        Text(
          message!,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withAlpha(153)),
          textAlign: TextAlign.center,
        ),
      ];
    }

    return [];
  }
}
