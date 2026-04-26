import 'dart:ui';
import 'package:lazurite/core/theme/theme_extensions.dart';

import 'package:bluesky/moderation.dart' as bsky_moderation;
import 'package:flutter/material.dart';
import 'package:lazurite/features/moderation/presentation/moderation_ui_helpers.dart';

class ModeratedBlurOverlay extends StatefulWidget {
  const ModeratedBlurOverlay({
    super.key,
    required this.ui,
    required this.child,
    this.borderRadius,
    this.fallbackLabel = 'Sensitive content',
    this.fillWidth = true,
  });

  final bsky_moderation.ModerationUI ui;
  final Widget child;
  final BorderRadius? borderRadius;
  final String fallbackLabel;
  final bool fillWidth;

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
    final canReveal = !widget.ui.noOverride;

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
                        moderationOverlayTitle(widget.ui, fallback: widget.fallbackLabel),
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        canReveal
                            ? 'Hidden by your moderation settings. You can reveal it for this view.'
                            : 'Hidden by your moderation settings and cannot be revealed here.',
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.35),
                      ),
                      if (canReveal) ...[
                        const SizedBox(height: 14),
                        FilledButton.tonal(
                          onPressed: () => setState(() => _revealed = true),
                          child: const Text('Show content'),
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
