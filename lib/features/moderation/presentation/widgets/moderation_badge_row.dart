import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

class ModerationBadgeRow extends StatelessWidget {
  const ModerationBadgeRow({super.key, required this.ui, this.padding = EdgeInsets.zero, this.labelResolver});

  final bsky_moderation.ModerationUI ui;
  final EdgeInsetsGeometry padding;
  final ModerationLabelResolver? labelResolver;

  @override
  Widget build(BuildContext context) {
    final moderationService = maybeModerationService(context);
    final locale = Localizations.localeOf(context);
    final effectiveResolver =
        labelResolver ??
        (moderationService == null
            ? null
            : ({required String identifier, String? labelerDid}) => moderationService.resolveLabelDisplayName(
                identifier: identifier,
                labelerDid: labelerDid,
                preferredLanguages: [locale.toLanguageTag(), locale.languageCode],
              ));

    final badges = moderationBadgesForUi(ui, labelResolver: effectiveResolver);
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = context.colorScheme;

    Widget chipFor(ModerationBadgeDescriptor descriptor, double maxWidth) {
      final isAlert = descriptor.tone == ModerationBadgeTone.alert;
      final background = isAlert
          ? colorScheme.errorContainer.withValues(alpha: 0.7)
          : colorScheme.secondaryContainer.withValues(alpha: 0.85);
      final foreground = isAlert ? colorScheme.onErrorContainer : colorScheme.onSecondaryContainer;

      return Tooltip(
        message: descriptor.description,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
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
                Flexible(
                  child: Text(
                    descriptor.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
          return Wrap(spacing: 8, runSpacing: 8, children: [for (final badge in badges) chipFor(badge, maxWidth)]);
        },
      ),
    );
  }
}
