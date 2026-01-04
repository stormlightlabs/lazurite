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

  /// Fetch remote timeline and cache it
  Future<void> fetchAndCacheTimeline({String? cursor}) async {
    _logger.info('Fetching timeline', {'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.feed.getTimeline',
        params: {'limit': 50, if (cursor != null) 'cursor': cursor},
      );

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

        // TODO: support other feeds
        items.add(
          TimelineItemsCompanion.insert(
            feedKey: 'home',
            postUri: post['uri'],
            reason: Value(reason != null ? jsonEncode(reason) : null),
            sortKey: '${baseTime - i}',
          ),
        );
      }

      await _dao.insertTimelineBatch(
        feedKey: 'home',
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

  Stream<List<TimelineFeedItem>> watchTimeline() {
    return _dao.watchTimeline('home');
  }
}
