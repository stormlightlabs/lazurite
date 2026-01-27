import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lazurite/src/core/utils/error_message.dart';
import 'package:lazurite/src/core/widgets/widgets.dart';
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
    final savedFeeds = ref.watch(allFeedsProvider).asData?.value ?? [];
    final isSaved = savedFeeds.any((f) => f.uri == widget.feedUri);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
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
                    _buildUserInfoRow(
                      widget.avatar,
                      widget.creatorHandle,
                      widget.displayName,
                      widget.feedUri,
                      isSaved,
                      textTheme,
                      colorScheme,
                    ),
                    if (widget.description != null) ...[
                      const SizedBox(height: 12),
                      Text(widget.description!),
                    ],
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildFeedContent(widget.feedUri, scrollController),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserInfoRow(
    String? avatar,
    String? creatorHandle,
    String displayName,
    String feedUri,
    bool isSaved,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Avatar(imageUrl: avatar, fallbackIcon: Icons.rss_feed, radius: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: textTheme.titleLarge),
              if (creatorHandle != null)
                Text(
                  '@$creatorHandle',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        if (isSaved)
          FilledButton.icon(
            onPressed: () {
              ref.read(feedMutationProvider.notifier).removeFeed(feedUri);
            },
            icon: const Icon(Icons.check),
            label: const Text('Saved'),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.surfaceContainerHighest,
              foregroundColor: colorScheme.onSurfaceVariant,
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
    );
  }

  Widget _buildFeedContent(String feedUri, ScrollController scrollController) {
    final feedContentState = ref.watch(feedContentProvider(feedUri));
    return Expanded(
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
    );
  }
}
