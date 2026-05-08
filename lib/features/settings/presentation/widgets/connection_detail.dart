import 'package:flutter/material.dart';

class ConnectionDetailRow extends StatelessWidget {
  const ConnectionDetailRow({super.key, required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'JetBrains Mono')),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 12),
            Icon(Icons.open_in_new, size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }
}
