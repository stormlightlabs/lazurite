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

  /// Helper to map API Post to DB Companion with validation.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  PostsCompanion _mapPost(Map<String, dynamic> json) {
    final authorJson = json['author'];
    if (authorJson is! Map<String, dynamic>) {
      throw FormatException('Post author must be a Map', json);
    }

    final authorDid = authorJson['did'];
    if (authorDid is! String || authorDid.isEmpty) {
      throw FormatException('Post author.did must be a non-empty string', json);
    }

    final uri = json['uri'];
    final cid = json['cid'];
    if (uri is! String || uri.isEmpty) {
      throw FormatException('Post uri must be a non-empty string', json);
    }
    if (cid is! String || cid.isEmpty) {
      throw FormatException('Post cid must be a non-empty string', json);
    }

    return PostsCompanion.insert(
      uri: uri,
      cid: cid,
      authorDid: authorDid,
      record: jsonEncode(json['record']),
      embed: Value(json['embed'] != null ? jsonEncode(json['embed']) : null),
      indexedAt: Value(DateTime.tryParse(json['indexedAt'] as String? ?? '')),
      replyCount: Value(json['replyCount'] as int? ?? 0),
      repostCount: Value(json['repostCount'] as int? ?? 0),
      likeCount: Value(json['likeCount'] as int? ?? 0),
      labels: Value(json['labels'] != null ? jsonEncode(json['labels']) : null),
    );
  }

  /// Helper to map API Author to DB Companion with validation.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  ProfilesCompanion _mapProfile(Map<String, dynamic> json) {
    final did = json['did'];
    final handle = json['handle'];

    if (did is! String || did.isEmpty) {
      throw FormatException('Profile did must be a non-empty string', json);
    }
    if (handle is! String || handle.isEmpty) {
      throw FormatException('Profile handle must be a non-empty string', json);
    }

    return ProfilesCompanion.insert(
      did: did,
      handle: handle,
      displayName: Value(json['displayName'] as String?),
      description: Value(json['description'] as String?),
      avatar: Value(json['avatar'] as String?),
    );
  }

  /// Helper to map API Author to DB Companion with validation.
  ///
  /// Extracts viewer relationship data if present.
  ProfileRelationshipsCompanion? _mapRelationship(Map<String, dynamic> json) {
    final did = json['did'];
    if (did is! String || did.isEmpty) return null;

    final viewer = json['viewer'] as Map<String, dynamic>?;
    if (viewer == null) return null;

    return ProfileRelationshipsCompanion.insert(
      profileDid: did,
      following: Value(viewer['following'] != null),
      followingUri: Value(viewer['following'] as String?),
      followedBy: Value(viewer['followedBy'] != null),
      muted: Value(viewer['muted'] as bool? ?? false),
      blocked: Value(viewer['blocking'] != null),
      blockingUri: Value(viewer['blocking'] as String?),
      blockedBy: Value(viewer['blockedBy'] as bool? ?? false),
      mutedByList: Value(viewer['mutedByList']?['uri'] as String?),
      blockingByList: Value(viewer['blockingByList']?['uri'] as String?),
      updatedAt: DateTime.now(),
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

      final feedJson = response['feed'];
      if (feedJson is! List) {
        throw FormatException('feed must be a List', response);
      }
      final nextCursor = response['cursor'] as String?;
      _logger.debug('Fetched ${feedJson.length} items', {'nextCursor': nextCursor});

      final posts = <PostsCompanion>[];
      final profiles = <ProfilesCompanion>[];
      final relationships = <ProfileRelationshipsCompanion>[];
      final items = <FeedContentItemsCompanion>[];

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      for (var i = 0; i < feedJson.length; i++) {
        final itemJson = feedJson[i];
        if (itemJson is! Map<String, dynamic>) {
          throw FormatException('Feed item must be a Map', itemJson);
        }

        final postJson = itemJson['post'];
        if (postJson is! Map<String, dynamic>) {
          throw FormatException('Feed item post must be a Map', itemJson);
        }

        final authorJson = postJson['author'];
        if (authorJson is! Map<String, dynamic>) {
          throw FormatException('Post author must be a Map', postJson);
        }

        final postUri = postJson['uri'];
        if (postUri is! String || postUri.isEmpty) {
          throw FormatException('Post uri must be a non-empty string', postJson);
        }

        posts.add(_mapPost(postJson));
        profiles.add(_mapProfile(authorJson));
        final authorRel = _mapRelationship(authorJson);
        if (authorRel != null) {
          relationships.add(authorRel);
        }

        final reasonJson = itemJson['reason'];
        if (reasonJson is Map<String, dynamic>) {
          final byJson = reasonJson['by'];
          if (byJson is Map<String, dynamic>) {
            profiles.add(_mapProfile(byJson));
            final byRel = _mapRelationship(byJson);
            if (byRel != null) {
              relationships.add(byRel);
            }
          }
        }

        final sortKey = '${baseTime - i}-$i-${postUri.hashCode.abs()}';

        items.add(
          FeedContentItemsCompanion.insert(
            feedKey: feedKey,
            postUri: postUri,
            reason: Value(reasonJson != null ? jsonEncode(reasonJson) : null),
            sortKey: sortKey,
          ),
        );
      }

      await _dao.insertFeedContentBatch(
        feedKey: feedKey,
        newPosts: posts,
        newProfiles: profiles,
        newRelationships: relationships,
        newItems: items,
        newCursor: nextCursor,
      );
      _logger.info('Cached ${feedJson.length} feed items');
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
