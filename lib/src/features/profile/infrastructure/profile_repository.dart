import 'package:drift/drift.dart';
import 'package:lazurite/src/core/utils/logger.dart';
import 'package:lazurite/src/infrastructure/db/app_database.dart';
import 'package:lazurite/src/infrastructure/db/daos/follows_dao.dart';
import 'package:lazurite/src/infrastructure/db/daos/profile_dao.dart';
import 'package:lazurite/src/infrastructure/network/xrpc_client.dart';

/// Repository for profile data with cache-first reads.
class ProfileRepository {
  ProfileRepository(this._api, this._dao, this._followsDao, this._logger);

  final XrpcClient _api;
  final ProfileDao _dao;
  final FollowsDao _followsDao;
  final Logger _logger;

  /// Fetches a profile from the API and caches it.
  ///
  /// [actor] can be a DID or handle.
  Future<ProfileData> getProfile(String actor) async {
    _logger.info('Fetching profile', {'actor': actor});
    try {
      final response = await _api.call('app.bsky.actor.getProfile', params: {'actor': actor});
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
        ),
      );
      _logger.debug('Cached profile', {'did': profile.did});

      return profile;
    } catch (e, stack) {
      _logger.error('Failed to fetch profile', e, stack);
      rethrow;
    }
  }

  /// Gets a cached profile by DID.
  Future<Profile?> getCachedProfile(String did) {
    return _dao.getProfile(did);
  }

  /// Watches a cached profile by DID.
  Stream<Profile?> watchProfile(String did) {
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
              ?.map((e) => FeedItem.fromJson(e as Map<String, dynamic>))
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
              ?.map((e) => ActorBasic.fromJson(e as Map<String, dynamic>))
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
              ?.map((e) => ActorBasic.fromJson(e as Map<String, dynamic>))
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
          actorDid: actorDid,
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
      // Parse rkey from AT URI: at://did:plc:xxx/app.bsky.graph.follow/rkey
      // AT URIs don't parse with Uri.parse, so use string manipulation
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
  Future<Follow?> getCachedFollow(String actorDid, String subjectDid) {
    return _followsDao.getFollow(actorDid, subjectDid);
  }

  /// Watches cached follow state for a user.
  Stream<Follow?> watchFollow(String actorDid, String subjectDid) {
    return _followsDao.watchFollow(actorDid, subjectDid);
  }
}

/// Domain model for profile data from API.
class ProfileData {
  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final viewer = json['viewer'] as Map<String, dynamic>?;
    return ProfileData(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
      banner: json['banner'] as String?,
      followersCount: json['followersCount'] as int? ?? 0,
      followsCount: json['followsCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      indexedAt: json['indexedAt'] != null ? DateTime.tryParse(json['indexedAt'] as String) : null,
      viewerFollowing: viewer?['following'] != null,
      viewerFollowUri: viewer?['following'] as String?,
    );
  }

  ProfileData({
    required this.did,
    required this.handle,
    this.displayName,
    this.description,
    this.avatar,
    this.banner,
    this.followersCount = 0,
    this.followsCount = 0,
    this.postsCount = 0,
    this.indexedAt,
    this.viewerFollowing = false,
    this.viewerFollowUri,
  });

  final String did;
  final String handle;
  final String? displayName;
  final String? description;
  final String? avatar;
  final String? banner;
  final int followersCount;
  final int followsCount;
  final int postsCount;
  final DateTime? indexedAt;

  /// Whether the current viewer is following this profile.
  final bool viewerFollowing;

  /// The URI of the follow record (needed for unfollow).
  final String? viewerFollowUri;

  /// Returns display name or handle.
  String get displayNameOrHandle => displayName ?? handle;

  /// Creates a copy with updated viewer following state.
  ProfileData copyWith({bool? viewerFollowing, String? viewerFollowUri}) {
    return ProfileData(
      did: did,
      handle: handle,
      displayName: displayName,
      description: description,
      avatar: avatar,
      banner: banner,
      followersCount: followersCount,
      followsCount: followsCount,
      postsCount: postsCount,
      indexedAt: indexedAt,
      viewerFollowing: viewerFollowing ?? this.viewerFollowing,
      viewerFollowUri: viewerFollowUri ?? this.viewerFollowUri,
    );
  }
}

/// Result of fetching author feed.
class AuthorFeedResult {
  AuthorFeedResult({required this.items, this.cursor});

  final List<FeedItem> items;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// Result of fetching followers.
class FollowersResult {
  FollowersResult({required this.followers, this.cursor});

  final List<ActorBasic> followers;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// Result of fetching follows.
class FollowsResult {
  FollowsResult({required this.follows, this.cursor});

  final List<ActorBasic> follows;
  final String? cursor;

  bool get hasMore => cursor != null;
}

/// Basic actor information for follow lists.
class ActorBasic {
  factory ActorBasic.fromJson(Map<String, dynamic> json) {
    return ActorBasic(
      did: json['did'] as String,
      handle: json['handle'] as String,
      displayName: json['displayName'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  ActorBasic({required this.did, required this.handle, this.displayName, this.avatar});

  final String did;
  final String handle;
  final String? displayName;
  final String? avatar;

  /// Returns display name or handle.
  String get displayNameOrHandle => displayName ?? handle;
}

/// Represents a single feed item from author feed.
class FeedItem {
  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final post = json['post'] as Map<String, dynamic>;
    final author = post['author'] as Map<String, dynamic>;
    final record = post['record'] as Map<String, dynamic>;

    return FeedItem(
      uri: post['uri'] as String,
      cid: post['cid'] as String,
      authorDid: author['did'] as String,
      authorHandle: author['handle'] as String,
      authorDisplayName: author['displayName'] as String?,
      authorAvatar: author['avatar'] as String?,
      text: record['text'] as String? ?? '',
      indexedAt: DateTime.tryParse(post['indexedAt'] as String? ?? ''),
      replyCount: post['replyCount'] as int? ?? 0,
      repostCount: post['repostCount'] as int? ?? 0,
      likeCount: post['likeCount'] as int? ?? 0,
    );
  }

  FeedItem({
    required this.uri,
    required this.cid,
    required this.authorDid,
    required this.authorHandle,
    this.authorDisplayName,
    this.authorAvatar,
    required this.text,
    this.indexedAt,
    this.replyCount = 0,
    this.repostCount = 0,
    this.likeCount = 0,
  });

  final String uri;
  final String cid;
  final String authorDid;
  final String authorHandle;
  final String? authorDisplayName;
  final String? authorAvatar;
  final String text;
  final DateTime? indexedAt;
  final int replyCount;
  final int repostCount;
  final int likeCount;
}
