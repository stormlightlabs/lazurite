import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget that displays an external link embed as a preview card.
///
/// Renders link preview cards with title, description, and optional thumbnail
/// for the `app.bsky.embed.external#view` embed type.
class EmbedExternal extends StatelessWidget {
  const EmbedExternal({required this.external, super.key});

  /// The external link data containing uri, title, description, and optional thumb.
  final Map<String, dynamic> external;

  String _extractDomain(String uri) {
    try {
      final parsedUri = Uri.parse(uri);
      return parsedUri.host;
    } catch (e) {
      return uri;
    }
  }

  Future<void> _openUrl(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = external['uri'] as String? ?? '';
    final title = external['title'] as String? ?? '';
    final description = external['description'] as String? ?? '';
    final thumb = external['thumb'] as String?;
    final domain = _extractDomain(uri);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: uri.isNotEmpty ? () => _openUrl(uri) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (thumb != null && thumb.isNotEmpty)
              AspectRatio(
                aspectRatio: 1.91 / 1, // Standard OG image ratio
                child: Image.network(
                  thumb,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.link, size: 48, color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.link, size: 14, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          domain,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
