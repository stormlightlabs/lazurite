import 'package:flutter/material.dart';

/// A section header for grouping related settings.
///
/// Displays a title with consistent styling and spacing. Used to organize
/// settings into logical groups like "Account", "Appearance", etc.
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.title, this.padding, super.key});

  final String title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
