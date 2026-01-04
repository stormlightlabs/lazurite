import 'package:flutter/material.dart';

/// A circular avatar widget for displaying user profile images.
///
/// Displays the user's profile image from [imageUrl] with graceful fallback
/// to an icon when the image is unavailable or null.
class Avatar extends StatelessWidget {
  const Avatar({
    required this.imageUrl,
    this.radius = 20,
    this.fallbackIcon = Icons.person,
    this.heroTag,
    super.key,
  });

  /// The URL of the profile image to display.
  ///
  /// If null, a fallback icon is shown instead.
  final String? imageUrl;

  /// The radius of the avatar circle.
  ///
  /// Defaults to 20.
  final double radius;

  /// The icon to display when [imageUrl] is null or fails to load.
  ///
  /// Defaults to [Icons.person].
  final IconData fallbackIcon;

  /// Optional hero tag for navigation transitions.
  ///
  /// If provided, the avatar is wrapped in a [Hero] widget.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      foregroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      onForegroundImageError: imageUrl != null ? (_, _) {} : null,
      child: Icon(fallbackIcon, size: radius, color: theme.colorScheme.onSurface.withAlpha(153)),
    );

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    return avatar;
  }
}
