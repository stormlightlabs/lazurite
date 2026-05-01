import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/router/in_app_link_resolver.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalLinkPreviewCard extends StatelessWidget {
  const ExternalLinkPreviewCard({
    super.key,
    required this.uri,
    required this.title,
    required this.description,
    this.thumbUrl,
    this.compact = false,
    this.onRemove,
    this.cacheManager,
  });

  final String uri;
  final String title;
  final String description;
  final String? thumbUrl;
  final bool compact;
  final VoidCallback? onRemove;
  final BaseCacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => _openUri(context, uri),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerLow,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumbUrl != null && thumbUrl!.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: thumbUrl!,
                    cacheManager: cacheManager,
                    height: compact ? 140 : 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => const SizedBox.shrink(),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.trim().isEmpty ? _displayHost(uri) : title.trim(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          description.trim(),
                          maxLines: compact ? 3 : null,
                          overflow: compact ? TextOverflow.ellipsis : TextOverflow.visible,
                          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        _displayHost(uri),
                        style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (onRemove != null)
              Positioned(
                top: 8,
                right: 8,
                child: IconButton.filledTonal(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  iconSize: 18,
                  tooltip: 'Remove link preview',
                  style: IconButton.styleFrom(
                    backgroundColor: context.colorScheme.surface.withValues(alpha: 0.9),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String displayHost(String rawUri) => _displayHost(rawUri);
}

String _displayHost(String rawUri) {
  final parsed = Uri.tryParse(rawUri);
  final host = parsed?.host.trim();
  if (host == null || host.isEmpty) {
    return rawUri;
  }
  return host;
}

void _openUri(BuildContext context, String rawUri) {
  final inAppRoute = InAppLinkResolver.resolveRoute(rawUri);
  final router = GoRouter.maybeOf(context);
  if (inAppRoute != null && router != null) {
    router.push(inAppRoute);
    return;
  }

  final uri = Uri.tryParse(rawUri);
  if (uri == null) {
    return;
  }

  _launchExternal(uri);
}

Future<void> _launchExternal(Uri url) async {
  await launchUrl(url, mode: LaunchMode.externalApplication);
}
