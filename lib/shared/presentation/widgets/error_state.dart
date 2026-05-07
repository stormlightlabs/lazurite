import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    required this.onRetry,
    this.title,
    this.retryLabel,
    this.icon = Icons.error_outline,
  });

  final String? title;
  final String message;
  final VoidCallback onRetry;
  final String? retryLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(title ?? l10n.errorGenericTitle, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: Text(retryLabel ?? l10n.buttonRetry)),
          ],
        ),
      ),
    );
  }
}
