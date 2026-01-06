import 'package:flutter/material.dart';
import 'package:lazurite/src/core/domain/content_label.dart';

/// Displays label chips for profile-level labels.
///
/// Shows account labels with appropriate styling for system labels (! prefix)
/// vs descriptive labels. Supports both [ContentLabel] objects and raw JSON maps.
class ProfileLabels extends StatelessWidget {
  const ProfileLabels({this.labels, this.rawLabels, super.key});

  /// Parsed ContentLabel objects.
  final List<ContentLabel>? labels;

  /// Raw label JSON maps (for backwards compatibility).
  final List<Map<String, dynamic>>? rawLabels;

  @override
  Widget build(BuildContext context) {
    final labelList = labels ?? _parseRawLabels();

    if (labelList.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: labelList.where((l) => !l.isNegation).map((label) {
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

  List<ContentLabel> _parseRawLabels() {
    if (rawLabels == null || rawLabels!.isEmpty) {
      return [];
    }

    return rawLabels!
        .where((json) => json.containsKey('val') && json.containsKey('src'))
        .map((json) {
          try {
            return ContentLabel(
              src: json['src'] as String? ?? '',
              uri: json['uri'] as String? ?? '',
              val: json['val'] as String? ?? '',
              cts: DateTime.tryParse(json['cts'] as String? ?? '') ?? DateTime.now(),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<ContentLabel>()
        .toList();
  }
}
