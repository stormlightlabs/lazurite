import 'package:flutter/material.dart';

/// Follow/unfollow button with loading state.
class FollowButton extends StatelessWidget {
  const FollowButton({
    required this.isFollowing,
    this.isLoading = false,
    this.isDisabled = false,
    this.onPressed,
    super.key,
  });

  /// Whether the current user is following this profile.
  final bool isFollowing;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether the button is disabled (e.g., read-only mode).
  final bool isDisabled;

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return SizedBox(
        width: 100,
        height: 36,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
          ),
        ),
      );
    }

    if (isFollowing) {
      return OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(100, 36),
          side: BorderSide(color: colorScheme.outline),
        ),
        child: const Text('Following'),
      );
    }

    return FilledButton(
      onPressed: isDisabled ? null : onPressed,
      style: FilledButton.styleFrom(minimumSize: const Size(100, 36)),
      child: const Text('Follow'),
    );
  }
}
