import 'package:flutter/material.dart';

/// A bottom sheet for selecting content warning labels.
///
/// Allows users to self-label their content with content warnings.
class ContentWarningSheet extends StatefulWidget {
  const ContentWarningSheet({
    super.key,
    required this.selectedLabels,
    required this.onSelectionChanged,
  });

  /// Currently selected content warning labels.
  final List<String> selectedLabels;

  /// Callback when selection changes.
  final ValueChanged<List<String>> onSelectionChanged;

  @override
  State<ContentWarningSheet> createState() => _ContentWarningSheetState();
}

class _ContentWarningSheetState extends State<ContentWarningSheet> {
  void _toggleLabel(String label) {
    final newSelection = List<String>.from(widget.selectedLabels);
    if (newSelection.contains(label)) {
      newSelection.remove(label);
    } else {
      newSelection.add(label);
    }
    widget.onSelectionChanged(newSelection);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Content Warnings',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onSelectionChanged([]);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Add content warnings to help others understand what to expect.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ..._warningOptions.map((option) {
              final isSelected = widget.selectedLabels.contains(option.value);
              return CheckboxListTile(
                title: Text(option.label),
                subtitle: Text(option.description),
                value: isSelected,
                onChanged: (_) => _toggleLabel(option.value),
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
              );
            }),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}

class _WarningOption {
  const _WarningOption({required this.value, required this.label, required this.description});

  final String value;
  final String label;
  final String description;
}

/// Available content warning options.
const List<_WarningOption> _warningOptions = [
  _WarningOption(
    value: 'sexual',
    label: 'Sexual Content',
    description: 'Contains sexually suggestive or explicit content',
  ),
  _WarningOption(
    value: 'nudity',
    label: 'Nudity',
    description: 'Contains nude or partially nude figures',
  ),
  _WarningOption(
    value: 'porn',
    label: 'Pornography',
    description: 'Contains sexually explicit material',
  ),
  _WarningOption(
    value: 'graphic-media',
    label: 'Graphic Media',
    description: 'Contains graphic or violent imagery',
  ),
];
