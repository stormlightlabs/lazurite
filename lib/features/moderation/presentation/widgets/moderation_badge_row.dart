import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';

class ModerationBadgeRow extends StatelessWidget {
  const ModerationBadgeRow({super.key, required this.ui, this.padding = EdgeInsets.zero});

  final bsky_moderation.ModerationUI ui;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final badges = moderationBadgesForUi(ui);
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    Widget chipFor(ModerationBadgeDescriptor descriptor) {
      final isAlert = descriptor.tone == ModerationBadgeTone.alert;
      final background = isAlert
          ? colorScheme.errorContainer.withValues(alpha: 0.7)
          : colorScheme.secondaryContainer.withValues(alpha: 0.85);
      final foreground = isAlert ? colorScheme.onErrorContainer : colorScheme.onSecondaryContainer;

      return Tooltip(
        message: descriptor.description,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: foreground.withValues(alpha: 0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isAlert ? Icons.warning_amber_rounded : Icons.info_outline, size: 14, color: foreground),
              const SizedBox(width: 6),
              Text(
                descriptor.label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: foreground, fontWeight: FontWeight.w700, letterSpacing: 0.2),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Wrap(spacing: 8, runSpacing: 8, children: [for (final badge in badges) chipFor(badge)]),
    );
  }
}
