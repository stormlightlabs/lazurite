import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  const VerificationBadge({required this.verificationStatus, this.size = 16.0, super.key});

  final String? verificationStatus;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (verificationStatus == null) return const SizedBox.shrink();

    final theme = Theme.of(context);

    Color badgeColor;
    IconData icon;
    String tooltip;

    switch (verificationStatus) {
      case 'official':
        badgeColor = Colors.blue;
        icon = Icons.check;
        tooltip = 'Official Account';
        break;
      case 'business':
        badgeColor = Colors.amber;
        icon = Icons.business;
        tooltip = 'Business Account';
        break;
      default:
        badgeColor = theme.colorScheme.primary;
        icon = Icons.check;
        tooltip = 'Verified Account';
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
        child: Icon(icon, size: size - 4, color: theme.colorScheme.onPrimary),
      ),
    );
  }
}
