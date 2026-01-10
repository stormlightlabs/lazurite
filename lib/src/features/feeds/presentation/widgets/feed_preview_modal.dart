import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/core/widgets/error_view.dart';
import 'package:lazurite/src/core/widgets/loading_view.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_notifier.dart';
import 'package:lazurite/src/features/feeds/application/feed_providers.dart';
import 'package:lazurite/src/features/feeds/presentation/screens/widgets/feed_post_card.dart';

class FeedPreviewModal extends ConsumerStatefulWidget {
  const FeedPreviewModal({
    required this.feedUri,
    required this.displayName,
    this.avatar,
    this.description,
    this.creatorHandle,
    super.key,
  });

  final String feedUri;
  final String displayName;
  final String? avatar;
  final String? description;
  final String? creatorHandle;

  @override
  ConsumerState<FeedPreviewModal> createState() => _FeedPreviewModalState();
}

class _FeedPreviewModalState extends ConsumerState<FeedPreviewModal> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedContentProvider(widget.feedUri).notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedContentState = ref.watch(feedContentProvider(widget.feedUri));
    final savedFeeds = ref.watch(allFeedsProvider).asData?.value ?? [];
    final isSaved = savedFeeds.any((f) => f.uri == widget.feedUri);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: widget.avatar != null
                              ? NetworkImage(widget.avatar!)
                              : null,
                          child: widget.avatar == null ? const Icon(Icons.rss_feed) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.displayName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (widget.creatorHandle != null)
                                Text(
                                  '@${widget.creatorHandle}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (isSaved)
                          FilledButton.icon(
                            onPressed: () {
                              ref.read(feedMutationProvider.notifier).removeFeed(widget.feedUri);
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Saved'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          )
                        else
                          FilledButton.icon(
                            onPressed: () {
                              ref.read(feedMutationProvider.notifier).saveFeed(widget.feedUri);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Save'),
                          ),
                      ],
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 12),
                      Text(widget.description!),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: feedContentState.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const Center(child: Text('No posts found'));
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) => FeedPostCard(item: items[index]),
                    );
                  },
                  loading: () => const LoadingView(),
                  error: (err, stack) => ErrorView(
                    title: 'Failed to load preview',
                    message: errorMessage(err),
                    onRetry: () {
                      ref.read(feedContentProvider(widget.feedUri).notifier).refresh();
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
