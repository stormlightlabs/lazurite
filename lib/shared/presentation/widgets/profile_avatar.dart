import 'package:lazurite/features/moderation/domain/moderation_models.dart' as bsky_moderation;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/cache/lazurite_image_cache.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.size,
    required this.fallbackText,
    this.imageUrl,
    this.moderationUi,
    this.shape = BoxShape.circle,
    this.borderRadius,
    this.border,
    this.placeholderTextStyle,
    this.fallbackBuilder,
    this.backgroundColor,
  });

  final double size;
  final String fallbackText;
  final String? imageUrl;
  final bsky_moderation.ModerationUI? moderationUi;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Border? border;
  final TextStyle? placeholderTextStyle;
  final WidgetBuilder? fallbackBuilder;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final shouldMask = moderationUi?.blur ?? false;
    final containerColor = backgroundColor ?? colorScheme.surfaceContainerHighest;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: containerColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? borderRadius : null,
        border: border,
      ),
      clipBehavior: Clip.antiAlias,
      child: shouldMask
          ? Icon(Icons.shield_outlined, color: colorScheme.onSurfaceVariant, size: size * 0.44)
          : imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              cacheManager: LazuriteImageCacheManager.instance,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _buildFallback(context, containerColor),
            )
          : _buildFallback(context, containerColor),
    );
  }

  Widget _buildFallback(BuildContext context, Color backgroundColor) {
    final resolvedFallback = fallbackBuilder?.call(context);
    final textStyle = placeholderTextStyle ?? context.textTheme.labelLarge;

    return ColoredBox(
      color: backgroundColor,
      child: Center(child: resolvedFallback ?? Text(formatInitials(fallbackText), style: textStyle)),
    );
  }
}
