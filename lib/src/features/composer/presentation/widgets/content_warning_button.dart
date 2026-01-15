import 'package:flutter/material.dart';

/// A button that displays content warning state.
///
/// Shows different states based on whether content warnings are set:
/// - No warnings: Shows an icon with "Add warning" label
/// - Has warnings: Shows an icon with the warning count
class ContentWarningButton extends StatelessWidget {
  const ContentWarningButton({super.key, required this.labels, required this.onTap, this.size});

  /// Currently selected content warning labels.
  final List<String> labels;

  /// Callback when the button is tapped.
  final VoidCallback onTap;

  /// Optional size constraint.
  final Size? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasWarnings = labels.isNotEmpty;
    final label = hasWarnings
        ? '${labels.length} warning${labels.length > 1 ? "s" : ""}'
        : 'Add warning';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: size?.height ?? 40,
        constraints: BoxConstraints(minWidth: size?.width ?? 100),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasWarnings
              ? theme.colorScheme.errorContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 18,
              color: hasWarnings
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: hasWarnings
                    ? theme.colorScheme.onErrorContainer
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: hasWarnings ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
