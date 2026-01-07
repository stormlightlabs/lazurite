import 'package:flutter/material.dart';

import '../../domain/bluesky_preferences.dart';

/// A selector widget for choosing content label visibility.
///
/// Displays a segmented button with options: Ignore, Show, Warn, Hide.
/// Used in the Content Moderation screen to configure visibility for each label type.
class LabelVisibilitySelector extends StatelessWidget {
  const LabelVisibilitySelector({required this.value, required this.onChanged, super.key});

  /// The current visibility setting.
  final LabelVisibility value;

  /// Called when the user selects a new visibility option.
  final ValueChanged<LabelVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<LabelVisibility>(
      segments: const [
        ButtonSegment(
          value: LabelVisibility.ignore,
          label: Text('Off'),
          tooltip: 'Do not filter or warn about this content',
        ),
        ButtonSegment(
          value: LabelVisibility.warn,
          label: Text('Warn'),
          tooltip: 'Show a warning before displaying this content',
        ),
        ButtonSegment(
          value: LabelVisibility.hide,
          label: Text('Hide'),
          tooltip: 'Completely hide this content from feeds',
        ),
      ],
      selected: {value},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onChanged(selection.first);
        }
      },
      showSelectedIcon: false,
    );
  }
}
