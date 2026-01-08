import 'package:flutter/material.dart';
import 'package:lazurite/src/core/animations/animation_utils.dart';

/// Publish button with loading and disabled states.
class PublishButton extends StatelessWidget {
  const PublishButton({
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.label = 'Post',
    super.key,
  });

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is disabled (e.g., empty draft).
  final bool isDisabled;

  /// Button label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return FilledButton(
        onPressed: null,
        style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
        ),
      );
    }

    return ScaleButton(
      enabled: !isDisabled,
      child: FilledButton(
        onPressed: isDisabled ? null : onPressed,
        style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
        child: Text(label),
      ),
    );
  }
}
