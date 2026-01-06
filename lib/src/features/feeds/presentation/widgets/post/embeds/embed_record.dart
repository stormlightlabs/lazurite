import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'embed_images.dart';

/// Widget that displays a record embed as a card.
///
/// Handles all record embed types from `app.bsky.embed.record#view`:
/// - Quoted posts (viewRecord)
/// - Not found state (viewNotFound)
/// - Blocked state (viewBlocked)
/// - Detached/deleted state (viewDetached)
/// - Feed generators (generatorView)
/// - Lists (listView)
/// - Starter packs (starterPackViewBasic)
class EmbedRecord extends StatelessWidget {
  const EmbedRecord({required this.record, super.key});

  /// The record data from the embed.
  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final type = record[r'$type'] as String?;

    if (type == 'app.bsky.embed.record#viewRecord') {
      return _QuotedPostCard(record: record);
    }

    if (type == 'app.bsky.embed.record#viewNotFound') {
      return _ErrorStateCard(
        icon: Icons.search_off,
        message: 'Post not found',
        uri: record['uri'] as String?,
      );
    }

    if (type == 'app.bsky.embed.record#viewBlocked') {
      return _ErrorStateCard(
        icon: Icons.block,
        message: 'Blocked content',
        uri: record['uri'] as String?,
      );
    }

    if (type == 'app.bsky.embed.record#viewDetached') {
      return _ErrorStateCard(
        icon: Icons.link_off,
        message: 'Content unavailable',
        uri: record['uri'] as String?,
      );
    }

    if (type == 'app.bsky.feed.defs#generatorView') {
      return _FeedGeneratorCard(record: record);
    }

    if (type == 'app.bsky.graph.defs#listView') {
      return _ListCard(record: record);
    }

    if (type == 'app.bsky.graph.defs#starterPackViewBasic') {
      return _StarterPackCard(record: record);
    }

    return const SizedBox.shrink();
  }
}

/// Renders a quoted post as an embedded card.
class _QuotedPostCard extends StatelessWidget {
  const _QuotedPostCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final author = record['author'] as Map<String, dynamic>?;
    final value = record['value'] as Map<String, dynamic>?;
    final embeds = record['embeds'] as List<dynamic>?;
    final uri = record['uri'] as String?;

    final displayName = author?['displayName'] as String? ?? '';
    final handle = author?['handle'] as String? ?? '';
    final avatar = author?['avatar'] as String?;
    final authorDid = author?['did'] as String? ?? '';

    final text = value?['text'] as String? ?? '';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: uri != null
          ? () {
              final encodedUri = Uri.encodeComponent(uri);
              GoRouter.of(context).push('/home/t/$encodedUri');
            }
          : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (avatar != null && avatar.isNotEmpty)
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage(avatar),
                    onBackgroundImageError: (e, s) {},
                  )
                else
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.person, size: 14, color: colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        if (displayName.isNotEmpty)
                          TextSpan(
                            text: displayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        TextSpan(
                          text: displayName.isNotEmpty ? ' @$handle' : '@$handle',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                text,
                style: theme.textTheme.bodyMedium,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (embeds != null && embeds.isNotEmpty) ...[
              const SizedBox(height: 8),
              _renderNestedEmbed(embeds.first as Map<String, dynamic>, authorDid),
            ],
          ],
        ),
      ),
    );
  }

  Widget _renderNestedEmbed(Map<String, dynamic> embed, String authorDid) {
    final type = embed[r'$type'] as String?;

    if (type == 'app.bsky.embed.images#view') {
      final images = embed['images'] as List<dynamic>? ?? [];
      return EmbedImages(images: images);
    }

    if (type == 'app.bsky.embed.external#view') {
      final external = embed['external'] as Map<String, dynamic>?;
      final title = external?['title'] as String? ?? 'Link';
      return Row(
        children: [
          const Icon(Icons.link, size: 16),
          const SizedBox(width: 4),
          Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// Renders an error state card (not found, blocked, detached).
class _ErrorStateCard extends StatelessWidget {
  const _ErrorStateCard({required this.icon, required this.message, this.uri});

  final IconData icon;
  final String message;
  final String? uri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceContainerLow,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Renders a feed generator embed.
class _FeedGeneratorCard extends StatelessWidget {
  const _FeedGeneratorCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final displayName = record['displayName'] as String? ?? 'Feed';
    final description = record['description'] as String?;
    final avatar = record['avatar'] as String?;
    final creator = record['creator'] as Map<String, dynamic>?;
    final creatorHandle = creator?['handle'] as String? ?? '';
    final likeCount = record['likeCount'] as int?;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (avatar != null && avatar.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                avatar,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _feedPlaceholder(colorScheme),
              ),
            )
          else
            _feedPlaceholder(colorScheme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rss_feed, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (creatorHandle.isNotEmpty)
                  Text(
                    'by @$creatorHandle',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (likeCount != null && likeCount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        '$likeCount',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.rss_feed, color: colorScheme.onSurfaceVariant),
    );
  }
}

/// Renders a list embed.
class _ListCard extends StatelessWidget {
  const _ListCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final name = record['name'] as String? ?? 'List';
    final description = record['description'] as String?;
    final avatar = record['avatar'] as String?;
    final purpose = record['purpose'] as String?;
    final creator = record['creator'] as Map<String, dynamic>?;
    final creatorHandle = creator?['handle'] as String? ?? '';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String purposeLabel = 'List';
    IconData purposeIcon = Icons.list;
    if (purpose?.contains('modlist') == true) {
      purposeLabel = 'Moderation List';
      purposeIcon = Icons.shield;
    } else if (purpose?.contains('curatelist') == true) {
      purposeLabel = 'Curated List';
      purposeIcon = Icons.star;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (avatar != null && avatar.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                avatar,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _listPlaceholder(colorScheme, purposeIcon),
              ),
            )
          else
            _listPlaceholder(colorScheme, purposeIcon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(purposeIcon, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  purposeLabel + (creatorHandle.isNotEmpty ? ' by @$creatorHandle' : ''),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listPlaceholder(ColorScheme colorScheme, IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: colorScheme.onSurfaceVariant),
    );
  }
}

/// Renders a starter pack embed.
class _StarterPackCard extends StatelessWidget {
  const _StarterPackCard({required this.record});

  final Map<String, dynamic> record;

  @override
  Widget build(BuildContext context) {
    final name = record['name'] as String? ?? 'Starter Pack';
    final creator = record['creator'] as Map<String, dynamic>?;
    final creatorHandle = creator?['handle'] as String? ?? '';
    final listItemCount = record['listItemCount'] as int?;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.rocket_launch, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.rocket_launch, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Starter Pack${creatorHandle.isNotEmpty ? ' by @$creatorHandle' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (listItemCount != null && listItemCount > 0)
                  Text(
                    '$listItemCount people',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
