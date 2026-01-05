import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lazurite/src/app/routes.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';

class FeedSelectorTab extends ConsumerWidget {
  const FeedSelectorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedFeedsAsync = ref.watch(pinnedFeedsProvider);
    final activeFeedUri = ref.watch(activeFeedProvider);

    return pinnedFeedsAsync.when(
      data: (feeds) {
        return SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: feeds.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == feeds.length) {
                return IconButton(
                  icon: const Icon(Icons.tune),
                  tooltip: 'Manage Feeds',
                  onPressed: () {
                    context.push(AppRoutes.feeds);
                  },
                );
              }

              final feed = feeds[index];
              final isActive = feed.uri == activeFeedUri;

              return ChoiceChip(
                showCheckmark: false,
                label: Text(feed.displayName),
                avatar: feed.avatar != null
                    ? CircleAvatar(backgroundImage: NetworkImage(feed.avatar!))
                    : null,
                selected: isActive,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(activeFeedProvider.notifier).switchFeed(feed.uri);
                  }
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
