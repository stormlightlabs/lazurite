import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A collapsible toggle with Cupertino chevron-circle icons.
///
/// Uses `chevron_right_circle` when collapsed and `chevron_down_circle`
/// when expanded, matching the system thread expansion affordance.
class CollapseToggle extends StatelessWidget {
  const CollapseToggle({required this.isCollapsed, required this.onTap, super.key});

  /// Whether the associated thread is currently collapsed
  final bool isCollapsed;

  /// Callback when toggle is tapped
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final icon = isCollapsed
        ? CupertinoIcons.chevron_right_circle
        : CupertinoIcons.chevron_down_circle;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant)),
      ),
    );
  }
}
