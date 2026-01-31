import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/widgets.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/widgets/feed_preview_modal.dart';

class FeedDiscoveryScreen extends ConsumerWidget {
  const FeedDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(feedSearchProvider);
    final notifier = ref.read(feedSearchProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Feeds')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Search feeds...',
              leading: const Icon(Icons.search),
              onChanged: notifier.setQuery,
              trailing: [
                if (searchState.isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                MenuAnchor(
                  builder: (context, controller, child) => ActionChip(
                    avatar: const Icon(Icons.sort, size: 16),
                    label: Text(
                      searchState.sortBy == FeedSortOption.popularity ? 'Popularity' : 'Name',
                    ),
                    onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                  ),
                  menuChildren: [
                    MenuItemButton(
                      child: const Text('Popularity'),
                      onPressed: () => notifier.setSortOption(FeedSortOption.popularity),
                    ),
                    MenuItemButton(
                      child: const Text('Name'),
                      onPressed: () => notifier.setSortOption(FeedSortOption.name),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Filter results...',
                        prefixIcon: Icon(Icons.filter_list, size: 16),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: notifier.setLocalFilter,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Builder(
              builder: (context) {
                if (searchState.error != null) {
                  return ErrorView(
                    title: 'Failed to discover feeds',
                    message: searchState.error!,
                    onRetry: notifier.refresh,
                  );
                }

                if (searchState.isLoading && searchState.results.isEmpty) {
                  return const LoadingView(message: 'Searching feeds...');
                }

                final feeds = searchState.filteredResults;
                if (feeds.isEmpty) {
                  if (searchState.isLoading) {
                    return const LoadingView(message: 'Searching feeds...');
                  }

                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No feeds found',
                    subtitle: searchState.localFilter.isNotEmpty
                        ? 'No results match your local filter.'
                        : (searchState.query.isNotEmpty
                              ? 'No results found for "${searchState.query}".'
                              : 'No popular feeds found at the moment.'),
                  );
                }

                return ListView.separated(
                  itemCount: feeds.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final feedData = feeds[index];

                    final uri = feedData['uri'];
                    if (uri is! String || uri.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return _buildFeedListTile(
                      context,
                      ref,
                      _FeedListItemData.fromMap(feedData, uri),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedListTile(BuildContext context, WidgetRef ref, _FeedListItemData feedData) {
    return ListTile(
      leading: Avatar(imageUrl: feedData.avatar, fallbackIcon: Icons.rss_feed, radius: 20),
      title: Text(feedData.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${feedData.creatorHandle} • ${feedData.likeCount} likes',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (feedData.description.isNotEmpty)
            Text(feedData.description, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.bookmark_add_outlined),
        onPressed: () {
          ref.read(feedMutationProvider.notifier).saveFeed(feedData.uri);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Saved ${feedData.displayName}')));
        },
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildFeedPreviewModal(feedData),
        );
      },
    );
  }

  Widget _buildFeedPreviewModal(_FeedListItemData feedData) {
    return FeedPreviewModal(
      feedUri: feedData.uri,
      displayName: feedData.displayName,
      avatar: feedData.avatar,
      description: feedData.description,
      creatorHandle: feedData.creatorHandle,
    );
  }
}

class _FeedListItemData {
  _FeedListItemData({
    required this.displayName,
    required this.description,
    required this.avatar,
    required this.creatorHandle,
    required this.likeCount,
    required this.uri,
  });

  factory _FeedListItemData.fromMap(Map<String, dynamic> map, String uri) {
    final creatorData = map['creator'] as Map<String, dynamic>?;
    return _FeedListItemData(
      displayName: map['displayName'] as String? ?? 'Unknown Feed',
      description: map['description'] as String? ?? '',
      avatar: map['avatar'] as String?,
      creatorHandle: creatorData?['handle'] as String? ?? 'unknown',
      likeCount: map['likeCount'] as int? ?? 0,
      uri: uri,
    );
  }

  final String displayName;
  final String description;
  final String? avatar;
  final String creatorHandle;
  final int likeCount;
  final String uri;
}
