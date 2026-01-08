import 'package:flutter/material.dart';

/// Animated pill that surfaces the remaining character count for the composer.
class CharacterCountMeter extends StatelessWidget {
  const CharacterCountMeter({
    required this.currentCount,
    required this.maxCount,
    this.warningThreshold = 20,
    super.key,
  });

  /// Current number of grapheme clusters in the composer.
  final int currentCount;

  /// Maximum characters permitted before requiring a split.
  final int maxCount;

  /// Threshold (from max) where warning styling kicks in.
  final int warningThreshold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final remaining = maxCount - currentCount;
    final isOverLimit = remaining < 0;
    final isNearLimit = remaining <= warningThreshold && remaining >= 0;
    final progress = (currentCount / maxCount).clamp(0.0, 1.0);

    final accentColor = isOverLimit
        ? colorScheme.error
        : isNearLimit
        ? colorScheme.tertiary
        : colorScheme.primary;

    final backgroundColor = isOverLimit
        ? colorScheme.errorContainer
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.8);

    return Semantics(
      label: 'Characters remaining',
      value: '$remaining',
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isOverLimit ? 1 : progress),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        builder: (context, animatedProgress, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    value: animatedProgress,
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(accentColor),
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$remaining',
                  style: theme.textTheme.titleSmall?.copyWith(color: accentColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
