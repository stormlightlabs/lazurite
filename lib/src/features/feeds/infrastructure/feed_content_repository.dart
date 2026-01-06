import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/feed_content_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for managing feed content (posts from feeds).
///
/// Handles fetching and caching posts from feed generators.
/// Works in conjunction with [FeedRepository] which manages feed metadata.
class FeedContentRepository {
  FeedContentRepository(this._api, this._dao, this._logger);
  final XrpcClient _api;
  final FeedContentDao _dao;
  final Logger _logger;

  /// Internal feed key for the home timeline.
  ///
  /// Uses a namespaced prefix to prevent collisions with actual AT URIs.
  static const String kInternalHomeFeedKey = '__internal:home';

  /// Helper to map API Post to DB Companion
  PostsCompanion _mapPost(Map<String, dynamic> json) {
    return PostsCompanion.insert(
      uri: json['uri'],
      cid: json['cid'],
      authorDid: json['author']['did'],
      record: jsonEncode(json['record']),
      embed: Value(json['embed'] != null ? jsonEncode(json['embed']) : null),
      indexedAt: Value(DateTime.tryParse(json['indexedAt'] ?? '')),
      replyCount: Value(json['replyCount'] ?? 0),
      repostCount: Value(json['repostCount'] ?? 0),
      likeCount: Value(json['likeCount'] ?? 0),
    );
  }

  /// Helper to map API Author to DB Companion
  ProfilesCompanion _mapProfile(Map<String, dynamic> json) {
    return ProfilesCompanion.insert(
      did: json['did'],
      handle: json['handle'],
      displayName: Value(json['displayName']),
      description: Value(json['description']),
      avatar: Value(json['avatar']),
    );
  }

  /// Derives a feedKey from a feed URI.
  ///
  /// Uses the full URI as the feedKey to ensure uniqueness.
  /// For the home feed (null feedUri), returns the internal home feed key.
  ///
  /// Validates that the feedUri doesn't collide with internal keys.
  String _feedKeyFromUri(String? feedUri) {
    if (feedUri == null) {
      return kInternalHomeFeedKey;
    }

    if (feedUri.startsWith('__internal:')) {
      throw ArgumentError.value(
        feedUri,
        'feedUri',
        'Feed URI cannot start with reserved prefix "__internal:"',
      );
    }

    return feedUri;
  }

  /// Fetch remote feed content and cache it.
  ///
  /// If [feedUri] is provided, fetches that specific feed using
  /// app.bsky.feed.getFeed (even when authenticated). Otherwise, fetches
  /// the user's home feed (authenticated) or Discover feed (unauthenticated).
  Future<void> fetchAndCacheFeed({String? cursor, String? feedUri}) async {
    final feedKey = _feedKeyFromUri(feedUri);
    _logger.info('Fetching feed content', {
      'cursor': cursor,
      'authenticated': _api.isAuthenticated,
      'feedUri': feedUri,
      'feedKey': feedKey,
    });

    try {
      final Map<String, dynamic> response;

      if (feedUri != null) {
        response = await _api.call(
          'app.bsky.feed.getFeed',
          params: {'feed': feedUri, 'limit': 50, if (cursor != null) 'cursor': cursor},
        );
      } else if (_api.isAuthenticated) {
        response = await _api.call(
          'app.bsky.feed.getTimeline',
          params: {'limit': 50, if (cursor != null) 'cursor': cursor},
        );
      } else {
        response = await _api.call(
          'app.bsky.feed.getFeed',
          params: {
            'feed': FeedRepository.kDiscoverFeedUri,
            'limit': 50,
            if (cursor != null) 'cursor': cursor,
          },
        );
      }

      final feed = response['feed'] as List;
      final nextCursor = response['cursor'] as String?;
      _logger.debug('Fetched ${feed.length} items', {'nextCursor': nextCursor});

      final posts = <PostsCompanion>[];
      final profiles = <ProfilesCompanion>[];
      final items = <FeedContentItemsCompanion>[];

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      for (var i = 0; i < feed.length; i++) {
        final item = feed[i] as Map<String, dynamic>;
        final post = item['post'] as Map<String, dynamic>;
        final author = post['author'] as Map<String, dynamic>;
        final reason = item['reason'];
        final postUri = post['uri'] as String;

        posts.add(_mapPost(post));
        profiles.add(_mapProfile(author));

        if (reason != null && reason['by'] != null) {
          profiles.add(_mapProfile(reason['by']));
        }

        final sortKey = '${baseTime - i}-$i-${postUri.hashCode.abs()}';

        items.add(
          FeedContentItemsCompanion.insert(
            feedKey: feedKey,
            postUri: postUri,
            reason: Value(reason != null ? jsonEncode(reason) : null),
            sortKey: sortKey,
          ),
        );
      }

      await _dao.insertFeedContentBatch(
        feedKey: feedKey,
        newPosts: posts,
        newProfiles: profiles,
        newItems: items,
        newCursor: nextCursor,
      );
      _logger.info('Cached ${feed.length} feed items');
    } catch (e, stack) {
      _logger.error('Failed to fetch/cache feed content', e, stack);
      rethrow;
    }
  }

  /// Watches a feed's content reactively.
  ///
  /// If [feedKey] is provided, watches that specific feed. Otherwise, watches
  /// the home feed.
  Stream<List<FeedPost>> watchFeedContent({String? feedKey}) {
    return _dao.watchFeedContent(feedKey ?? kInternalHomeFeedKey);
  }

  /// Gets the cursor for a specific feed.
  ///
  /// Returns null if no cursor is stored for the feed.
  Future<String?> getCursor(String feedKey) {
    return _dao.getCursor(feedKey);
  }

  /// Clears all cached items for a specific feed.
  ///
  /// Removes feed content items and cursor for the given feedKey.
  Future<void> clearFeedContent(String feedKey) {
    return _dao.clearFeedContent(feedKey);
  }

  /// Cleans up stale feed content (not viewed in 7 days).
  Future<void> cleanupCache() async {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    final count = await _dao.deleteStaleFeedContentItems(threshold);
    if (count > 0) {
      _logger.info('Cleaned up $count stale feed content items');
    }
  }
}
