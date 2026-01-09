import 'package:flutter/material.dart';

/// Displays viewer relationship state indicators on profiles.
///
/// Shows visual indicators for muted, blocked, blocked-by, and
/// follows-you states with appropriate icons and colors.
class ProfileRelationshipIndicator extends StatelessWidget {
  const ProfileRelationshipIndicator({
    this.viewerMuted = false,
    this.viewerBlocked = false,
    this.viewerBlockedBy = false,
    this.viewerFollowedBy = false,
    this.mutedByList,
    this.blockingByList,
    super.key,
  });

  /// Whether the viewer has muted this profile.
  final bool viewerMuted;

  /// Whether the viewer has blocked this profile.
  final bool viewerBlocked;

  /// Whether this profile has blocked the viewer.
  final bool viewerBlockedBy;

  /// Whether this profile follows the viewer.
  final bool viewerFollowedBy;

  /// Reference to the list that muted this profile (if muted via list).
  final String? mutedByList;

  /// Reference to the list that blocked this profile (if blocked via list).
  final String? blockingByList;

  @override
  Widget build(BuildContext context) {
    final indicators = <Widget>[];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (viewerBlockedBy) {
      indicators.add(
        _IndicatorChip(
          icon: Icons.block,
          label: 'Blocks you',
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        ),
      );
    }

    if (viewerBlocked) {
      final label = blockingByList != null ? 'Blocked via list' : 'Blocked';
      indicators.add(
        _IndicatorChip(
          icon: Icons.block,
          label: label,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        ),
      );
    }

    if (viewerMuted) {
      final label = mutedByList != null ? 'Muted via list' : 'Muted';
      indicators.add(
        _IndicatorChip(
          icon: Icons.volume_off,
          label: label,
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
        ),
      );
    }

    if (viewerFollowedBy) {
      indicators.add(
        _IndicatorChip(
          icon: Icons.person_add,
          label: 'Follows you',
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        ),
      );
    }

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 8, runSpacing: 4, children: indicators);
  }
}

class _IndicatorChip extends StatelessWidget {
  const _IndicatorChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: foregroundColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}
