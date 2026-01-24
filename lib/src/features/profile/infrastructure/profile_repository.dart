import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lazurite/src/core/domain/author.dart';
import 'package:lazurite/src/core/domain/post.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart' as db;
import 'package:lazurite/src/infrastructure/db/app_database.dart' hide Post, Profile;
import 'package:lazurite/src/infrastructure/db/daos/follows_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_relationship_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

import '../domain/profile.dart';

/// Repository for profile data with cache-first reads.
class ProfileRepository {
  ProfileRepository(this._api, this._dao, this._followsDao, this._relationshipsDao, this._logger);

  final XrpcClient _api;
  final ProfileDao _dao;
  final FollowsDao _followsDao;
  final ProfileRelationshipDao _relationshipsDao;
  final Logger _logger;

  /// Fetches a profile from the API and caches it.
  ///
  /// [actor] can be a DID or handle.
  Future<ProfileData> getProfile(String actor, String ownerDid) async {
    _logger.info('Fetching profile', {'actor': actor, 'ownerDid': ownerDid});
    try {
      final response = await _api.call('app.bsky.actor.getProfile', params: {'actor': actor});
      _logger.debug('getProfile response', {
        'handle': response['handle'],
        'viewer': response['viewer'],
      });

      final pinnedRaw = response['pinnedPost'];
      if (pinnedRaw != null) {
        _logger.info('Received pinnedPost', {
          'type': pinnedRaw.runtimeType.toString(),
          'value': pinnedRaw.toString(),
        });
      } else {
        _logger.info('No pinnedPost in response');
      }

      final profile = ProfileData.fromJson(response);

      await _dao.upsertProfile(
        ProfilesCompanion.insert(
          did: profile.did,
          handle: profile.handle,
          displayName: Value(profile.displayName),
          description: Value(profile.description),
          avatar: Value(profile.avatar),
          banner: Value(profile.banner),
          indexedAt: Value(profile.indexedAt),
          pronouns: Value(profile.pronouns),
          website: Value(profile.website),
          createdAt: Value(profile.createdAt),
          verificationStatus: Value(profile.verificationStatus),
          labels: Value(profile.labels != null ? jsonEncode(profile.labels) : null),
          pinnedPostUri: Value(profile.pinnedPostUri),
        ),
      );

      _logger.debug('Caching relationship', {
        'ownerDid': ownerDid,
        'profileDid': profile.did,
        'following': profile.viewerFollowing,
        'followedBy': profile.viewerFollowedBy,
        'followingUri': profile.viewerFollowUri,
      });

      await _relationshipsDao.upsertRelationship(
        ProfileRelationshipsCompanion.insert(
          ownerDid: ownerDid,
          profileDid: profile.did,
          following: Value(profile.viewerFollowing),
          followingUri: Value(profile.viewerFollowUri),
          followedBy: Value(profile.viewerFollowedBy),
          muted: Value(profile.viewerMuted),
          blocked: Value(profile.viewerBlockingUri != null),
          blockedBy: Value(profile.viewerBlockedBy),
          blockingUri: Value(profile.viewerBlockingUri),
          mutedByList: Value(profile.viewerMutedByList),
          blockingByList: Value(profile.viewerBlockingByList),
          updatedAt: DateTime.now(),
        ),
      );

      _logger.debug('Cached profile and relationships', {'did': profile.did});

      return profile;
    } catch (e, stack) {
      _logger.error('Failed to fetch profile', e, stack);
      rethrow;
    }
  }

  /// Gets a cached profile by DID.
  Future<db.Profile?> getCachedProfile(String did) {
    return _dao.getProfile(did);
  }

  /// Watches a cached profile by DID.
  Stream<db.Profile?> watchProfile(String did) {
    return _dao.watchProfile(did);
  }

  /// Fetches author's feed with cursor pagination.
  Future<AuthorFeedResult> getAuthorFeed(String actor, {String? cursor}) async {
    _logger.info('Fetching author feed', {'actor': actor, 'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.feed.getAuthorFeed',
        params: {'actor': actor, 'limit': 50, if (cursor != null) 'cursor': cursor},
      );

      final feed =
          (response['feed'] as List?)
              ?.map((e) => Post.fromLexicon(e as Map<String, dynamic>))
              .toList() ??
          [];
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Fetched ${feed.length} author feed items');
      return AuthorFeedResult(items: feed, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Failed to fetch author feed', e, stack);
      rethrow;
    }
  }

  /// Fetches followers of an actor with cursor pagination.
  Future<FollowersResult> getFollowers(String actor, {String? cursor}) async {
    _logger.info('Fetching followers', {'actor': actor, 'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.graph.getFollowers',
        params: {'actor': actor, 'limit': 50, if (cursor != null) 'cursor': cursor},
      );

      final followers =
          (response['followers'] as List?)
              ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Fetched ${followers.length} followers');
      return FollowersResult(followers: followers, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Failed to fetch followers', e, stack);
      rethrow;
    }
  }

  /// Fetches accounts an actor is following with cursor pagination.
  Future<FollowsResult> getFollows(String actor, {String? cursor}) async {
    _logger.info('Fetching follows', {'actor': actor, 'cursor': cursor});
    try {
      final response = await _api.call(
        'app.bsky.graph.getFollows',
        params: {'actor': actor, 'limit': 50, if (cursor != null) 'cursor': cursor},
      );

      final follows =
          (response['follows'] as List?)
              ?.map((e) => Author.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final nextCursor = response['cursor'] as String?;

      _logger.debug('Fetched ${follows.length} follows');
      return FollowsResult(follows: follows, cursor: nextCursor);
    } catch (e, stack) {
      _logger.error('Failed to fetch follows', e, stack);
      rethrow;
    }
  }

  /// Follow a user. Returns the created follow record URI.
  Future<String> follow(String actorDid, String subjectDid) async {
    _logger.info('Following user', {'subject': subjectDid});
    try {
      final response = await _api.call(
        'com.atproto.repo.createRecord',
        body: {
          'repo': actorDid,
          'collection': 'app.bsky.graph.follow',
          'record': {
            r'$type': 'app.bsky.graph.follow',
            'subject': subjectDid,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );

      final uri = response['uri'] as String;

      await _followsDao.upsertFollow(
        FollowsCompanion.insert(
          actorDid: actorDid, // actorDid is the owner
          subjectDid: subjectDid,
          uri: uri,
          createdAt: Value(DateTime.now()),
        ),
      );

      _logger.debug('Created follow record', {'uri': uri});
      return uri;
    } catch (e, stack) {
      _logger.error('Failed to follow user', e, stack);
      rethrow;
    }
  }

  /// Unfollow a user by deleting the follow record.
  Future<void> unfollow(String actorDid, String followUri) async {
    _logger.info('Unfollowing user', {'uri': followUri});
    try {
      final parts = followUri.split('/');
      if (parts.length < 2) {
        throw ArgumentError('Invalid follow URI: $followUri');
      }
      final rkey = parts.last;

      await _api.call(
        'com.atproto.repo.deleteRecord',
        body: {'repo': actorDid, 'collection': 'app.bsky.graph.follow', 'rkey': rkey},
      );

      await _followsDao.deleteFollowByUri(followUri);

      _logger.debug('Deleted follow record', {'uri': followUri});
    } catch (e, stack) {
      _logger.error('Failed to unfollow user', e, stack);
      rethrow;
    }
  }

  /// Gets cached follow state for a user.
  Future<db.Follow?> getCachedFollow(String actorDid, String subjectDid) {
    return _followsDao.getFollow(actorDid, subjectDid);
  }

  /// Watches cached follow state for a user.
  Stream<db.Follow?> watchFollow(String actorDid, String subjectDid) {
    return _followsDao.watchFollow(actorDid, subjectDid);
  }

  /// Mutes a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  Future<void> muteActor(String actorDid, String subjectDid) async {
    _logger.info('Muting user', {'subject': subjectDid});
    try {
      await _api.call('app.bsky.graph.muteActor', body: {'actor': subjectDid});

      await _relationshipsDao.updateMuteStatus(subjectDid, true, actorDid);
      _logger.debug('Muted user', {'subject': subjectDid});
    } catch (e, stack) {
      _logger.error('Failed to mute user', e, stack);
      rethrow;
    }
  }

  /// Unmutes a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  Future<void> unmuteActor(String actorDid, String subjectDid) async {
    _logger.info('Unmuting user', {'subject': subjectDid});
    try {
      await _api.call('app.bsky.graph.unmuteActor', body: {'actor': subjectDid});

      await _relationshipsDao.updateMuteStatus(subjectDid, false, actorDid);
      _logger.debug('Unmuted user', {'subject': subjectDid});
    } catch (e, stack) {
      _logger.error('Failed to unmute user', e, stack);
      rethrow;
    }
  }

  /// Blocks a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  Future<String> blockActor(String actorDid, String subjectDid) async {
    _logger.info('Blocking user', {'subject': subjectDid});
    try {
      final response = await _api.call(
        'com.atproto.repo.createRecord',
        body: {
          'repo': actorDid,
          'collection': 'app.bsky.graph.block',
          'record': {
            r'$type': 'app.bsky.graph.block',
            'subject': subjectDid,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );

      final uri = response['uri'] as String;

      await _relationshipsDao.updateBlockStatus(subjectDid, true, actorDid, blockingUri: uri);
      _logger.debug('Blocked user', {'subject': subjectDid, 'uri': uri});
      return uri;
    } catch (e, stack) {
      _logger.error('Failed to block user', e, stack);
      rethrow;
    }
  }

  /// Unblocks a user.
  ///
  /// This is a graph operation but is included here for profile management context.
  /// [subjectDid] is optional but recommended to allow immediate local state update.
  Future<void> unblockActor(String actorDid, String blockUri, {String? subjectDid}) async {
    _logger.info('Unblocking user', {'uri': blockUri, 'subject': subjectDid});
    try {
      final parts = blockUri.split('/');
      if (parts.length < 2) {
        throw ArgumentError('Invalid block URI: $blockUri');
      }
      final rkey = parts.last;

      await _api.call(
        'com.atproto.repo.deleteRecord',
        body: {'repo': actorDid, 'collection': 'app.bsky.graph.block', 'rkey': rkey},
      );

      if (subjectDid != null) {
        await _relationshipsDao.updateBlockStatus(subjectDid, false, actorDid);
      }

      _logger.debug('Deleted block record', {'uri': blockUri});
    } catch (e, stack) {
      _logger.error('Failed to unblock user', e, stack);
      rethrow;
    }
  }

  /// Reports a user or content.
  ///
  /// [reasonType] should be one of the supported AT Protocol report reasons.
  Future<void> createReport({
    required String reasonType,
    required String subjectDid,
    String? reason,
  }) async {
    _logger.info('Reporting user', {'subject': subjectDid, 'reasonType': reasonType});
    try {
      await _api.call(
        'com.atproto.moderation.createReport',
        body: {
          'reasonType': reasonType,
          'subject': {r'$type': 'com.atproto.admin.defs#repoRef', 'did': subjectDid},
          if (reason != null) 'reason': reason,
        },
      );
      _logger.debug('Reported user', {'subject': subjectDid});
    } catch (e, stack) {
      _logger.error('Failed to report user', e, stack);
      rethrow;
    }
  }

  /// Fetches a single post by URI.
  Future<Post?> getPost(String uri) async {
    _logger.info('Fetching post', {'uri': uri});
    try {
      final response = await _api.call(
        'app.bsky.feed.getPosts',
        params: {
          'uris': [uri],
        },
      );

      final posts = response['posts'] as List?;
      if (posts == null || posts.isEmpty) return null;

      return Post.fromLexicon(posts.first as Map<String, dynamic>);
    } catch (e, stack) {
      _logger.error('Failed to fetch post', e, stack);
      rethrow;
    }
  }
}
