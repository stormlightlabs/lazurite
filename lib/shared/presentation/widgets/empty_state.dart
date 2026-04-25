import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.subtitle,
    this.padding = const EdgeInsets.all(24),
  });

  final String message;
  final IconData icon;
  final Widget? action;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            ..._subtitle(subtitle, textTheme, colorScheme),
            ..._action(action),
          ],
        ),
      ),
    );
  }

  List<Widget> _action(Widget? action) => (action == null) ? [] : [const SizedBox(height: 16), action];

  List<Widget> _subtitle(String? subtitle, TextTheme textTheme, ColorScheme colorScheme) => (subtitle == null)
      ? []
      : [
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ];
}
