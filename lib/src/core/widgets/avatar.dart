import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A circular avatar widget for displaying user profile images with caching.
class Avatar extends StatelessWidget {
  const Avatar({
    required this.imageUrl,
    this.radius = 20,
    this.fallbackIcon = Icons.person,
    this.heroTag,
    super.key,
  });

  /// The URL of the profile image to display.
  final String? imageUrl;

  /// The radius of the avatar circle.
  final double radius;

  /// The icon to display when [imageUrl] is null or fails to load.
  final IconData fallbackIcon;

  /// Optional hero tag for navigation transitions.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(borderRadius: BorderRadius.circular(radius), child: _buildImage(theme))
          : _buildFallback(theme),
    );

    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    return avatar;
  }

  Widget _buildImage(ThemeData theme) {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildFallback(theme),
      errorWidget: (context, url, error) => _buildFallback(theme),
    );
  }

  Widget _buildFallback(ThemeData theme) {
    return Icon(fallbackIcon, size: radius, color: theme.colorScheme.onSurface.withAlpha(153));
  }
}
