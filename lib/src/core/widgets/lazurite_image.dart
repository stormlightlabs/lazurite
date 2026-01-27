import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../animations/animation_utils.dart';

/// A reusable image widget that handles caching and loading states.
///
/// Uses [CachedNetworkImage] for disk-based caching and provides
/// consistent placeholders and error widgets aligned with Lazurite's design.
class LazuriteImage extends StatelessWidget {
  const LazuriteImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.useHero = false,
    this.heroTag,
    super.key,
  });

  /// The URL of the image to display.
  final String imageUrl;

  /// Optional width of the image.
  final double? width;

  /// Optional height of the image.
  final double? height;

  /// How the image should be inscribed into the box.
  final BoxFit fit;

  /// Optional custom placeholder widget.
  final Widget? placeholder;

  /// Optional custom error widget.
  final Widget? errorWidget;

  /// Optional border radius for the image.
  final BorderRadius? borderRadius;

  /// Whether to wrap the image in a [Hero] widget.
  final bool useHero;

  /// Optional hero tag. Required if [useHero] is true.
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildError(context);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(context),
      errorWidget: (context, url, error) => errorWidget ?? _buildError(context),
      fadeInDuration: const Duration(milliseconds: 300),
      imageBuilder: (context, imageProvider) {
        Widget result = Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
        );

        if (useHero && heroTag != null) {
          result = Hero(tag: heroTag!, child: result);
        }

        return result;
      },
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: borderRadius,
      ),
      child: const Center(child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
    );
  }

  Widget _buildError(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: theme.colorScheme.onErrorContainer,
          size: 24,
        ),
      ),
    );
  }
}

/// A specialized [LazuriteImage] for user avatars.
class LazuriteAvatar extends StatelessWidget {
  const LazuriteAvatar({required this.imageUrl, this.radius = 20, this.onTap, super.key});

  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? LazuriteImage(
              imageUrl: imageUrl!,
              width: radius * 2,
              height: radius * 2,
              borderRadius: BorderRadius.circular(radius),
              errorWidget: Icon(
                Icons.person,
                size: radius,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )
          : Icon(Icons.person, size: radius, color: theme.colorScheme.onPrimaryContainer),
    );

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ScaleButton(child: avatar),
      );
    }

    return avatar;
  }
}
