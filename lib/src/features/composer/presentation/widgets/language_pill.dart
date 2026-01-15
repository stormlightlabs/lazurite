import 'package:flutter/material.dart';

/// A compact pill widget displaying a language code.
///
/// Shows ISO 639 language codes (e.g., "EN", "ES", "JA") as rounded pills.
/// Can be displayed with or without a remove button.
class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key, required this.code, this.onRemove, this.showRemove = true});

  /// The ISO 639 language code to display (will be uppercased).
  final String code;

  /// Callback when the remove button is tapped.
  final VoidCallback? onRemove;

  /// Whether to show the remove button.
  final bool showRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                code.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (showRemove && onRemove != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.close, size: 16, color: theme.colorScheme.onSurfaceVariant),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
