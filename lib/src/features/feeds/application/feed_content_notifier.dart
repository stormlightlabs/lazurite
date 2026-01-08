import 'dart:convert';

import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/auth/application/auth_providers.dart';
import 'package:lazurite/src/features/auth/domain/auth_state.dart';
import 'package:lazurite/src/features/feeds/application/feed_content_providers.dart';
import 'package:lazurite/src/features/settings/application/muted_word_filter_provider.dart';
import 'package:lazurite/src/features/settings/application/settings_providers.dart';
import 'package:lazurite/src/features/settings/domain/bluesky_preferences.dart';
import 'package:lazurite/src/features/settings/domain/muted_word_filter_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/logger_provider.dart';
import '../../../infrastructure/db/daos/feed_content_dao.dart';
import '../infrastructure/feed_content_repository.dart';
import '../infrastructure/feed_repository.dart';

part 'feed_content_notifier.g.dart';

/// Notifier for managing feed content (posts from the active feed).
///
/// Watches the active feed and provides a stream of posts from that feed.
/// Applies user preference filters (muted words, hide replies/reposts/quotes).
/// Supports refresh, load more, and clear operations.
@riverpod
class FeedContentNotifier extends _$FeedContentNotifier {
  Logger get _logger => ref.read(loggerProvider('FeedContentNotifier'));
  bool get _isAuthenticated => ref.read(authProvider) is AuthStateAuthenticated;

  @override
  Stream<List<FeedPost>> build(String feedUri) {
    final repository = ref.watch(feedContentRepositoryProvider);
    final logger = ref.watch(loggerProvider('FeedContentNotifier'));
    final mutedWordFilter = ref.watch(mutedWordFilterServiceProvider);
    final feedViewPref = ref.watch(feedViewPrefProvider);

    final feedKey = _feedKeyFromUri(feedUri);
    logger.debug('Watching feed content stream', {'feedKey': feedKey, 'feedUri': feedUri});

    return repository.watchFeedContent(feedKey: feedKey).map((items) {
      final pref = feedViewPref.maybeWhen(
        data: (data) => data,
        orElse: () => FeedViewPref.defaultPref,
      );
      var filtered = _applyFeedViewFilters(items, pref);

      if (mutedWordFilter != null) {
        filtered = _applyMutedWordFilter(filtered, mutedWordFilter);
      }

      return filtered;
    });
  }

  /// Applies feed view preference filters to hide replies, reposts, and quote posts.
  List<FeedPost> _applyFeedViewFilters(List<FeedPost> items, FeedViewPref pref) {
    return items.where((item) {
      if (pref.hideReposts && item.reason != null) {
        try {
          final reasonJson = jsonDecode(item.reason!) as Map<String, dynamic>;
          if (reasonJson[r'$type']?.toString().contains('reason') == true) {
            return false;
          }
        } catch (_) {
          /* Ignore parse errors */
        }
      }

      if (pref.hideReplies) {
        try {
          final recordJson = jsonDecode(item.post.record) as Map<String, dynamic>;
          if (recordJson['reply'] != null) {
            return false;
          }
        } catch (_) {
          /* Ignore parse errors */
        }
      }

      if (pref.hideQuotePosts) {
        try {
          final recordJson = jsonDecode(item.post.record) as Map<String, dynamic>;
          final embedJson = recordJson['embed'] as Map<String, dynamic>?;
          if (embedJson != null && embedJson[r'$type']?.toString().contains('record') == true) {
            return false;
          }
        } catch (_) {
          /* Ignore parse errors */
        }
      }

      return true;
    }).toList();
  }

  /// Applies muted word filter to hide posts matching muted words.
  List<FeedPost> _applyMutedWordFilter(List<FeedPost> items, MutedWordFilterService filter) {
    return items.where((item) {
      final text = _extractText(item);
      final tags = _extractTags(item);
      final isFollowing = item.relationship?.following ?? false;
      return !filter.shouldMutePost(text: text, tags: tags, isFollowing: isFollowing);
    }).toList();
  }

  /// Extracts post text from the record JSON.
  String _extractText(FeedPost item) {
    try {
      final recordJson = jsonDecode(item.post.record) as Map<String, dynamic>;
      return recordJson['text'] as String? ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Extracts hashtags from the record JSON facets.
  List<String> _extractTags(FeedPost item) {
    try {
      final recordJson = jsonDecode(item.post.record) as Map<String, dynamic>;
      final facets = recordJson['facets'] as List<dynamic>?;
      if (facets == null) return [];

      final tags = <String>[];
      for (final facet in facets) {
        final features = (facet as Map<String, dynamic>)['features'] as List<dynamic>?;
        if (features == null) continue;

        for (final feature in features) {
          final featureMap = feature as Map<String, dynamic>;
          if (featureMap[r'$type'] == 'app.bsky.richtext.facet#tag') {
            final tag = featureMap['tag'] as String?;
            if (tag != null) tags.add(tag);
          }
        }
      }
      return tags;
    } catch (_) {
      return [];
    }
  }

  /// Derives a feedKey from a feed URI.
  ///
  /// Uses the internal home feed key for the home feed, otherwise uses the full URI.
  String _feedKeyFromUri(String feedUri) {
    if (feedUri == FeedRepository.kHomeFeedUri ||
        feedUri == FeedRepository.kFollowingFeedUri ||
        feedUri == FeedRepository.kTimelineFeedUri) {
      return FeedContentRepository.kInternalHomeFeedKey;
    }
    return feedUri;
  }

  String? _resolveRemoteFeedUri() {
    if (feedUri == FeedRepository.kHomeFeedUri ||
        feedUri == FeedRepository.kFollowingFeedUri ||
        feedUri == FeedRepository.kTimelineFeedUri) {
      return null;
    }
    return feedUri;
  }

  /// Refreshes the current feed content.
  ///
  /// Fetches the latest posts from the active feed and caches them locally.
  Future<void> refresh() async {
    final repository = ref.read(feedContentRepositoryProvider);

    final actualFeedUri = _resolveRemoteFeedUri();
    if (actualFeedUri == null && !_isAuthenticated) {
      _logger.debug('Skipping refresh for timeline feed while unauthenticated');
      return;
    }

    try {
      await repository.fetchAndCacheFeed(feedUri: actualFeedUri);
    } catch (error, stack) {
      _logger.error('Failed to refresh feed content', error, stack);
    }
  }

  /// Loads more posts for the current feed.
  ///
  /// Fetches the next page using the stored cursor for the active feed.
  Future<void> loadMore() async {
    final repository = ref.read(feedContentRepositoryProvider);

    final feedKey = _feedKeyFromUri(feedUri);
    final actualFeedUri = _resolveRemoteFeedUri();
    if (actualFeedUri == null && !_isAuthenticated) {
      _logger.debug('Skipping loadMore for timeline feed while unauthenticated');
      return;
    }

    final cursor = await repository.getCursor(feedKey);

    if (cursor != null) {
      try {
        await repository.fetchAndCacheFeed(cursor: cursor, feedUri: actualFeedUri);
      } catch (error, stack) {
        _logger.error('Failed to load more feed content', error, stack);
      }
    }
  }

  /// Clears the content for the current feed.
  ///
  /// Removes all cached items and cursor for the active feed.
  Future<void> clearFeedContent() async {
    final repository = ref.read(feedContentRepositoryProvider);
    final feedKey = _feedKeyFromUri(feedUri);
    await repository.clearFeedContent(feedKey);
  }
}
