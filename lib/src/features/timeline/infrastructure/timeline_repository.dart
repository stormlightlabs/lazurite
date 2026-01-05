import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/timeline_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

class TimelineRepository {
  TimelineRepository(this._api, this._dao, this._logger);
  final XrpcClient _api;
  final TimelineDao _dao;
  final Logger _logger;

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
      // TODO: hostedAt
    );
  }

  /// The official What's Hot feed for unauthenticated users
  static const kDiscoverFeedUri =
      'at://did:plc:z72i7hdynmk6r22z27h6tvur/app.bsky.feed.generator/whats-hot';

  /// Derives a feedKey from a feed URI.
  ///
  /// Uses the full URI as the feedKey to ensure uniqueness.
  /// For the home timeline (null feedUri), returns 'home'.
  String _feedKeyFromUri(String? feedUri) {
    return feedUri ?? 'home';
  }

  /// Fetch remote timeline and cache it.
  ///
  /// If [feedUri] is provided, fetches that specific feed using
  /// app.bsky.feed.getFeed (even when authenticated). Otherwise, fetches
  /// the user's home timeline (authenticated) or Discover feed (unauthenticated).
  Future<void> fetchAndCacheTimeline({String? cursor, String? feedUri}) async {
    final feedKey = _feedKeyFromUri(feedUri);
    _logger.info('Fetching timeline', {
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
          params: {'feed': kDiscoverFeedUri, 'limit': 50, if (cursor != null) 'cursor': cursor},
        );
      }

      final feed = response['feed'] as List;
      final nextCursor = response['cursor'] as String?;
      _logger.debug('Fetched ${feed.length} items', {'nextCursor': nextCursor});

      final posts = <PostsCompanion>[];
      final profiles = <ProfilesCompanion>[];
      final items = <TimelineItemsCompanion>[];

      final baseTime = DateTime.now().millisecondsSinceEpoch;

      for (var i = 0; i < feed.length; i++) {
        final item = feed[i] as Map<String, dynamic>;
        final post = item['post'] as Map<String, dynamic>;
        final author = post['author'] as Map<String, dynamic>;
        final reason = item['reason'];

        posts.add(_mapPost(post));
        profiles.add(_mapProfile(author));

        if (reason != null && reason['by'] != null) {
          profiles.add(_mapProfile(reason['by']));
        }

        items.add(
          TimelineItemsCompanion.insert(
            feedKey: feedKey,
            postUri: post['uri'],
            reason: Value(reason != null ? jsonEncode(reason) : null),
            sortKey: '${baseTime - i}',
          ),
        );
      }

      await _dao.insertTimelineBatch(
        feedKey: feedKey,
        newPosts: posts,
        newProfiles: profiles,
        newItems: items,
        newCursor: nextCursor,
      );
      _logger.info('Cached ${feed.length} timeline items');
    } catch (e, stack) {
      _logger.error('Failed to fetch/cache timeline', e, stack);
      rethrow;
    }
  }

  /// Watches a timeline feed reactively.
  ///
  /// If [feedKey] is provided, watches that specific feed. Otherwise, watches
  /// the home timeline.
  Stream<List<TimelineFeedItem>> watchTimeline({String? feedKey}) {
    return _dao.watchTimeline(feedKey ?? 'home');
  }

  /// Gets the cursor for a specific feed.
  ///
  /// Returns null if no cursor is stored for the feed.
  Future<String?> getCursor(String feedKey) {
    return _dao.getCursor(feedKey);
  }

  /// Clears all cached items for a specific feed.
  ///
  /// Removes timeline items and cursor for the given feedKey.
  Future<void> clearTimeline(String feedKey) {
    return _dao.clearTimeline(feedKey);
  }

  /// Cleans up stale timeline items (not viewed in 7 days).
  Future<void> cleanupCache() async {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    final count = await _dao.deleteStaleTimelineItems(threshold);
    if (count > 0) {
      _logger.info('Cleaned up $count stale timeline items');
    }
  }
}
