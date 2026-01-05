import 'package:flutter/material.dart';

/// Multi-line text field for composing posts with character count.
class ComposerTextField extends StatelessWidget {
  const ComposerTextField({
    required this.controller,
    this.maxLength = 300,
    this.hintText = "What's happening?",
    this.onChanged,
    super.key,
  });

  /// Text editing controller for the field.
  final TextEditingController controller;

  /// Maximum character limit (default 300).
  final int maxLength;

  /// Hint text displayed when empty.
  final String hintText;

  /// Callback fired when text changes.
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            maxLines: null,
            minLines: 4,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha(128)),
              border: InputBorder.none,
              counterText: '',
            ),
            style: theme.textTheme.bodyLarge,
            onChanged: onChanged,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final remaining = maxLength - value.text.length;
                final isOverLimit = remaining < 0;
                final isNearLimit = remaining <= 20 && remaining >= 0;

                return Text(
                  '$remaining',
                  textAlign: TextAlign.end,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOverLimit
                        ? colorScheme.error
                        : isNearLimit
                        ? colorScheme.tertiary
                        : colorScheme.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
