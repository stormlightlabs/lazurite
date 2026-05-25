import 'package:bluesky_poptart/app/bsky/actor/defs.dart';
import 'package:bluesky_poptart/app/bsky/feed/defs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lazurite/core/cache/lazurite_image_cache.dart';
import 'package:lazurite/core/logging/app_logger.dart';
import 'package:lazurite/core/theme/theme_extensions.dart';
import 'package:lazurite/features/feed/cubit/feed_preferences_cubit.dart';
import 'package:lazurite/features/feed/data/feed_repository.dart';
import 'package:lazurite/features/settings/bloc/account_settings_cubit.dart';
import 'package:lazurite/features/settings/presentation/widgets/account_feed_display_preferences.dart';
import 'package:lazurite/shared/presentation/helpers/snackbar_helper.dart';
import 'package:lazurite/shared/presentation/widgets/confirmation_dialog.dart';
import 'package:lazurite/shared/presentation/widgets/empty_state.dart';
import 'package:lazurite/shared/presentation/widgets/loading_state.dart';
import 'package:lazurite/shared/utils/format_utils.dart';

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
    context.read<FeedPreferencesCubit>().loadPreferences(emitCachedFirst: false);
    _loadSuggestedFeeds();
  }

  Future<void> _loadSuggestedFeeds() async {
    setState(() => _isLoadingSuggestions = true);

    final feedRepository = context.read<FeedRepository>();
    try {
      final feeds = await feedRepository.getSuggestedFeeds(limit: 10);
      if (!mounted) {
        return;
      }
      setState(() {
        _suggestedFeeds = feeds;
        _isLoadingSuggestions = false;
      });
    } catch (error, stackTrace) {
      log.w('Failed to load suggested feeds', error: error, stackTrace: stackTrace);
      if (!mounted) {
        return;
      }
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
        listenWhen: (previous, current) =>
            current.status == FeedPreferencesStatus.saveError ||
            (current.status == FeedPreferencesStatus.loaded &&
                current.message != null &&
                current.message != previous.message),
        listener: (context, state) {
          if (state.status == FeedPreferencesStatus.saveError) {
            showAppSnackBar(
              context,
              'Failed to sync: ${state.message}',
              actionLabel: 'Dismiss',
              onAction: () => context.read<FeedPreferencesCubit>().clearError(),
            );
          } else if (state.status == FeedPreferencesStatus.loaded && state.message != null) {
            showAppSnackBar(context, state.message!);
          }
        },
        builder: (context, state) {
          if (state.status == FeedPreferencesStatus.loading) {
            return const LoadingState();
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
                const EmptyState(message: 'No saved feeds', icon: Icons.bookmark_border, padding: EdgeInsets.all(16))
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
      onReorderItem: (oldIndex, newIndex) {
        context.read<FeedPreferencesCubit>().reorderPinnedFeeds(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final feed = pinnedFeeds[index];
        final isTimeline = state.isTimeline(feed);
        final generator = state.generatorFor(feed);

        return ListTile(
          key: ValueKey(feed.id),
          leading: isTimeline
              ? _buildTimelineIcon(context)
              : (generator != null ? _buildGeneratorIcon(context, generator) : _buildFeedIcon(context, feed.value)),
          title: Text(state.displayNameFor(feed)),
          subtitle: Text(state.subtitleFor(feed)),
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
            style: context.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          const Spacer(),
          if (showReorder) TextButton(onPressed: onAction, child: Text(isReordering ? 'Done' : 'Reorder')),
          if (actionText != null && !showReorder) TextButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }

  Widget _buildPinnedFeedItem(BuildContext context, SavedFeed feed, FeedPreferencesState state) {
    final isTimeline = state.isTimeline(feed);
    final generator = state.generatorFor(feed);

    return ListTile(
      leading: isTimeline
          ? _buildTimelineIcon(context)
          : (generator != null ? _buildGeneratorIcon(context, generator) : _buildFeedIcon(context, feed.value)),
      title: Text(state.displayNameFor(feed)),
      subtitle: Text(state.subtitleFor(feed)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTimeline)
            IconButton(
              tooltip: 'Feed display',
              icon: const Icon(Icons.tune_outlined),
              onPressed: () => _showFeedDisplaySettings(context, feed, state),
            ),
          IconButton(
            tooltip: 'Unpin feed',
            icon: const Icon(Icons.check_circle),
            color: context.colorScheme.primary,
            onPressed: () => context.read<FeedPreferencesCubit>().unpinFeed(feed.id),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedFeedItem(BuildContext context, SavedFeed feed) {
    final state = context.watch<FeedPreferencesCubit>().state;
    final description = state.descriptionFor(feed);
    final generator = state.generatorFor(feed);

    return ListTile(
      leading: generator != null ? _buildGeneratorIcon(context, generator) : _buildFeedIcon(context, feed.value),
      title: Text(state.displayNameFor(feed)),
      subtitle: Text(description ?? state.subtitleFor(feed)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Pin feed',
            icon: const Icon(Icons.pin_end_outlined),
            onPressed: () => context.read<FeedPreferencesCubit>().pinFeed(feed.id),
          ),
          IconButton(
            tooltip: 'Remove feed',
            icon: Icon(Icons.close, color: context.colorScheme.error),
            onPressed: () => _confirmRemoveFeed(context, feed.id),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedDisplaySettings(BuildContext context, SavedFeed feed, FeedPreferencesState state) {
    final feedRepository = context.read<FeedRepository>();
    final feedPreferenceId = state.isTimeline(feed) ? homeFeedPreferenceId : feed.value;
    final feedDisplayName = state.displayNameFor(feed);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => BlocProvider(
        create: (_) => AccountSettingsCubit(
          feedRepository: feedRepository,
          feed: feedPreferenceId,
          feedDisplayName: feedDisplayName,
        )..loadPreferences(),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                child: Row(
                  children: [
                    Text('Feed display', style: context.textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close',
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AccountFeedDisplayPreferences(
                  padding: const EdgeInsets.only(bottom: 24),
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoverSection(BuildContext context) {
    if (_isLoadingSuggestions) {
      return const LoadingState(padding: EdgeInsets.all(32));
    }

    if (_suggestedFeeds == null || _suggestedFeeds!.isEmpty) {
      return const EmptyState(
        message: 'No suggested feeds available',
        icon: Icons.travel_explore_outlined,
        padding: EdgeInsets.all(16),
      );
    }

    return Column(children: _suggestedFeeds!.map((feed) => _buildDiscoverCard(context, feed)).toList());
  }

  Widget _buildDiscoverCard(BuildContext context, GeneratorView feed) {
    final prefsState = context.watch<FeedPreferencesCubit>().state;
    final isAdded = prefsState.containsFeedValue(feed.uri.toString());

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
                    feedDisplayName(feed),
                    style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'by ${feed.creator.displayName ?? feed.creator.handle}',
                    style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
                  ),
                  if (feed.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      feed.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                  if (feed.likeCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${feed.likeCount} likes',
                      style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
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
    final avatarUrl = feed.avatar ?? feed.creator.avatar;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF08BDBA), Color(0xFF3DDBD9)]),
        borderRadius: BorderRadius.circular(10),
      ),
      child: avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: avatarUrl,
                cacheManager: LazuriteImageCacheManager.instance,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => const Icon(Icons.rss_feed, color: Colors.white),
              ),
            )
          : const Icon(Icons.rss_feed, color: Colors.white),
    );
  }

  Future<void> _confirmRemoveFeed(BuildContext context, String feedId) async {
    await showConfirmationDialog(
      context: context,
      title: const Text('Remove Feed'),
      content: const Text('Are you sure you want to remove this feed from your saved feeds?'),
      confirmLabel: 'Remove',
      confirmDestructive: true,
      onConfirmed: () => context.read<FeedPreferencesCubit>().removeFeed(feedId),
    );
  }
}
