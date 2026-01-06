import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
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

                if (searchState.results.isEmpty && searchState.isLoading) {
                  return const LoadingView();
                }

                final feeds = searchState.filteredResults;
                if (feeds.isEmpty) {
                  if (searchState.isLoading) {
                    return const Center(child: Text('No matching feeds found.'));
                  }
                  return const Center(child: Text('No feeds found.'));
                }

                return ListView.separated(
                  itemCount: feeds.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final feedData = feeds[index];
                    final creatorData = feedData['creator'] as Map<String, dynamic>?;

                    final uri = feedData['uri'];
                    if (uri is! String || uri.isEmpty) {
                      // Skip feeds with invalid URIs
                      return const SizedBox.shrink();
                    }

                    return _buildFeedListTile(
                      context,
                      ref,
                      _FeedListItemData(
                        displayName: feedData['displayName'] as String? ?? 'Unknown Feed',
                        description: feedData['description'] as String? ?? '',
                        avatar: feedData['avatar'] as String?,
                        creatorHandle: creatorData?['handle'] as String? ?? 'unknown',
                        likeCount: feedData['likeCount'] as int? ?? 0,
                        uri: uri,
                      ),
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

  Widget _buildFeedListTile(BuildContext context, WidgetRef ref, _FeedListItemData feedData) =>
      ListTile(
        leading: CircleAvatar(
          backgroundImage: feedData.avatar != null ? NetworkImage(feedData.avatar!) : null,
          child: feedData.avatar == null ? const Icon(Icons.rss_feed) : null,
        ),
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
            builder: (context) => FeedPreviewModal(
              feedUri: feedData.uri,
              displayName: feedData.displayName,
              avatar: feedData.avatar,
              description: feedData.description,
              creatorHandle: feedData.creatorHandle,
            ),
          );
        },
      );
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

  final String displayName;
  final String description;
  final String? avatar;
  final String creatorHandle;
  final int likeCount;
  final String uri;
}
