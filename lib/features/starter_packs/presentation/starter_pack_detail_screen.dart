import 'package:atproto_core/atproto_core.dart' show AtUri;
import 'package:bluesky/app_bsky_graph_defs.dart' as bsky_graph;
import 'package:flutter/material.dart' hide ListView;
import 'package:flutter/material.dart' as material show ListView;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/features/starter_packs/bloc/starter_pack_bloc.dart';
import 'package:lazurite/features/starter_packs/data/starter_pack_repository.dart';

class StarterPackDetailScreen extends StatelessWidget {
  const StarterPackDetailScreen({super.key, required this.packUri});

  final AtUri packUri;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          StarterPackBloc(starterPackRepository: context.read<StarterPackRepository>())
            ..add(StarterPackRequested(starterPackUri: packUri)),
      child: const _StarterPackDetailView(),
    );
  }
}

class _StarterPackDetailView extends StatelessWidget {
  const _StarterPackDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StarterPackBloc, StarterPackState>(
      listenWhen: (prev, curr) =>
          (prev.followedCount == null && curr.followedCount != null) ||
          (prev.errorMessage != curr.errorMessage && curr.errorMessage != null && !curr.isLoading) ||
          curr.status == StarterPackStatus.deleted,
      listener: (context, state) {
        if (state.status == StarterPackStatus.deleted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/profile');
          }
          return;
        }

        if (state.followedCount != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Followed ${state.followedCount} member${state.followedCount == 1 ? '' : 's'}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!), behavior: SnackBarBehavior.floating));
        }
      },
      builder: (context, state) {
        final pack = state.starterPack;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: true,
                title: Text(pack != null ? ((pack.record['name'] as String?) ?? 'Starter Pack') : 'Starter Pack'),
                actions: [
                  if (state.isMutating)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                ],
              ),
              if (state.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (state.status == StarterPackStatus.error && pack == null)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? 'Failed to load starter pack'),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () => context.read<StarterPackBloc>().add(
                              StarterPackRequested(starterPackUri: state.packUri!),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (pack != null)
                SliverToBoxAdapter(
                  child: _StarterPackContent(pack: pack, state: state),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StarterPackContent extends StatelessWidget {
  const _StarterPackContent({required this.pack, required this.state});

  final bsky_graph.StarterPackView pack;
  final StarterPackState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final name = (pack.record['name'] as String?) ?? 'Starter Pack';
    final description = pack.record['description'] as String?;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/view?actor=${pack.creator.did}'),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: pack.creator.avatar != null ? NetworkImage(pack.creator.avatar!) : null,
                  child: pack.creator.avatar == null
                      ? Text(
                          (pack.creator.displayName?.isNotEmpty == true
                                  ? pack.creator.displayName!
                                  : pack.creator.handle)
                              .substring(0, 1)
                              .toUpperCase(),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.creator.displayName ?? pack.creator.handle,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '@${pack.creator.handle}',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(name, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          if (description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Text(description!, style: textTheme.bodyMedium),
          ],
          const SizedBox(height: 16),
          if (pack.joinedWeekCount != null || pack.joinedAllTimeCount != null) ...[
            Row(
              children: [
                if (pack.joinedWeekCount != null) ...[
                  _buildStatChip(context, pack.joinedWeekCount!, 'joined this week'),
                  const SizedBox(width: 12),
                ],
                if (pack.joinedAllTimeCount != null) _buildStatChip(context, pack.joinedAllTimeCount!, 'total joined'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          const Divider(),
          const SizedBox(height: 8),
          _buildMembersSection(context),
          if (pack.feeds?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _buildFeedsSection(context),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, int count, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(_formatCount(count), style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildMembersSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sample = pack.listItemsSample ?? const [];
    final refListUri = pack.list?.uri;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Members', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            if (refListUri != null) ...[
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/list?uri=${Uri.encodeComponent(refListUri.toString())}'),
                child: const Text('See all'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (sample.isEmpty)
          Text('No members', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))
        else
          SizedBox(
            height: 72,
            child: material.ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sample.length,
              itemBuilder: (context, index) {
                final member = sample[index];
                return GestureDetector(
                  onTap: () => context.push('/profile/view?actor=${member.subject.did}'),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: member.subject.avatar != null ? NetworkImage(member.subject.avatar!) : null,
                          child: member.subject.avatar == null
                              ? Text(
                                  (member.subject.displayName?.isNotEmpty == true
                                          ? member.subject.displayName!
                                          : member.subject.handle)
                                      .substring(0, 1)
                                      .toUpperCase(),
                                )
                              : null,
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 56,
                          child: Text(
                            member.subject.displayName ?? member.subject.handle,
                            style: textTheme.labelSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        if (refListUri != null)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isFollowingAll
                  ? null
                  : () => context.read<StarterPackBloc>().add(const FollowAllRequested()),
              icon: state.isFollowingAll
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.group_add_outlined),
              label: Text(state.isFollowingAll ? 'Following…' : 'Follow all'),
            ),
          ),
      ],
    );
  }

  Widget _buildFeedsSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final feeds = pack.feeds ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommended Feeds', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final feed in feeds.take(3))
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.surfaceContainerHighest,
              backgroundImage: feed.avatar != null ? NetworkImage(feed.avatar!) : null,
              child: feed.avatar == null ? const Icon(Icons.rss_feed) : null,
            ),
            title: Text(feed.displayName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: feed.description != null
                ? Text(feed.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : null,
          ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}
