import 'package:flutter/material.dart';

import '../../domain/draft.dart';

/// Displays a colored status chip for a draft's current state.
class DraftStatusChip extends StatelessWidget {
  const DraftStatusChip({required this.status, super.key});

  /// The draft status to display.
  final DraftStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (label, color, icon) = switch (status) {
      DraftStatus.draft => ('Draft', colorScheme.outline, Icons.edit_outlined),
      DraftStatus.publishing => ('Publishing', colorScheme.primary, null),
      DraftStatus.failed => ('Failed', colorScheme.error, Icons.error_outline),
      DraftStatus.posted => ('Posted', Colors.green, Icons.check_circle_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == DraftStatus.publishing) ...[
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: color),
            ),
            const SizedBox(width: 4),
          ] else if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}
