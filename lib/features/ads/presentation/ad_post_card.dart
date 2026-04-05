import 'package:flutter/material.dart';

class AdPostCard extends StatelessWidget {
  const AdPostCard({required this.child, this.isLinear = false, super.key});

  final bool isLinear;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return isLinear ? _buildLinear(context) : _buildGrid(context);
  }

  Widget _buildLinear(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Sponsored',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: double.infinity, minHeight: 80, maxHeight: 200),
          child: child,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Sponsored',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}
