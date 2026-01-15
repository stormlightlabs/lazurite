import 'package:flutter/material.dart';
import 'package:lazurite/src/features/composer/domain/draft.dart';

/// A bottom sheet for configuring threading settings.
///
/// Allows users to set:
/// - Reply restrictions (thread gate type)
/// - Quote post toggle
class ThreadingSettingsSheet extends StatefulWidget {
  const ThreadingSettingsSheet({
    super.key,
    required this.threadGateType,
    required this.quoteDisabled,
    required this.onThreadGateChanged,
    required this.onQuoteDisabledChanged,
  });

  /// Current thread gate type (null = no restriction).
  final ThreadGateType? threadGateType;

  /// Current quote disabled state.
  final bool quoteDisabled;

  /// Callback when thread gate type changes.
  final ValueChanged<ThreadGateType?> onThreadGateChanged;

  /// Callback when quote disabled changes.
  final ValueChanged<bool> onQuoteDisabledChanged;

  @override
  State<ThreadingSettingsSheet> createState() => _ThreadingSettingsSheetState();
}

class _ThreadingSettingsSheetState extends State<ThreadingSettingsSheet> {
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
            const Text(
              'Post Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Who can reply',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<ThreadGateType?>(
              groupValue: widget.threadGateType,
              onChanged: (value) => widget.onThreadGateChanged(value),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<ThreadGateType?>(
                    title: Text('Everyone'),
                    subtitle: Text('Anyone can reply to this post'),
                    value: null,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  RadioListTile<ThreadGateType?>(
                    title: Text('People you mention'),
                    subtitle: Text('Only users you @mention can reply'),
                    value: ThreadGateType.mention,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  RadioListTile<ThreadGateType?>(
                    title: Text('People you follow'),
                    subtitle: Text('Only users you follow can reply'),
                    value: ThreadGateType.following,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  RadioListTile<ThreadGateType?>(
                    title: Text('Mentioned & Following'),
                    subtitle: Text('Users you mention or follow can reply'),
                    value: ThreadGateType.mentionAndFollowing,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Quote posts',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Disable quote posts'),
              subtitle: const Text('Prevent others from quoting this post'),
              value: widget.quoteDisabled,
              onChanged: widget.onQuoteDisabledChanged,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done')),
          ],
        ),
      ),
    );
  }
}
