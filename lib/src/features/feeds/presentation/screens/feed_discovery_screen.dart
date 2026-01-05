import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';

class FeedDiscoveryScreen extends ConsumerStatefulWidget {
  const FeedDiscoveryScreen({super.key});

  @override
  ConsumerState<FeedDiscoveryScreen> createState() => _FeedDiscoveryScreenState();
}

class _FeedDiscoveryScreenState extends ConsumerState<FeedDiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(discoverFeedsProvider.notifier).discover();
    });
  }

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(discoverFeedsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Discover Feeds')),
      body: discoveryState.when(
        data: (feeds) {
          if (feeds.isEmpty) {
            return const Center(child: Text('No trending feeds found.'));
          }
          return ListView.separated(
            itemCount: feeds.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final feedData = feeds[index];
              final displayName = feedData['displayName'] as String? ?? 'Unknown Feed';
              final description = feedData['description'] as String? ?? '';
              final avatar = feedData['avatar'] as String?;
              final uri = feedData['uri'] as String;
              final creator = feedData['creator'] as Map<String, dynamic>?;
              final creatorHandle = creator?['handle'] as String? ?? 'unknown';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null ? const Icon(Icons.rss_feed) : null,
                ),
                title: Text(displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@$creatorHandle', style: Theme.of(context).textTheme.bodySmall),
                    if (description.isNotEmpty)
                      Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  onPressed: () {
                    ref.read(feedMutationProvider.notifier).saveFeed(uri);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Saved $displayName')));
                  },
                ),
                onTap: () {
                  // TODO: Preview feed
                  // ref.read(activeFeedProvider.notifier).switchFeed(uri);
                  // Navigator.pop(context); // Optional: go back to home
                },
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (err, stack) => ErrorView(
          title: 'Failed to discover feeds',
          message: err.toString(),
          onRetry: () => ref.read(discoverFeedsProvider.notifier).discover(),
        ),
      ),
    );
  }
}
