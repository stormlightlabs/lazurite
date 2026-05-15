import 'dart:ui';

import 'package:lazurite/features/moderation/domain/moderation_models.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';

const _defaultModerationFallbackLabel = 'Sensitive content';

class ModeratedBlurOverlay extends StatefulWidget {
  const ModeratedBlurOverlay({
    super.key,
    required this.ui,
    required this.child,
    this.borderRadius,
    this.fallbackLabel = _defaultModerationFallbackLabel,
    this.fillWidth = true,
    this.labelResolver,
  });

  final bsky_moderation.ModerationUI ui;
  final Widget child;
  final BorderRadius? borderRadius;
  final String fallbackLabel;
  final bool fillWidth;
  final ModerationLabelResolver? labelResolver;

  @override
  State<ModeratedBlurOverlay> createState() => _ModeratedBlurOverlayState();
}

class _ModeratedBlurOverlayState extends State<ModeratedBlurOverlay> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.ui.blur || _revealed) {
      return widget.child;
    }

    final colorScheme = context.colorScheme;
    final l10n = context.l10n;
    final canReveal = !widget.ui.noOverride;
    final moderationService = maybeModerationService(context);
    final locale = Localizations.localeOf(context);
    final effectiveResolver =
        widget.labelResolver ??
        (moderationService == null
            ? null
            : ({required String identifier, String? labelerDid}) => moderationService.resolveLabelDisplayName(
                identifier: identifier,
                labelerDid: labelerDid,
                preferredLanguages: [locale.toLanguageTag(), locale.languageCode],
              ));

    Widget content = Stack(
      fit: StackFit.passthrough,
      children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(colorScheme.surface.withValues(alpha: 0.22), BlendMode.srcATop),
            child: widget.child,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.72),
              borderRadius: widget.borderRadius,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_off_outlined, color: colorScheme.onSurface, size: 24),
                      const SizedBox(height: 10),
                      Text(
                        moderationOverlayTitle(
                          widget.ui,
                          fallback: widget.fallbackLabel == _defaultModerationFallbackLabel
                              ? l10n.labelSensitiveContent
                              : widget.fallbackLabel,
                          labelResolver: effectiveResolver,
                          l10n: l10n,
                        ),
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        canReveal ? l10n.messageModeratedContentCanReveal : l10n.messageModeratedContentCannotReveal,
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.35),
                      ),
                      if (canReveal) ...[
                        const SizedBox(height: 14),
                        FilledButton.tonal(
                          onPressed: () => setState(() => _revealed = true),
                          child: Text(l10n.buttonShowContent),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    if (widget.borderRadius != null) {
      content = ClipRRect(borderRadius: widget.borderRadius!, child: content);
    }

    if (widget.fillWidth) {
      return SizedBox(width: double.infinity, child: content);
    }

    return content;
  }
}
