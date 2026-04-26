import 'package:bluesky/app_bsky_graph_defs.dart';
import 'package:flutter/material.dart';
import 'package:lazurite/shared/presentation/widgets/profile_avatar.dart';
import 'package:lazurite/shared/utils/format_utils.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';

class StarterPackCard extends StatelessWidget {
  const StarterPackCard({super.key, required this.pack, this.onTap});

  final StarterPackViewBasic pack;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final name = (pack.record['name'] as String?) ?? 'Starter Pack';
    final memberCount = pack.listItemCount;
    final joinedWeek = pack.joinedWeekCount;
    final joinedAll = pack.joinedAllTimeCount;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ProfileAvatar(
                    size: 40,
                    fallbackText: name,
                    backgroundColor: colorScheme.primaryContainer,
                    fallbackBuilder: (_) => Icon(Icons.group_outlined, color: colorScheme.onPrimaryContainer, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'by @${pack.creator.handle}',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: [
                  if (memberCount != null) _buildStat(context, memberCount, 'members'),
                  if (joinedWeek != null) _buildStat(context, joinedWeek, 'joined this week'),
                  if (joinedAll != null) _buildStat(context, joinedAll, 'joined total'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, int count, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(formatCount(count), style: context.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        Text(label, style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
