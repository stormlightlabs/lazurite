import 'package:flutter/material.dart';

class ProfileLabels extends StatelessWidget {
  const ProfileLabels({required this.labels, super.key});

  final List<Map<String, dynamic>>? labels;

  @override
  Widget build(BuildContext context) {
    if (labels == null || labels!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: labels!.map((label) {
        final val = label['val'] as String? ?? 'Label';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            val,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onErrorContainer),
          ),
        );
      }).toList(),
    );
  }
}
