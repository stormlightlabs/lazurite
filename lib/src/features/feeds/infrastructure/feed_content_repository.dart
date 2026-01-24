import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/features/feeds/infrastructure/feed_repository.dart';
import 'package:lazurite/src/features/thread/domain/thread.dart';
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
    try {
      final post = ThreadPost.fromJson(json);
      return post.toPostsCompanion();
    } catch (e) {
      _logger.error('Failed to map post', {'error': e, 'json': json});
      rethrow;
    }
  }

  /// Helper to map API Author to DB Companion with validation.
  ///
  /// Throws [FormatException] if required fields are missing or invalid.
  ProfilesCompanion _mapProfile(Map<String, dynamic> json) {
    try {
      final author = ThreadAuthor.fromJson(json);
      return author.toProfilesCompanion();
    } catch (e) {
      _logger.error('Failed to map profile', {'error': e, 'json': json});
      rethrow;
    }
  }

  /// Helper to map API Author to DB Companion with validation.
  ///
  /// Extracts viewer relationship data if present.
  ProfileRelationshipsCompanion? _mapRelationship(Map<String, dynamic> json, String ownerDid) {
    try {
      final author = ThreadAuthor.fromJson(json);
      return author.toRelationshipCompanion(ownerDid);
    } catch (e) {
      _logger.warning('Failed to map relationship', {'error': e, 'json': json});
      return null;
    }
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

  /// Fetches and caches bookmarked posts.
  ///
  /// Uses a special internal feed key [kInternalBookmarksFeedKey].
  Future<void> fetchBookmarks({String? cursor, required String ownerDid}) async {
    const feedKey = '__internal:bookmarks';
    _logger.info('Fetching bookmarks', {'cursor': cursor, 'ownerDid': ownerDid});

    try {
      final response = await _api.call(
        'app.bsky.bookmark.getBookmarks',
        params: {'limit': 50, if (cursor != null) 'cursor': cursor},
      );

      final bookmarks = response['bookmarks'] as List;
      final nextCursor = response['cursor'] as String?;

      final posts = <PostsCompanion>[];
      final profiles = <ProfilesCompanion>[];
      final relationships = <ProfileRelationshipsCompanion>[];
      final items = <FeedContentItemsCompanion>[];

      final baseTime = DateTime.now().microsecondsSinceEpoch;

      for (var i = 0; i < bookmarks.length; i++) {
        final bookmark = bookmarks[i];

        Map<String, dynamic> postJson;
        if (bookmark.containsKey('post')) {
          postJson = bookmark['post'];
        } else {
          postJson = bookmark;
        }

        final postUri = postJson['uri'];
        if (postUri is! String || postUri.isEmpty) continue;

        try {
          posts.add(_mapPost(postJson));

          if (postJson['author'] != null) {
            profiles.add(_mapProfile(postJson['author']));

            final authorRel = _mapRelationship(postJson['author'], ownerDid);
            if (authorRel != null) {
              relationships.add(authorRel);
            }
          }

          final embedJson = postJson['embed'];
          if (embedJson is Map<String, dynamic>) {
            final embedType = embedJson['\$type'] as String?;

            if (embedType == 'app.bsky.embed.record' ||
                embedType == 'app.bsky.embed.recordWithMedia') {
              final recordJson = embedJson['record'];
              if (recordJson is Map<String, dynamic>) {
                final embeddedAuthor = recordJson['author'];
                if (embeddedAuthor is Map<String, dynamic>) {
                  try {
                    profiles.add(_mapProfile(embeddedAuthor));
                    final embeddedRel = _mapRelationship(embeddedAuthor, ownerDid);
                    if (embeddedRel != null) {
                      relationships.add(embeddedRel);
                    }
                  } catch (e) {
                    _logger.warning('Failed to map embedded author', {
                      'error': e,
                      'author': embeddedAuthor,
                    });
                  }
                }
              }
            }
          }

          final sortKey = '${baseTime - i}-$i-${postUri.hashCode.abs()}';

          items.add(
            FeedContentItemsCompanion.insert(
              feedKey: feedKey,
              postUri: postUri,
              ownerDid: ownerDid,
              sortKey: sortKey,
            ),
          );
        } catch (e) {
          _logger.warning('Skipping invalid bookmark item', {'error': e, 'item': bookmark});
        }
      }

      await _dao.insertFeedContentBatch(
        feedKey: feedKey,
        ownerDid: ownerDid,
        newPosts: posts,
        newProfiles: profiles,
        newRelationships: relationships,
        newItems: items,
        newCursor: nextCursor,
      );
      _logger.info('Cached ${bookmarks.length} bookmarks');
    } catch (e, stack) {
      _logger.error('Failed to fetch/cache bookmarks', e, stack);
      rethrow;
    }
  }

  /// Fetch remote feed content and cache it.
  Future<void> fetchAndCacheFeed({
    required String ownerDid,
    String? cursor,
    String? feedUri,
  }) async {
    final feedKey = _feedKeyFromUri(feedUri);

    _logger.info('Fetching feed content', {
      'cursor': cursor,
      'authenticated': _api.isAuthenticated,
      'feedUri': feedUri,
      'feedKey': feedKey,
      'ownerDid': ownerDid,
    });

    try {
      final Map<String, dynamic> response;

      if (feedUri != null) {
        final isListFeed = _isListFeedUri(feedUri);
        final endpoint = isListFeed ? 'app.bsky.feed.getListFeed' : 'app.bsky.feed.getFeed';
        final paramKey = isListFeed ? 'list' : 'feed';
        response = await _api.call(
          endpoint,
          params: {paramKey: feedUri, 'limit': 50, if (cursor != null) 'cursor': cursor},
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
        final authorRel = _mapRelationship(authorJson, ownerDid);
        if (authorRel != null) {
          relationships.add(authorRel);
        }

        final reasonJson = itemJson['reason'];
        if (reasonJson is Map<String, dynamic>) {
          final byJson = reasonJson['by'];
          if (byJson is Map<String, dynamic>) {
            profiles.add(_mapProfile(byJson));
            final byRel = _mapRelationship(byJson, ownerDid);
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
            ownerDid: ownerDid,
            reason: Value(reasonJson != null ? jsonEncode(reasonJson) : null),
            sortKey: sortKey,
          ),
        );
      }

      await _dao.insertFeedContentBatch(
        feedKey: feedKey,
        ownerDid: ownerDid,
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

  /// Watches a feed's content reactively for a specific user.
  Stream<List<FeedPost>> watchFeedContent({required String ownerDid, String? feedKey}) {
    return _dao.watchFeedContent(feedKey ?? kInternalHomeFeedKey, ownerDid);
  }

  /// Gets the cursor for a specific feed and user.
  Future<String?> getCursor(String feedKey, String ownerDid) {
    return _dao.getCursor(feedKey, ownerDid);
  }

  /// Clears all cached items for a specific feed and user.
  Future<void> clearFeedContent(String feedKey, String ownerDid) {
    return _dao.clearFeedContent(feedKey, ownerDid);
  }

  /// Cleans up stale feed content (not viewed in 7 days).
  Future<void> cleanupCache(String ownerDid) async {
    final threshold = DateTime.now().subtract(const Duration(days: 7));
    final count = await _dao.deleteStaleFeedContentItems(threshold, ownerDid);
    if (count > 0) {
      _logger.info('Cleaned up $count stale feed content items for $ownerDid');
    }
  }

  bool _isListFeedUri(String feedUri) {
    if (!feedUri.startsWith('at://')) return false;
    final withoutScheme = feedUri.substring(5);
    final segments = withoutScheme.split('/');
    if (segments.length < 2) return false;
    return segments[1] == 'app.bsky.graph.list';
  }
}
