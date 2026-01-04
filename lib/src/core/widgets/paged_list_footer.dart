import 'package:flutter/material.dart';

/// The state of a paginated list footer.
enum PagedListState {
  /// Currently loading more items.
  loading,

  /// Reached the end of the list.
  end,

  /// An error occurred while loading more items.
  error,
}

/// A footer widget for paginated lists.
///
/// Displays different content based on the current [PagedListState]:
/// - Loading: Shows a progress indicator
/// - End: Shows "You've reached the end" message
/// - Error: Shows error message with optional retry button
class PagedListFooter extends StatelessWidget {
  const PagedListFooter({
    required this.state,
    this.errorMessage,
    this.onRetry,
    this.endMessage,
    super.key,
  });

  /// The current state of the paged list.
  final PagedListState state;

  /// Error message to display in error state.
  final String? errorMessage;

  /// Callback for retry button in error state.
  final VoidCallback? onRetry;

  /// Custom message for end state.
  final String? endMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: switch (state) {
          PagedListState.loading => const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          PagedListState.end => Text(
            endMessage ?? "You've reached the end",
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(102),
            ),
          ),
          PagedListState.error => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 24, color: theme.colorScheme.error.withAlpha(153)),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Failed to load more',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        },
      ),
    );
  }
}
