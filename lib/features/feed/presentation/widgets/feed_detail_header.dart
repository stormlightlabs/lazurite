import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

class FeedDetailHeader extends StatelessWidget {
  const FeedDetailHeader({super.key, required this.generator, required this.loadedPostCount});

  final GeneratorView generator;
  final int loadedPostCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final creator = generator.creator;
    final description = generator.description?.trim() ?? '';

    return Container(
      key: const ValueKey('feed_detail_header'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(
            size: 64,
            imageUrl: generator.avatar,
            fallbackText: generator.displayName,
            shape: BoxShape.rectangle,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  generator.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  'by ${creator.displayName?.trim().isNotEmpty == true ? creator.displayName : creator.handle}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(description, maxLines: 4, overflow: TextOverflow.ellipsis, style: context.textTheme.bodyMedium),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _HeaderCount(label: 'likes', count: generator.likeCount ?? 0),
                    _HeaderCount(label: 'loaded', count: loadedPostCount),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCount extends StatelessWidget {
  const _HeaderCount({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${formatCount(count)} $label',
      style: context.textTheme.labelMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
