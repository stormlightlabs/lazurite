import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/embed/external.dart';
import 'package:bluesky_poptart/app/bsky/embed/images.dart';
import 'package:bluesky_poptart/app/bsky/embed/record.dart';
import 'package:bluesky_poptart/app/bsky/embed/record_with_media.dart';
import 'package:bluesky_poptart/app/bsky/embed/video.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:bluesky_poptart/app/bsky/graph/defs.dart' as bsky_graph;
import 'package:bluesky_poptart/app/bsky/labeler/defs.dart' as bsky_labeler;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/core/l10n/l10n.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/presentation/widgets/facet_text.dart';
import 'package:lazurite/features/feed/presentation/widgets/post_text_styles.dart';
import 'package:lazurite/shared/presentation/widgets/actor_name_widget.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:lazurite/shared/utils/parse_utils.dart';

typedef PostImagesEmbedBuilder =
    Widget Function(BuildContext context, List<EmbedImagesViewImage> images, {required String heroNamespace});
typedef PostExternalEmbedBuilder = Widget Function(BuildContext context, EmbedExternalViewExternal external);
typedef PostVideoEmbedBuilder = Widget Function(BuildContext context, EmbedVideoView video);
typedef PostUnknownEmbedBuilder = Widget Function(BuildContext context);

enum PostRecordEmbedKind { post, notFound, blocked, detached, generator, list, labeler, starterPack, unknown }

extension PostRecordEmbedUnionKind on UEmbedRecordViewRecord {
  PostRecordEmbedKind get postRecordEmbedKind {
    if (isEmbedRecordViewRecord) return PostRecordEmbedKind.post;
    if (isEmbedRecordViewNotFound) return PostRecordEmbedKind.notFound;
    if (isEmbedRecordViewBlocked) return PostRecordEmbedKind.blocked;
    if (isEmbedRecordViewDetached) return PostRecordEmbedKind.detached;
    if (isGeneratorView) return PostRecordEmbedKind.generator;
    if (isListView) return PostRecordEmbedKind.list;
    if (isLabelerView) return PostRecordEmbedKind.labeler;
    if (isStarterPackViewBasic) return PostRecordEmbedKind.starterPack;
    return PostRecordEmbedKind.unknown;
  }
}

class PostRecordEmbed extends StatelessWidget {
  const PostRecordEmbed({
    super.key,
    required this.recordView,
    required this.heroNamespace,
    required this.quoteDepth,
    required this.maxQuoteDepth,
    required this.compact,
    required this.buildImagesEmbed,
    required this.buildExternalEmbed,
    required this.buildVideoEmbed,
    required this.buildUnknownEmbed,
  });

  final EmbedRecordView recordView;
  final String heroNamespace;
  final int quoteDepth;
  final int maxQuoteDepth;
  final bool compact;
  final PostImagesEmbedBuilder buildImagesEmbed;
  final PostExternalEmbedBuilder buildExternalEmbed;
  final PostVideoEmbedBuilder buildVideoEmbed;
  final PostUnknownEmbedBuilder buildUnknownEmbed;

  @override
  Widget build(BuildContext context) {
    final record = recordView.record;

    return switch (record.postRecordEmbedKind) {
      PostRecordEmbedKind.post => _buildQuotedPost(context, record.embedRecordViewRecord!),
      PostRecordEmbedKind.notFound => _buildUnavailableQuote(context, context.l10n.messageQuotedPostNotFound),
      PostRecordEmbedKind.blocked => _buildUnavailableQuote(context, context.l10n.messageQuotedPostBlocked),
      PostRecordEmbedKind.detached => _buildUnavailableQuote(context, context.l10n.messageQuotedPostUnavailable),
      PostRecordEmbedKind.generator => _buildGeneratorRecord(context, record.generatorView!),
      PostRecordEmbedKind.list => _buildListRecord(context, record.listView!),
      PostRecordEmbedKind.labeler => _buildLabelerRecord(context, record.labelerView!),
      PostRecordEmbedKind.starterPack => _buildStarterPackRecord(context, record.starterPackViewBasic!),
      PostRecordEmbedKind.unknown => _buildUnknownRecord(context),
    };
  }

  Widget _buildQuotedPost(BuildContext context, EmbedRecordViewRecord quoted) {
    final quotedRecord = tryParseRecord(quoted.value);
    final nestedHeroNamespace = '$heroNamespace/quote:${quoted.uri}';
    final nestedEmbed = quoteDepth >= maxQuoteDepth
        ? null
        : _buildQuotedEmbeds(
            context,
            quoted.embeds,
            heroNamespace: '$nestedHeroNamespace/embeds',
            quoteDepth: quoteDepth + 1,
          );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: context.colorScheme.surfaceContainerLow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          GoRouter.maybeOf(context)?.push('/post?uri=${Uri.encodeComponent(quoted.uri.toString())}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileAvatar(
                    size: 28,
                    imageUrl: quoted.author.avatar,
                    fallbackText: quoted.author.displayName ?? quoted.author.handle,
                    shape: BoxShape.rectangle,
                    border: Border.all(color: context.colorScheme.outlineVariant),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ActorNameWidget(
                      displayName: quoted.author.displayName,
                      handle: quoted.author.handle,
                      displayNameStyle: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.colorScheme.onSurface,
                      ),
                      handleStyle: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                      uppercaseHandle: false,
                    ),
                  ),
                ],
              ),
              if (quotedRecord != null && quotedRecord.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                FacetText(
                  text: quotedRecord.text,
                  facets: quotedRecord.facets,
                  style: feedPostBodyTextStyle(context, compact: compact, nested: true),
                  maxLines: compact ? 6 : null,
                  overflow: compact ? TextOverflow.ellipsis : TextOverflow.visible,
                ),
              ],
              if (nestedEmbed != null) ...[const SizedBox(height: 8), nestedEmbed],
              if (quoteDepth == maxQuoteDepth && _hasQuotedRecordEmbed(quoted.embeds)) ...[
                const SizedBox(height: 8),
                _buildShallowQuote(context, _nestedQuotedAuthor(quoted.embeds) ?? quoted.author),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratorRecord(BuildContext context, GeneratorView generator) => PostRecordResourceCard(
    icon: Icons.dynamic_feed_outlined,
    avatarUrl: generator.avatar,
    fallbackText: generator.displayName,
    label: context.l10n.labelFeed,
    title: generator.displayName,
    subtitle: _byline(generator.creator.displayName, generator.creator.handle),
    description: generator.description,
    metadata: generator.likeCount == null ? null : '${formatCount(generator.likeCount!)} likes',
    compact: compact,
    onTap: () => GoRouter.maybeOf(context)?.push('/feed?uri=${Uri.encodeComponent(generator.uri.toString())}'),
  );

  Widget _buildListRecord(BuildContext context, bsky_graph.ListView list) {
    final isMod = list.purpose.knownValue == bsky_graph.KnownListPurpose.appBskyGraphDefsModlist;
    return PostRecordResourceCard(
      icon: isMod ? Icons.shield_outlined : Icons.list_alt_outlined,
      avatarUrl: list.avatar,
      fallbackText: list.name,
      label: isMod ? context.l10n.labelModerationShort : context.l10n.labelList,
      title: list.name,
      subtitle: _byline(list.creator.displayName, list.creator.handle),
      description: list.description,
      metadata: list.listItemCount == null ? null : '${formatCount(list.listItemCount!)} members',
      compact: compact,
      onTap: () => GoRouter.maybeOf(context)?.push('/list?uri=${Uri.encodeComponent(list.uri.toString())}'),
    );
  }

  Widget _buildLabelerRecord(BuildContext context, bsky_labeler.LabelerView labeler) => PostRecordResourceCard(
    icon: Icons.verified_user_outlined,
    avatarUrl: labeler.creator.avatar,
    fallbackText: labeler.creator.displayName ?? labeler.creator.handle,
    label: context.l10n.labelLabeler,
    title: labeler.creator.displayName ?? labeler.creator.handle,
    subtitle: '@${labeler.creator.handle}',
    metadata: labeler.likeCount == null ? null : '${formatCount(labeler.likeCount!)} likes',
    compact: compact,
    onTap: () =>
        GoRouter.maybeOf(context)?.push('/settings/moderation/detail?did=${Uri.encodeComponent(labeler.creator.did)}'),
  );

  Widget _buildStarterPackRecord(BuildContext context, bsky_graph.StarterPackViewBasic pack) {
    final name = (pack.record['name'] as String?)?.trim();
    final description = (pack.record['description'] as String?)?.trim();
    final title = name == null || name.isEmpty ? context.l10n.labelStarterPack : name;
    return PostRecordResourceCard(
      icon: Icons.group_add_outlined,
      fallbackText: title,
      label: context.l10n.labelStarterPack,
      title: title,
      subtitle: _byline(pack.creator.displayName, pack.creator.handle),
      description: description,
      metadata: pack.listItemCount == null ? null : '${formatCount(pack.listItemCount!)} members',
      compact: compact,
      onTap: () => GoRouter.maybeOf(context)?.push('/starter-pack?uri=${Uri.encodeComponent(pack.uri.toString())}'),
    );
  }

  Widget _buildUnknownRecord(BuildContext context) => PostRecordResourceCard(
    icon: Icons.article_outlined,
    fallbackText: context.l10n.labelUnknown,
    label: context.l10n.labelUnknown,
    title: context.l10n.messageQuotedPostUnavailable,
    compact: compact,
  );

  Widget _buildShallowQuote(BuildContext context, ProfileViewBasic author) => Container(
    width: double.infinity,
    padding: EdgeInsets.all(compact ? 8 : 10),
    decoration: BoxDecoration(
      border: Border.all(color: context.colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(10),
      color: context.colorScheme.surfaceContainerLow,
    ),
    child: Row(
      children: [
        ProfileAvatar(
          size: compact ? 20 : 24,
          imageUrl: author.avatar,
          fallbackText: author.displayName ?? author.handle,
          shape: BoxShape.rectangle,
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
        SizedBox(width: compact ? 6 : 8),
        Expanded(
          child: Text(
            '${author.displayName ?? author.handle} @${author.handle} ...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    ),
  );

  Widget _buildUnavailableQuote(BuildContext context, String label) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: context.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(12)),
    child: Text(label, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
  );

  Widget? _buildQuotedEmbeds(
    BuildContext context,
    List<UEmbedRecordViewRecordEmbeds>? embeds, {
    required String heroNamespace,
    required int quoteDepth,
  }) {
    if (embeds == null || embeds.isEmpty) return null;

    final embed = embeds.first;

    if (embed.isEmbedImagesView) {
      return buildImagesEmbed(context, embed.embedImagesView!.images, heroNamespace: '$heroNamespace/images');
    }
    if (embed.isEmbedExternalView) {
      return buildExternalEmbed(context, embed.embedExternalView!.external);
    }
    if (embed.isEmbedVideoView) {
      return buildVideoEmbed(context, embed.embedVideoView!);
    }
    if (embed.isEmbedRecordView) {
      return PostRecordEmbed(
        recordView: embed.embedRecordView!,
        heroNamespace: '$heroNamespace/record',
        quoteDepth: quoteDepth,
        maxQuoteDepth: maxQuoteDepth,
        compact: compact,
        buildImagesEmbed: buildImagesEmbed,
        buildExternalEmbed: buildExternalEmbed,
        buildVideoEmbed: buildVideoEmbed,
        buildUnknownEmbed: buildUnknownEmbed,
      );
    }
    if (embed.isEmbedRecordWithMediaView) {
      final recordWithMedia = embed.embedRecordWithMediaView!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRecordWithMediaMedia(context, recordWithMedia.media, heroNamespace: '$heroNamespace/rwm-media'),
          const SizedBox(height: 8),
          PostRecordEmbed(
            recordView: recordWithMedia.record,
            heroNamespace: '$heroNamespace/rwm-record',
            quoteDepth: quoteDepth,
            maxQuoteDepth: maxQuoteDepth,
            compact: compact,
            buildImagesEmbed: buildImagesEmbed,
            buildExternalEmbed: buildExternalEmbed,
            buildVideoEmbed: buildVideoEmbed,
            buildUnknownEmbed: buildUnknownEmbed,
          ),
        ],
      );
    }
    if (embed.isUnknown) {
      return buildUnknownEmbed(context);
    }

    return null;
  }

  Widget _buildRecordWithMediaMedia(
    BuildContext context,
    UEmbedRecordWithMediaViewMedia media, {
    required String heroNamespace,
  }) {
    if (media.isEmbedImagesView) {
      return buildImagesEmbed(context, media.embedImagesView!.images, heroNamespace: '$heroNamespace/images');
    }
    if (media.isEmbedExternalView) {
      return buildExternalEmbed(context, media.embedExternalView!.external);
    }
    if (media.isEmbedVideoView) {
      return buildVideoEmbed(context, media.embedVideoView!);
    }
    return buildUnknownEmbed(context);
  }

  bool _hasQuotedRecordEmbed(List<UEmbedRecordViewRecordEmbeds>? embeds) {
    if (embeds == null || embeds.isEmpty) return false;
    final embed = embeds.first;
    return embed.isEmbedRecordView || embed.isEmbedRecordWithMediaView;
  }

  ProfileViewBasic? _nestedQuotedAuthor(List<UEmbedRecordViewRecordEmbeds>? embeds) {
    if (embeds == null || embeds.isEmpty) return null;
    final embed = embeds.first;
    final recordView = embed.isEmbedRecordView
        ? embed.embedRecordView
        : embed.isEmbedRecordWithMediaView
        ? embed.embedRecordWithMediaView?.record
        : null;
    final record = recordView?.record;
    return record?.isEmbedRecordViewRecord == true ? record!.embedRecordViewRecord!.author : null;
  }

  String _byline(String? displayName, String handle) {
    final name = displayName?.trim();
    return name == null || name.isEmpty ? '@$handle' : 'by $name @$handle';
  }
}

class PostRecordResourceCard extends StatelessWidget {
  const PostRecordResourceCard({
    super.key,
    required this.icon,
    required this.fallbackText,
    required this.label,
    required this.title,
    required this.compact,
    this.avatarUrl,
    this.subtitle,
    this.description,
    this.metadata,
    this.onTap,
  });

  final IconData icon;
  final String? avatarUrl;
  final String fallbackText;
  final String label;
  final String title;
  final String? subtitle;
  final String? description;
  final String? metadata;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final descriptionText = description?.trim();
    final metadataText = metadata?.trim();
    final subtitleText = subtitle?.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        color: context.colorScheme.surfaceContainerLow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileAvatar(
                size: compact ? 32 : 40,
                imageUrl: avatarUrl,
                fallbackText: fallbackText,
                fallbackBuilder: (_) =>
                    Icon(icon, color: context.colorScheme.onSurfaceVariant, size: compact ? 18 : 22),
                shape: BoxShape.rectangle,
                border: Border.all(color: context.colorScheme.outlineVariant),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: context.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitleText != null && subtitleText.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                      ),
                    ],
                    if (!compact && descriptionText != null && descriptionText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        descriptionText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurface),
                      ),
                    ],
                    if (metadataText != null && metadataText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        metadataText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, size: 20, color: context.colorScheme.onSurfaceVariant),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
