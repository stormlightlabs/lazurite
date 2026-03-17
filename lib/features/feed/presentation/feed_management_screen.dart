import 'package:atproto_core/atproto_core.dart';
import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_feed_defs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';

class FeedManagementScreen extends StatefulWidget {
  const FeedManagementScreen({super.key});

  @override
  State<FeedManagementScreen> createState() => _FeedManagementScreenState();
}

class _FeedManagementScreenState extends State<FeedManagementScreen> {
  List<GeneratorView>? _suggestedFeeds;
  bool _isLoadingSuggestions = false;
  bool _isReordering = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestedFeeds();
  }

  Future<void> _loadSuggestedFeeds() async {
    setState(() => _isLoadingSuggestions = true);

    try {
      final feedRepository = context.read<FeedRepository>();
      final feeds = await feedRepository.getSuggestedFeeds(limit: 10);
      setState(() {
        _suggestedFeeds = feeds;
        _isLoadingSuggestions = false;
      });
    } catch (e) {
      setState(() => _isLoadingSuggestions = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Feeds'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done'))],
      ),
      body: BlocConsumer<FeedPreferencesCubit, FeedPreferencesState>(
        listener: (context, state) {
          if (state.status == FeedPreferencesStatus.saveError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to sync: ${state.message}'),
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () => context.read<FeedPreferencesCubit>().clearError(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == FeedPreferencesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              _buildSectionHeader(
                context,
                'Pinned Feeds',
                showReorder: state.pinnedFeeds.length > 1 && !_isReordering,
                isReordering: _isReordering,
                onAction: () => setState(() => _isReordering = !_isReordering),
              ),
              if (_isReordering && state.pinnedFeeds.length > 1)
                _buildReorderablePinnedFeeds(context, state)
              else
                ...state.pinnedFeeds.map((feed) => _buildPinnedFeedItem(context, feed, state)),
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Saved Feeds'),
              if (state.unpinnedFeeds.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No saved feeds',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              else
                ...state.unpinnedFeeds.map((feed) => _buildSavedFeedItem(context, feed)),
              const SizedBox(height: 16),
              _buildSectionHeader(context, 'Discover Feeds', actionText: 'Refresh', onAction: _loadSuggestedFeeds),
              _buildDiscoverSection(context),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReorderablePinnedFeeds(BuildContext context, FeedPreferencesState state) {
    final pinnedFeeds = state.pinnedFeeds;

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: pinnedFeeds.length,
      onReorder: (oldIndex, newIndex) {
        context.read<FeedPreferencesCubit>().reorderPinnedFeeds(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final feed = pinnedFeeds[index];
        final isTimeline =
            feed.type is SavedFeedTypeKnownValue &&
            (feed.type as SavedFeedTypeKnownValue).data == KnownSavedFeedType.timeline;

        return ListTile(
          key: ValueKey(feed.id),
          leading: isTimeline ? _buildTimelineIcon(context) : _buildFeedIcon(context, feed.value),
          title: Text(isTimeline ? 'Following' : _getFeedDisplayName(feed.value)),
          subtitle: Text(isTimeline ? 'Timeline' : 'Custom Feed'),
          trailing: ReorderableDragStartListener(index: index, child: const Icon(Icons.drag_handle)),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? actionText,
    VoidCallback? onAction,
    bool showReorder = false,
    bool isReordering = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const Spacer(),
          if (showReorder) TextButton(onPressed: onAction, child: Text(isReordering ? 'Done' : 'Reorder')),
          if (actionText != null && !showReorder) TextButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }

  Widget _buildPinnedFeedItem(BuildContext context, SavedFeed feed, FeedPreferencesState state) {
    final isTimeline =
        feed.type is SavedFeedTypeKnownValue &&
        (feed.type as SavedFeedTypeKnownValue).data == KnownSavedFeedType.timeline;

    return ListTile(
      leading: isTimeline ? _buildTimelineIcon(context) : _buildFeedIcon(context, feed.value),
      title: Text(isTimeline ? 'Following' : _getFeedDisplayName(feed.value)),
      subtitle: Text(isTimeline ? 'Timeline' : 'Custom Feed'),
      trailing: IconButton(
        icon: const Icon(Icons.check_circle),
        color: Theme.of(context).colorScheme.primary,
        onPressed: () => context.read<FeedPreferencesCubit>().unpinFeed(feed.id),
      ),
    );
  }

  Widget _buildSavedFeedItem(BuildContext context, SavedFeed feed) {
    return ListTile(
      leading: _buildFeedIcon(context, feed.value),
      title: Text(_getFeedDisplayName(feed.value)),
      subtitle: const Text('Custom Feed'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.pin_end_outlined),
            onPressed: () => context.read<FeedPreferencesCubit>().pinFeed(feed.id),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
            onPressed: () => _confirmRemoveFeed(context, feed.id),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverSection(BuildContext context) {
    if (_isLoadingSuggestions) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_suggestedFeeds == null || _suggestedFeeds!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No suggested feeds available',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Column(children: _suggestedFeeds!.map((feed) => _buildDiscoverCard(context, feed)).toList());
  }

  Widget _buildDiscoverCard(BuildContext context, GeneratorView feed) {
    final prefsState = context.watch<FeedPreferencesCubit>().state;
    final isAdded = prefsState.feeds.any((f) => f.value == feed.uri.toString());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildGeneratorIcon(context, feed),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feed.displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'by ${feed.creator.displayName ?? feed.creator.handle}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (feed.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      feed.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (feed.likeCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${feed.likeCount} likes',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: isAdded
                  ? null
                  : () => context.read<FeedPreferencesCubit>().addFeed(
                      type: const SavedFeedType.knownValue(data: KnownSavedFeedType.feed),
                      value: feed.uri.toString(),
                      pinned: false,
                    ),
              child: Text(isAdded ? 'Added' : '+ Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineIcon(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0066FF), Color(0xFF0EA5E9)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.people, color: Colors.white),
    );
  }

  Widget _buildFeedIcon(BuildContext context, String feedUri) {
    final gradients = [
      const [Color(0xFFF59E0B), Color(0xFFFB923C)],
      const [Color(0xFF8B5CF6), Color(0xFFBE95FF)],
      const [Color(0xFF22C55E), Color(0xFF42BE65)],
      const [Color(0xFFEE5396), Color(0xFFFF7EB6)],
    ];
    final index = feedUri.hashCode % gradients.length;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradients[index]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.rss_feed, color: Colors.white),
    );
  }

  Widget _buildGeneratorIcon(BuildContext context, GeneratorView feed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF08BDBA), Color(0xFF3DDBD9)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: feed.avatar != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                feed.avatar!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(Icons.rss_feed, color: Colors.white),
              ),
            )
          : const Icon(Icons.rss_feed, color: Colors.white),
    );
  }

  String _getFeedDisplayName(String feedUri) {
    try {
      final uri = AtUri.parse(feedUri);
      return uri.rkey;
    } catch (_) {
      return feedUri.split('/').lastOrNull ?? feedUri;
    }
  }

  void _confirmRemoveFeed(BuildContext context, String feedId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Feed'),
        content: const Text('Are you sure you want to remove this feed from your saved feeds?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<FeedPreferencesCubit>().removeFeed(feedId);
              Navigator.of(context).pop();
            },
            child: Text('Remove', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
