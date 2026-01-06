import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lazurite/src/core/domain/content_label.dart';

/// A widget that displays a content warning overlay for labeled content.
///
/// When [labels] contain labels that require warning (e.g., `!warn`, `porn`),
/// the child content is blurred and hidden behind an overlay.
/// Users can tap to reveal the content.
///
/// For labels with [LabelBehavior.hide] (e.g., `!takedown`), the content
/// remains hidden with no reveal option.
class ContentWarning extends StatefulWidget {
  const ContentWarning({required this.labels, required this.child, super.key});

  /// The labels applied to this content.
  final List<ContentLabel> labels;

  /// The content to potentially hide behind a warning.
  final Widget child;

  @override
  State<ContentWarning> createState() => _ContentWarningState();
}

class _ContentWarningState extends State<ContentWarning> {
  bool _revealed = false;

  /// Determines the most restrictive behavior from all labels.
  LabelBehavior get _behavior {
    var mostRestrictive = LabelBehavior.inform;
    for (final label in widget.labels) {
      if (label.isNegation) continue;

      final behavior = label.behavior;
      if (behavior == LabelBehavior.hide) {
        return LabelBehavior.hide;
      }
      if (behavior == LabelBehavior.alert && mostRestrictive != LabelBehavior.hide) {
        mostRestrictive = LabelBehavior.alert;
      }
      if (behavior == LabelBehavior.warn &&
          mostRestrictive != LabelBehavior.hide &&
          mostRestrictive != LabelBehavior.alert) {
        mostRestrictive = LabelBehavior.warn;
      }
      if (behavior == LabelBehavior.blur && mostRestrictive == LabelBehavior.inform) {
        mostRestrictive = LabelBehavior.blur;
      }
    }
    return mostRestrictive;
  }

  /// Gets all non-negated labels for display.
  List<ContentLabel> get _activeLabels => widget.labels.where((l) => !l.isNegation).toList();

  bool get _shouldShowOverlay {
    final behavior = _behavior;
    return behavior == LabelBehavior.warn ||
        behavior == LabelBehavior.blur ||
        behavior == LabelBehavior.hide ||
        behavior == LabelBehavior.alert;
  }

  bool get _canReveal => _behavior != LabelBehavior.hide;

  void _handleReveal() {
    if (_canReveal) {
      setState(() => _revealed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowOverlay || _revealed) {
      final showChips = _activeLabels.isNotEmpty && (_revealed || !_shouldShowOverlay);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showChips) ...[_LabelChips(labels: _activeLabels), const SizedBox(height: 8)],
          widget.child,
        ],
      );
    }

    return _ContentWarningOverlay(
      behavior: _behavior,
      labels: _activeLabels,
      canReveal: _canReveal,
      onReveal: _handleReveal,
      child: widget.child,
    );
  }
}

class _ContentWarningOverlay extends StatelessWidget {
  const _ContentWarningOverlay({
    required this.behavior,
    required this.labels,
    required this.canReveal,
    required this.onReveal,
    required this.child,
  });

  final LabelBehavior behavior;
  final List<ContentLabel> labels;
  final bool canReveal;
  final VoidCallback onReveal;
  final Widget child;

  String get _warningText {
    if (behavior == LabelBehavior.hide) {
      return 'Content hidden';
    }
    if (labels.isEmpty) {
      return 'Content warning';
    }
    final types = labels.map((l) => l.displayValue).toSet().join(', ');
    return 'Content warning: $types';
  }

  IconData get _icon {
    return switch (behavior) {
      LabelBehavior.hide => Icons.visibility_off,
      LabelBehavior.alert => Icons.warning_amber,
      LabelBehavior.warn => Icons.warning_amber_outlined,
      LabelBehavior.blur => Icons.blur_on,
      LabelBehavior.inform => Icons.info_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.3), BlendMode.darken),
              child: IgnorePointer(child: child),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
              child: InkWell(
                onTap: canReveal ? onReveal : null,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icon,
                        size: 32,
                        color: behavior == LabelBehavior.alert
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _warningText,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (canReveal) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: onReveal,
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('Show content'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ],
                      if (!canReveal) ...[
                        const SizedBox(height: 8),
                        Text(
                          'This content cannot be shown',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays label chips for labeled content.
class _LabelChips extends StatelessWidget {
  const _LabelChips({required this.labels});

  final List<ContentLabel> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: labels.map((label) {
        final isAlert = label.behavior == LabelBehavior.alert;
        final isSystem = label.isSystemLabel;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isAlert
                ? theme.colorScheme.errorContainer
                : isSystem
                ? theme.colorScheme.tertiaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSystem) ...[
                Icon(
                  Icons.shield_outlined,
                  size: 12,
                  color: isAlert
                      ? theme.colorScheme.onErrorContainer
                      : theme.colorScheme.onTertiaryContainer,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label.displayValue,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isAlert
                      ? theme.colorScheme.onErrorContainer
                      : isSystem
                      ? theme.colorScheme.onTertiaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Standalone label chips widget for use outside ContentWarning.
class LabelChips extends StatelessWidget {
  const LabelChips({required this.labels, super.key});

  final List<ContentLabel> labels;

  @override
  Widget build(BuildContext context) {
    if (labels.isEmpty) return const SizedBox.shrink();

    final activeLabels = labels.where((l) => !l.isNegation).toList();
    if (activeLabels.isEmpty) return const SizedBox.shrink();

    return _LabelChips(labels: activeLabels);
  }
}
