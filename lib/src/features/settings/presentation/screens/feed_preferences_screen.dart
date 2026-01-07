import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings_providers.dart';
import '../../domain/bluesky_preferences.dart';
import '../widgets/settings_section.dart';

/// Feed and thread preferences screen.
///
/// Allows users to configure feed view settings (hide replies, reposts, quotes) and thread view
/// settings (sort order, prioritize followed users).
/// Changes are persisted locally and synced to the user's Bluesky account.
class FeedPreferencesScreen extends ConsumerWidget {
  const FeedPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedPrefAsync = ref.watch(feedViewPrefProvider);
    final threadPrefAsync = ref.watch(threadViewPrefProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed Preferences')),
      body: feedPrefAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (feedPref) => threadPrefAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (threadPref) => _buildContent(context, ref, feedPref, threadPref),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    FeedViewPref feedPref,
    ThreadViewPref threadPref,
  ) {
    return ListView(
      children: [
        _buildFeedViewSection(context, ref, feedPref),
        const Divider(),
        _buildThreadViewSection(context, ref, threadPref),
      ],
    );
  }

  Widget _buildFeedViewSection(BuildContext context, WidgetRef ref, FeedViewPref pref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSection(title: 'Feed View'),
        SwitchListTile(
          title: const Text('Hide Replies'),
          subtitle: const Text('Hide all reply posts from your feed'),
          value: pref.hideReplies,
          onChanged: (value) => _updateFeedPref(
            ref,
            FeedViewPref(
              hideReplies: value,
              hideRepliesByUnfollowed: pref.hideRepliesByUnfollowed,
              hideRepliesByLikeCount: pref.hideRepliesByLikeCount,
              hideReposts: pref.hideReposts,
              hideQuotePosts: pref.hideQuotePosts,
              feed: pref.feed,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Hide Replies by Unfollowed'),
          subtitle: const Text('Hide replies from accounts you don\'t follow'),
          value: pref.hideRepliesByUnfollowed,
          onChanged: pref.hideReplies
              ? null
              : (value) => _updateFeedPref(
                  ref,
                  FeedViewPref(
                    hideReplies: pref.hideReplies,
                    hideRepliesByUnfollowed: value,
                    hideRepliesByLikeCount: pref.hideRepliesByLikeCount,
                    hideReposts: pref.hideReposts,
                    hideQuotePosts: pref.hideQuotePosts,
                    feed: pref.feed,
                  ),
                ),
        ),
        SwitchListTile(
          title: const Text('Hide Reposts'),
          subtitle: const Text('Hide reposted content from your feed'),
          value: pref.hideReposts,
          onChanged: (value) => _updateFeedPref(
            ref,
            FeedViewPref(
              hideReplies: pref.hideReplies,
              hideRepliesByUnfollowed: pref.hideRepliesByUnfollowed,
              hideRepliesByLikeCount: pref.hideRepliesByLikeCount,
              hideReposts: value,
              hideQuotePosts: pref.hideQuotePosts,
              feed: pref.feed,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Hide Quote Posts'),
          subtitle: const Text('Hide posts that quote other posts'),
          value: pref.hideQuotePosts,
          onChanged: (value) => _updateFeedPref(
            ref,
            FeedViewPref(
              hideReplies: pref.hideReplies,
              hideRepliesByUnfollowed: pref.hideRepliesByUnfollowed,
              hideRepliesByLikeCount: pref.hideRepliesByLikeCount,
              hideReposts: pref.hideReposts,
              hideQuotePosts: value,
              feed: pref.feed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThreadViewSection(BuildContext context, WidgetRef ref, ThreadViewPref pref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSection(title: 'Thread View'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Reply Sort Order', style: theme.textTheme.bodyLarge),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Choose how replies are sorted in thread views',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<ThreadSortOrder>(
            segments: const [
              ButtonSegment(
                value: ThreadSortOrder.oldest,
                label: Text('Oldest'),
                icon: Icon(Icons.arrow_upward, size: 18),
              ),
              ButtonSegment(
                value: ThreadSortOrder.newest,
                label: Text('Newest'),
                icon: Icon(Icons.arrow_downward, size: 18),
              ),
              ButtonSegment(
                value: ThreadSortOrder.mostLikes,
                label: Text('Likes'),
                icon: Icon(Icons.favorite_outline, size: 18),
              ),
            ],
            selected: {pref.sort},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                _updateThreadPref(
                  ref,
                  ThreadViewPref(
                    sort: selection.first,
                    prioritizeFollowedUsers: pref.prioritizeFollowedUsers,
                  ),
                );
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Prioritize Followed Users'),
          subtitle: const Text('Show replies from people you follow first'),
          value: pref.prioritizeFollowedUsers,
          onChanged: (value) => _updateThreadPref(
            ref,
            ThreadViewPref(sort: pref.sort, prioritizeFollowedUsers: value),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> _updateFeedPref(WidgetRef ref, FeedViewPref pref) async {
    final repo = ref.read(blueskyPreferencesRepositoryProvider);
    await repo.updateFeedViewPref(pref);
  }

  Future<void> _updateThreadPref(WidgetRef ref, ThreadViewPref pref) async {
    final repo = ref.read(blueskyPreferencesRepositoryProvider);
    await repo.updateThreadViewPref(pref);
  }
}
